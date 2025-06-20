function varargout = ...
    bin_pixels_with_mex_code_(obj,coord,proc_mode,...
    npix,s,err,pix_cand,unique_runid,force_double,return_selected,test_mex_inputs)
% s,e,pix,unique_runid,pix_indx
% Sort pixels according to their coordinates in the axes grid and
% calculate pixels grid statistics.
%
%--------------------------------------------------------------------------
% Inputs:
%
% obj   -- the initialized AxesBlockBase object with the grid defined
% coord -- the 3D or 4D array of pixels coordinates transformed into
%          AxesBlockBase coordinate system
% proc_mode
%       -- the number of output parameters requested to process. Depending
%          on this number, additional parts of the algorithm are deployed.
% npix
%      -- the array of size of this grid, accumulating the information
%         about number of pixels contributing into each bin of the grid,
%         defined by this axes block. This routine uses it only as
%         indicator of number of calls to this code and keeps ownership of
%         actual npix array to itself. On first call it is empty and on
%         subsequent calls it gets values from previous call to binning
%         routine
% s    -- the array of size of this grid accumulating information about
%
% pix_cand
%      -- if provided (not empty) contain PixelData information with
%         the pixels to bin. The signal and error, contributing into s and
%         e arrays are taken from this data. Some outputs may request sorting
%         pix_cand according to the grid.
% unique_runid
%      -- The unique indices, contributing into the cut. Empty on first
%         call.
%
% force_double -- if true, the routine changes type of pixels
%                 it gets on input, into double. if not, output
%                 pixels will keep their initial type.
% return_selected
%              -- if true sets pix_ok to return the indices of selected
%                 pixels for use with DnD cuts where fewer args are
%                 requested
% SPECIAL:
% test_mex_inputs
%              -- if ture, routine works in testing mode and all input
%                 parameters are reflected to output parameters.
%                 This mode used in unit testing to verify correct
%                 operations of mex code.
%--------------------------------------------------------------------------
% Outputs:
% npix  -- the array of size of this grid, accumulating the information
%          about number of pixels contributing into each bin of the grid,
%          defined by this axes block.
% Optional:
% s,e  -- if proc_mode >=3, contains accumulated signal and errors from
%         the pixels, contributing into the grid. num_outputs >=3 requests
%         pix_cand parameter to be present and not empty.
% pix_ok
%      -- if proc_mode >=4, returns input pix_cand contributed to
%         the the cut and sorted by grid cell or left unsorted,
%         depending on requested pix_indx output.
%         IF return_selected is true, contains indices of kept pixels
% unique_runid
%      -- if proc_mode >=5, array, containing the unique runids from the
%         pixels, contributed to the cut. If input unique_runid was not
%         empty, output unique_runid is combined with the input unique_runid
%         and contains no duplicates.
% pix_indx
%      -- in proc_mode ==6, contains indices of the grid cells,
%         containing the pixels from input pix_cand. If this parameter is
%         requested, the order of output pix corresponds to the order of
%         pixels in PixelData. if proc_mode < 6, output pix are sorted by
%         npix bins.
%
% selected
%      -- in proc_mode == 7, contains logical array with true where
%         pixels were kept and false, where they are dropped

persistent mex_code_holder; % the variable contains pointer, which ensure
% constitency of subsequent calls to mex code.
persistent npix_retained; % number of pixels retained during sequence
% of calls to bin pixels with persistent accumulators
if isempty(npix)
    % clear mex code holder to reset mex code binning to defaults and start
    % binning operation over
    mex_code_holder = [];
    npix_retained = 0;
end
if isempty(npix_retained)
    npix_retained = 0;
end


num_threads = config_store.instance().get_value('parallel_config','threads');

nbins_all_dims = uint32(obj.nbins_all_dims(:)');
if size(coord,1) == 3  % 3D array binning
    pax = obj.pax;
    data_range     = obj.img_range(:,1:3);
    nbins_all_dims = nbins_all_dims(1:3);
    pax = pax(pax~=4);
    ndims = numel(pax);
else
    data_range = obj.img_range;
    ndims = obj.dimensions;
end

other_mex_input = struct( ...
    'coord_in',    coord,...                % input coordinates to bin. May be empty in modes when they are processed from transformed pixel data
    'binning_mode',proc_mode, ...           % binning mode, what binning values to calculate and return
    'num_threads', num_threads,  ...        % how many threads to use in parallel computation
    'data_range',  data_range,...           % binning ranges
    'dimensions',   ndims, ...              % number of image dimensions (sum(nbins_all_dims > 1)))
    'nbins_all_dims',nbins_all_dims, ...    % dimensions of binning lattice
    'unique_runid', unique_runid, ...       % unique run indices of pixels contributing into cut
    'force_double', force_double, ...       % make result double precision regardless of input data
    'return_selected',return_selected,...   %
    'test_input_parsing',test_mex_inputs ...% Run mex code in test mode validating the way input have been parsed by mex code and doing no caclculations.
    );
other_mex_input.unique_runid = unique_runid;

is_pix = isa(pix_cand,'PixelDataBase');
if is_pix
    other_mex_input.pix_candidates   = pix_cand.get_raw_data;
    other_mex_input.check_pix_selection = true; % check if pixels have already been processed by previous symmetry operations
    ndata = 2;
    if pix_cand.is_corrected
        other_mex_input.alignment_matr = pix_cand.alignment_matr;
    else
        other_mex_input.alignment_matr  = [];
    end
else
    other_mex_input.alignment_matr   = [];
    other_mex_input.pix_candidates   = pix_cand;
    other_mex_input.check_pix_selection  = false; % use all pixels, do not analyze selection
    % cell with data array
    ndata = numel(pix_cand);
end
% routine allocates npix (s,e on request) on first call and keeps ownership
% of these arrays internally. Input npix is not used and serves just as an
% indication that this is the first call to the routine if npix is empty.
% [mex_code_holder,npix, s, e,out_param_names,out_param_values] = bin_pixels_c( ...
%     mex_code_holder,npix_in,s_in,err_in,other_mex_input);
if proc_mode == 1
    % return mex_holder, npix, field_names, field_values
    out = cell(1,4);
else % return mex_holder, npix, s, e, field_names, field_values for the fields
    % requested by binning mode
    out = cell(1,6);
end

% mex code preserves its state between calls unless mex_code_holder is
% changed or input npix array provided as input is empty or bin_pixels_c('clear') 
% is called explicitly somewhere from MATLAB session. 
% This behaviour should be accounted for whien binning is used in a loop !!!
varargout = cell(1,nargout);
[out{:}] = bin_pixels_c(mex_code_holder,npix,s,err,other_mex_input);
mex_code_holder = out{1};
varargout{bin_out.npix} = out{2};

if proc_mode == 1
    % in this case pix_ok change meaning and contains output data structure
    % directly. The structure itself contains copy of input parameters plus
    % various helper values obtained from input and used during the testing
    % [mp,npix, fields, values] = bin_pixels_c(coord,npix,s,e,other_mex_input);

    out_struc = cell2struct(out{4},out{3},2);
    if ~test_mex_inputs
        npix_retained = npix_retained + out_struc.npix_retained;
        out_struc.npix_retained = npix_retained;
    end
    if nargout > 1
        varargout{end} = out_struc;
    end
else  % otherwise, there are no such ouputs, output structure is flattened
    out_struc = cell2struct(out{6},out{5},2);
    %[mp,npix, s, e, fields, values] = bin_pixels_c(coord,npix,s,e,other_mex_input);
    varargout{bin_out.s} = out{3};
    varargout{bin_out.e} = out{4};
    if test_mex_inputs
        varargout{end} = out_struc;
    end
    npix_retained = npix_retained + out_struc.npix_retained;

    pix_ok_data  = out_struc.pix_ok_data;
    pix_ok_range = out_struc.pix_ok_data_range;

    if proc_mode<4 || ~is_pix
        if ndata>=3
            varargout{bin_out.pix_ok} = pix_ok_range; % redefine pix_ok_range to be npix accumulated
        end
    end
    if proc_mode<5
        return;
    end

    if isempty(pix_ok_data)
        varargout{bin_out.pix_ok} = pix_ok_data;
    else
        pix_ok = PixelDataMemory();
        pix_ok = pix_ok.set_raw_data(pix_ok_data);
        varargout{bin_out.pix_ok} = pix_ok.set_data_range(pix_ok_range);
    end
    if proc_mode<6
        return;
    end
    
    % in modes where these values are not calculated, the code returns
    % empty
    varargout{bin_out.unique_runid}  = out_struc.unique_runid;
    varargout{bin_out.pix_indx}      = out_struc.pix_idx;
    varargout{bin_out.selected}      = out_struc.selected;
end

end

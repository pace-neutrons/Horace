function [obj,npix, s, e, pix_ok, unique_runid, pix_indx, selected] = ...
    bin_pixels_with_mex_code_(obj,coord,num_outputs,...
    npix_in,pix_cand,unique_runid,force_double,return_selected,test_mex_inputs)
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
% num_outputs
%       -- the number of output parameters requested to process. Depending
%          on this number, additional parts of the algorithm will be
%          deployed.
% npix_in
%       -- the array of size of this grid, accumulating the information
%          about number of pixels contributing into each bin of the grid,
%          defined by this axes block. This routine uses it only as
%          indicator of number of calls to this code and keeps ownership of
%          actual npix array to itself. On first call it is empty and on
%          subsequent calls it gets values from previous call to binning
%          routine
% pix_cand
%      -- if provided (not empty) contain PixelData information with
%         the pixels to bin. The signal and error, contributing into s and
%         e arrays are taken from this data. Some outputs may request sorting
%         pix_cand according to the grid.
% unique_runid
%      -- The unique indices, contributing into the cut. Empty on first
%         call.
% varargin may contain the following parameters:
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
% s,e  -- if num_outputs >=3, contains accumulated signal and errors from
%         the pixels, contributing into the grid. num_outputs >=3 requests
%         pix_cand parameter to be present and not empty.
% pix_ok
%      -- if num_outputs >=4, returns input pix_cand contributed to
%         the the cut and sorted by grid cell or left unsorted,
%         depending on requested pix_indx output.
%         IF '-return_selected' passed, contains indices of kept pixels
% unique_runid
%      -- if num_outputs >=5, array, containing the unique runids from the
%         pixels, contributed to the cut. If input unique_runid was not
%         empty, output unique_runid is combined with the input unique_runid
%         and contains no duplicates.
% pix_indx
%      -- in num_outputs ==6, contains indices of the grid cells,
%         containing the pixels from input pix_cand. If this parameter is
%         requested, the order of output pix corresponds to the order of
%         pixels in PixelData. if num_outputs<6, output pix are sorted by
%         npix bins.
%
% selected
%      -- in num_outputs == 7, contains indices of kept pixels

pix_ok       = [];
pix_indx     = [];
selected     = [];

num_threads = config_store.instance().get_value('parallel_config','threads');

pax = obj.pax;
if size(coord,1) == 3  % 3D array binning
    data_range = obj.img_range(:,1:3);
    pax = pax(pax~=4);
    ndims = numel(pax);
else
    data_range = obj.img_range(:,1:3);
    ndims = obj.dimensions;
end

other_mex_input = struct( ...
    'coord_in',coord,...                    % input coordinates to bin. May be empty in modes when they are processed from transformed pixel data
    'binning_mode',num_outputs, ...         % binning mode, what binning values to calculate and return
    'num_threads',num_threads,  ...         % how many threads to use in parallel computation
    'data_range',data_range,...             % binning ranges
    'bins_all_dims',obj.nbins_all_dims, ... % size of binning lattice
    'dimensions',ndims, ...                 % number of image dimensions (sum(nbins_all_dims > 1)))
    'unique_runid',unique_runid, ...        % unique run indices of pixels contributing into cut
    'force_double',force_double, ...        % make result double precision regardless of input data
    'test_input_parsing',test_mex_inputs ...% Run mex code in test mode validating the way input have been parsed by mex code and doing no caclculations.
    );
other_mex_input.unique_runid = unique_runid;

is_pix = isa(pix_cand,'PixelDataBase');
if is_pix && return_selected
    other_mex_input.pix_candidates   = pix_cand.get_raw_data;
    other_mex_input.selected = pix_cand.detector_idx>0;  % already selected pixels should be ignored by mex routine
    ndata = 2;
    if pix_cand.is_corrected
        other_mex_input.alignment_matr = pix_cand.alignment_matr;
    else
        other_mex_input.alignment_matr  = [];
    end
else
    other_mex_input.alignment_matr   = [];
    other_mex_input.pix_candidates   = pix_cand;
    other_mex_input.selected         = []; % do not analyse selected pixels
    % cell with data array
    ndata = numel(pix_cand);
end
% routine allocates npix (s,e on request) on first call and keeps ownership
% of these arrays internally. Input npix is not used and serves just as an
% indication that this is the first call to the routine if npix is empty.
[obj.mex_code_holder_,npix, s, e,out_param_names,out_param_values] = bin_pixels_c( ...
    obj.mex_code_holder_,npix_in,other_mex_input);

out_struc = cell2struct(out_param_values,out_param_names);
if test_mex_inputs
    % in this case pix_ok change meaning and contains output data structure
    % directly. The structure itself contains copy of input parameters plus
    % various helper values obtained from input and used during the testing
    pix_ok = out_struc;
    return
else
    %[npix, s, e, pix_ok, unique_runid, pix_indx, selected] = bin_pixels_c(coord,npix,s,e,other_mex_input);
    pix_ok_data  = out_struc.pix_ok_data;
    pix_ok_range = out_struc.pix_ok_range;

    if num_outputs<4 || ~is_pix
        if ndata>=3
            pix_ok = pix_ok_range; % redefine pix_ok_range to be npix accumulated
        end
        return;
    end
    if isempty(pix_ok_data)
        pix_ok = pix_ok_data;
    else
        pix_ok = PixelDataMemory();
        pix_ok = pix_ok.set_raw_data(pix_ok_data);
        pix_ok = pix_ok.set_data_range(pix_ok_range);
    end

    % in modes where these values are not calculated, the code returns 
    % empty 
    unique_runid  = out_struc.unique_runid;
    pix_indx      = out_struc.pix_idx;
    selected      = out_struc.selected;

end

end

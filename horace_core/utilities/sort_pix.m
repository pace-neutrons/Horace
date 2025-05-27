function pix = sort_pix(pix_retained, pix_ix_retained,npix,pix_range,keep_precision)
% function sorts pixels according to their indices in n-D array npix
%
% To do that, it has to load all pixels in memory, so filebacked pixels are
% acceptable as long as they all can be loaded in memory. This is
% relatively weak restriction as pixel indices are already in memory.
%
% It may be renamed sort_pixels_by_bins as the pix_ix_retained are the
% sorting pixels according to array of indices which specify pixel location
% in image bins and the indices of the pixels which place them into
% appropriate bins were processed externally.
%
% This is explicitly memory-only operation which is applied to
% block of pixels pixel in memory or to the part of such image.
%
%input:
% pix_retained --  PixelData object, which is to be sorted or a cell array
%                  containing PixelData objects
%
% pix_ix_retained
%              -- indices of these pixels in n-D array or cell array of
%                 such indices. Number of elements in these arrays have to
%                 coincide with number of pixels in pix_retained cellarray,
%                 and each block of cellarray needs to contain as many
%                 elements as number of pixels in appropriate element of
%                 pix_retained cellarray.
% npix         -- auxiliary array, containing numbers of pixels in each
%                 cell of n-D array. Used only by mex sorting to simplify
%                 memory allocation and allow to lock particular cells in
%                 case of OMP sorting. If not used, should be empty
% Optional input:
% pix_range   -- if provided, prohibits pix range recalculation in pix
%                constructor. The range  provided will be used instead
%
% keep_precision
%             -- if provided and true the routine keeps type of pixels
%                received on input. If not, pixels converted into double.
%
%Output:
%pix  array of pixels sorted into 1D array according to indices provided
%
if nargin<3
    npix = [];
end
if nargin<4
    pix_range=[];
end
if nargin<5
    keep_precision = false;
end
[use_mex,force_mex,use_given_pix_range,data_range] = check_and_get_additional_pars( ...
    pix_range);

if ~iscell(pix_retained)
    pix_retained = {pix_retained};
end
if ~iscell(pix_ix_retained)
    pix_ix_retained = {pix_ix_retained};
end


% Do the job -- sort pixels according to their bin indices.
if use_mex
    try
        %IMPORTANT: use double type as mex code asks for double type, not
        %logical.
        keep_type = double(keep_precision);

        raw_pix = cellfun(@(x)get_pix_page_data(x,keep_precision), pix_retained, ...
            'UniformOutput', false);
        in_memory = cellfun(@(pix)~pix.is_filebacked, pix_retained);
        if ~all(in_memory) % there are filebaced pixels and we need to check
            % if all requested pixels are loaded in memory for correct
            % sorting
            req_part_loaded = cellfun(@(pix,idx)(size(pix,2)==numel(idx)),raw_pix,pix_ix_retained);
            if ~all(req_part_loaded)
                fail_idx = find(~req_part_loaded);
                error('HORACE:sort_pix:invalid_argument',...
                    ['not all requested pixel pages loaded in memory' ...
                    ' as number of pixels do not correspond to number of indices to sort\n' ...
                    ' Invalid data block numbers out of %d blocks are: %s'],...
                    numel(pix_ix_retained),disp2str(fail_idx));
            end
        end
        if isempty(npix)
            % calculate npix distribution to be able to run mex code
            npix = calc_npix_distribution(pix_ix_retained);
        end

        pix = PixelDataBase.create();
        if use_given_pix_range
            raw_pix = sort_pixels_by_bins(raw_pix, pix_ix_retained, ...
                npix,keep_type);
        else
            [raw_pix,data_range_l] = sort_pixels_by_bins(raw_pix, pix_ix_retained, ...
                npix,keep_type);
            data_range = data_range_l;
        end
        pix = pix.set_raw_data(raw_pix);
        pix = pix.set_data_range(data_range);

        clear pix_retained pix_ix_retained;  % clear big arrays

    catch ME
        use_mex=false;
        if get(hor_config,'log_level')>=1
            message=ME.message;
            warning('HORACE:mex_code_problem', ...
                ' C-routines returned error: %s, details: %s \n Trying MATLAB', ...
                ME.identifier,message)
            if force_mex
                rethrow(ME);
            end
        end
    end
end

if ~use_mex
    % drop empty cells if any
    is_empty = cellfun(@isempty,pix_retained);
    pix_retained= pix_retained(~is_empty);
    if isempty(pix_retained)
        pix = PixelDataMemory();
        return;
    end
    if numel(pix_retained) ~= numel(pix_ix_retained)
        pix_ix_retained = pix_ix_retained(~is_empty);
    end

    % combine pixels together. Type may be lost? Should not but form allows. Should we enforce it?
    pix = PixelDataBase.cat(pix_retained{:},'-force_membased');
    pix.keep_precision = keep_precision;
    clear pix_retained;
    if isempty(pix)  % return early if no pixels
        pix = PixelDataMemory();
        return;
    end
    ix = cat(1, pix_ix_retained{:});

    clear pix_ix_retained;
    if issorted(ix)
        return;
    end

    [~,ind] = sort(ix);  % returns ind as the indexing array into pix
    %                      that puts the elements of pix in increasing
    %                      single bin index
    clear ix;      % clear big arrays so that final output variable pix
    %                is not way up the stack

    pix=pix.get_pixels(ind); % reorders pix according to pix indices within bins
    clear ind;
end
%
function npix = calc_npix_distribution(bin_idx)
% calculate distribution of pixels over bins to be able to run mex code
%
% Inputs:
% bin_idx -- cellarray containing indices of pixels in bins
% Returns:
% npix    -- 1D array containing distribution of input indices over the
%            bins
%
max_cell_idx = cellfun(@max,bin_idx);
num_bins     = max(max_cell_idx);
npix         = zeros(num_bins,1);
for i = 1:numel(bin_idx)
    npix = cut_data_from_file_job.calc_npix_distribution(bin_idx{i},npix);
end

%
function data = get_pix_page_data(pix,keep_precision)
% get current pixel data page keeping pixels precision on request
pix.keep_precision = keep_precision;
data = pix.data;

function [use_mex,force_mex,use_given_pix_range,data_range] = check_and_get_additional_pars(pix_range)
% checks validity of additional arguments and if data_range is provided as
% additional parameter.

[use_mex,force_mex] = config_store.instance().get_value('hor_config','use_mex','force_mex_if_use_mex');

use_given_pix_range = ~isempty(pix_range);

if use_given_pix_range
    data_range = pix_range;
    if ~isequal(size(data_range), [2,9])
        error('HORACE:sort_pix:invalid_argument',...
            'if data_range is provided, it has to be 2x9 array. Actually its size is: %s',...
            disp2str(size(data_range)))
    end
else
    data_range = [];
end

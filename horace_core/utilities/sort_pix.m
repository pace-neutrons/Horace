function pix = sort_pix(pix_retained, pix_ix_retained, npix, varargin)
% function sorts pixels according to their indices in n-D array npix
%
%input:
% pix_retained   PixelData object, which is to be sorted or a cell array
%       containing arrays of PixelData objects
%
% ix    indices of these pixels in n-D array or cell array of such indices
% npix  auxiliary array, containing numbers of pixels in each cell of
%       n-D array
% Optional input:
%  pix_range -- if provided, prohibits pix range recalculation in pix
%               constructor. The range  provided will be used instead
%
% '-nomex'    -- do not use mex code even if its available
%               (usually for testing)
%
% '-force_mex' -- use only mex code and fail if mex is not available
%                (usually for testing)
% '-force_double'
%              -- if provided, the routine changes type of pixels
%                 it get on input, into double. if not, output pixels will
%                 keep their initial type
%
% these two options can not be used together.
%

%Output:
%pix  array of pixels sorted into 1D array according to indices provided
%

%  Process inputs
options = {'-nomex','-force_mex','-force_double'};
%[ok,mess,nomex,force_mex,missing]=parse_char_options(varargin,options);
[ok, mess, nomex, force_mex, force_double, argi] = ...
    parse_char_options(varargin,options);

if ~ok
    error('HORACE:utilities:invalid_argument', ...
        ['sort_pixels: invalid argument',mess])
end

if nomex && force_mex
    error('HORACE:utilities:invalid_argument', ...
        'sort_pixels: invalid argument -- nomex and force mex options can not be used together' )
end

use_given_pix_range = ~isempty(argi);

if use_given_pix_range
    data_range = argi{:};
    if ~isequal(size(data_range), [2,9])
        error('HORACE:sort_pix:invalid_argument',...
            'if data_range is provided, it has to be 2x9 array. Actually its size is: %s',...
            disp2str(size(data_range)))
    end
end

if ~iscell(pix_retained)
    pix_retained = {pix_retained};
end
if ~iscell(pix_ix_retained)
    pix_ix_retained = {pix_ix_retained};
end

% Don't use mex with file-backed
% TODO Make mex available to file-backed
use_mex = ~pix_retained{1}.is_filebacked && ...
          force_mex || ...
          (exist('npix', 'var') && ...
           ~isempty(npix) && ...
           ~nomex && ...
           get(hor_config, 'use_mex'));

%
% Do the job -- sort pixels
%
if use_mex
    try
        % TODO: make "keep type" a default behaviour!
        % function retrieves keep_type variable value from this file
        % so returns double or single resolution pixels depending on this
        %IMPORTANT: use double type as mex code asks for double type, not
        %logical.
        keep_type = double(force_double);

        raw_pix = cellfun(@(pix_data) pix_data.data, pix_retained, ...
            'UniformOutput', false);
        pix = PixelDataBase.create();
        if use_given_pix_range
            raw_pix = sort_pixels_by_bins(raw_pix, pix_ix_retained, ...
                npix,keep_type);
            pix = pix.set_raw_data(raw_pix);
            pix = pix.set_data_range(data_range);
        else
            [raw_pix,data_range_l] = sort_pixels_by_bins(raw_pix, pix_ix_retained, ...
                npix,keep_type);
            pix = pix.set_raw_data(raw_pix);
            pix = pix.set_data_range(data_range_l);
        end
        clear pix_retained pix_ix_retained;  % clear big arrays

    catch ME
        use_mex=false;
        if get(hor_config,'log_level')>=1
            message=ME.message;
            warning('HORACE:mex_code_problem', ...
                ' C-routines returned error: %s, details: %s \n Trying Matlab', ...
                ME.identifier,message)
            if force_mex
                rethrow(ME);
            end
        end
    end
end

if ~use_mex
    ix = cat(1, pix_ix_retained{:});

    clear pix_ix_retained;

    if issorted(ix)
        pix = pix_retained{1};
        return;
    end

    [~,ind] = sort(ix);  % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
    clear ix;          % clear big arrays so that final output variable pix is not way up the stack

    % maintain type of pix
    pix = pix_retained{1}.cat(pix_retained{:});
    clear pix_retained;
    if isempty(pix)  % return early if no pixels
        pix = PixelDataMemory();
        return;
    end

    if pix.is_filebacked
        mch_sz = get(hor_config, 'mem_chunk_size');

        pix = pix.get_new_handle();

        for i = 1:mch_sz:numel(ind)
            end_idx = min(i+mch_sz-1, numel(ind));
            slice = ind(i:end_idx);
            data = pix.get_fields('all', slice);
            pix.format_dump_data(data);
        end

        pix = pix.finalise(numel(ind));

    else
        pix=pix.get_pixels(ind); % reorders pix according to pix indices within bins
    end
    clear ind;
end

end

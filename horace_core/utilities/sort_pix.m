function   pix = sort_pix(pix_retained,pix_ix_retained,npix,varargin)
% function sorts pixels according to their indexes in n-D array npix
%
%input:
% pix_retained   PixelData object, which is to be sorted or a cell array
%       containing arrays of PixelData objects
%
% ix    indexes of these pixels in n-D array or cell array of such indexes
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
%pix  array of pixels sorted into 1D array according to indexes provided
%
%
%
%

%  Process inputs
options = {'-nomex','-force_mex','-force_double'};
%[ok,mess,nomex,force_mex,missing]=parse_char_options(varargin,options);
[ok,mess,nomex,force_mex,force_double,argi]=parse_char_options(varargin,options);
if ~ok
    error('HORACE:utilities:invalid_argument', ...
        ['sort_pixels: invalid argument',mess])
end
if nomex && force_mex
    error('HORACE:utilities:invalid_argument', ...
        'sort_pixels: invalid argument -- nomex and force mex options can not be used together' )
end
if isempty(argi)
    use_given_pix_range = false;
else
    use_given_pix_range =true;
    pix_range = argi{:};
    if any(size(pix_range) ~= [2,4])
        error('HORACE:utilities:invalid_argument',...
            'if pix_range is provided, it has to be 2x4 array. Actually its size is: %',...
            evalc('disp(size(pix_range))'))
    end
end

if ~iscell(pix_retained)
    pix_retained = {pix_retained};
end
if ~iscell(pix_ix_retained)
    pix_ix_retained = {pix_ix_retained};
end
if nomex
    use_mex = false;
else
    use_mex=get(hor_config,'use_mex');
end
if ~exist('npix','var') || isempty(npix)
    use_mex=false;
end
if force_mex
    use_mex = true;
end
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
        if force_double % keep_type is extracted by sort_pix_by_bins routine
            keep_type = 0; %
        else
            keep_type = 1;
        end
        raw_pix = cellfun(@(pix_data) pix_data.data, pix_retained, ...
            'UniformOutput', false);
        pix = PixelDataBase.create();
        if use_given_pix_range
            raw_pix = sort_pixels_by_bins(raw_pix, pix_ix_retained, ...
                npix,keep_type);
            pix.set_data('all',raw_pix);
            pix.set_range(pix_range);
        else
            [raw_pix,pix_range_l] = sort_pixels_by_bins(raw_pix, pix_ix_retained, ...
                npix,keep_type);
            pix.set_data('all',raw_pix);
            pix.set_range(pix_range_l);
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
    if numel(pix_ix_retained) == 1
        ix = pix_ix_retained{1};
    else
        ix = cat(1,pix_ix_retained{:});
    end
    clear pix_ix_retained;
    [~,ind]=sort(ix);  % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
    clear ix ;          % clear big arrays so that final output variable pix is not way up the stack
    if numel(pix_retained) == 1
        pix = pix_retained{1};
    else
        pix = PixelDataBase.cat(pix_retained{:});
    end
    clear pix_retained;
    if isempty(pix)  % return early if no pixels
        pix = PixelDataBase.create();
        return;
    end

    pix=pix.get_pixels(ind); % reorders pix according to pix indexes within bins
    clear ind;
    if force_double
        if ~isa(pix.data,'double')
            pix = PixelDataBase.create(double(pix.data));
        end
    end
end

function   pix = sort_pixels(pix_retained,pix_ix_retained,npix,varargin)
% function sorts pixels according to their indexes in n-D array npix
%
%input:
% pix_retained   9xNpix array of pixels, which have to be sorted or sell array
%       containing arrys of such pixels
%
% ix    indexes of these pixels in n-D array or cell array of such indexes
% npix  auxiliary array, containing numbers of pixels in each cell of
%       n-D array
% Optional input:
%
% '-nomex'    -- do not use mex code even if its availible
%               (usually for testing)
%
% '-force_mex' -- use only mex code and fail if mex is not availible
%              (usually for testing)
% these two options can not be used together.
%

%Output:
%pix  array of pixels sorted into 1D array according to indexes provided
%
%
% $Revision: 1036 $ ($Date: 2015-07-29 19:09:38 +0100 (Wed, 29 Jul 2015) $)
%

%  Process inputs
options = {'-nomex','-force_mex'};
%[ok,mess,nomex,force_mex,missing]=parse_char_options(varargin,options);
[ok,mess,nomex,force_mex]=parse_char_options(varargin,options);
if ~ok
    error('SORT_PIXELS:invalid_argument',['sort_pixels: invalid argument',mess])
end
if nomex && force_mex
    error('SORT_PIXELS:invalid_argument','sort_pixels: invalid argument -- nomex and force mex options can not be used together' )
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
        pix = sort_pixels_by_bins(pix_retained,pix_ix_retained,npix);
        %pix = sort_pixels_by_bins(pix_retained,pix_ix_retained);
        clear pix_retained pix_ix_retained;  % clear big arrays
    catch
        use_mex=false;
        if horace_info_level>=1
            message=lasterr();
            warning(' Can not sort_pixels_by_bins using c-routines, reason: %s \n trying Matlab',message)
            if force_mex
                error('SORT_PIXELS:c_code_fail','sort_pixels: can not use mex code but force mex requested')
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
    % TODO: make single!
    if numel(pix_retained) == 1
        pix = double(pix_retained{1});
    else
        pix = double(cat(2,pix_retained{:}));
    end
    clear pix_retained;
    pix=pix(:,ind);     % reorders pix
    clear ind;
end




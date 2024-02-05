function wout = replicate (win, wref,varargin)
% Make a higher dimensional dataset from a lower dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
%   >> wout = replicate (win, wref)
%
% Input:
% ------
%   win     Low dimensional dataset of datasets. The signal, error
%           and npix arrays of this object will be replicated over the
%           extra dimensions of the reference dataset.
%
%   wref    Reference dataset structure to use as template for expanding the
%           input straucture. Can be a dnd or sqw dataset.
%           - The plot axes of win must also be plot axes of wref, and the number
%           of points along these common axes must be the same, although the
%           numerical values of the coordinates need not be the same.
%           - The data is expanded along the plot axes of wref that are
%           integration axes of win.
%           - The annotations etc. are taken from the reference dataset.
% Optional:
% '-set_pix' -- if provided, wref object should be sqw objects with pixels.
%               in this case result would be sqw object(s) with pixels set
%               to reprouce replicated image, defined by input dnd object.
%
% Output:
% -------
%   wout    Output dataset object (or array of objects). It is dnd object
%           with the same dimensionality as wref or sqw object with the
%           same dimensionality as input dnd object and
%
% Original author: T.G.Perring
%

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type: ensure call is with dnd-type sqw object as first argument, sqw object as second
% Note that the second argument cannot be an sqw object, as otherwise the sqw replicate method would have been
% called, because the sqw class has been defined as superior to dnd classes.

if ~(isscalar(wref) && isa(wref,'SQWDnDBase'))
    error('HORACE:replicate:invalid_argument',...
        'The second argument must be a scalar dnd or sqw object, actually it has %d elements and its type is %s',...
        numel(wref),class(wref));
end

[ok,mess,set_pix] = parse_char_options(varargin,'-set_pix');
if ~ok
    error('HORACE:sqw:invalid_argument',mess);
end
if isa(wref,'sqw')
    if set_pix
        if wref.has_pixels
            wout = replicate(sqw(win),wref,'-set_pix');
        else
            warning('HORACE:invalid_argument', ...
                '-set_pix key is provided as input of replicate(dnd,sqw_ref_object,"-set_pix"), but sqw_ref_object does not contain pixels')
            wout=replicate_dnd_(win,wref.data);
        end
    else
        wout=replicate_dnd_(win,wref.data);
    end
elseif isa(wref,'DnDBase')
    if set_pix
        warning('HORACE:invalid_argument', ...
            '-set_pix key is provided as input of replicate(dnd,sqw_ref_object,"-set_pix"), but sqw_ref_object is dnd object')
    end
    wout=replicate_dnd_(win,wref);
end

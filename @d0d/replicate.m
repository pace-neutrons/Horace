function wout = replicate (win, wref)
% Make a higher dimensional dataset from a zero dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
%   >> wout = replicate (win, wref)
%
% Input:
% ------
%   win     Zero dimensional dataset or array of datasets. The signal, error
%           and npix arrays will be replicated over the extra dimensions of
%           the reference dataset.
%
%   wref    Reference dataset structure to use as template for expanding the
%           input straucture. Can be a dnd or sqw dataset.
%           - The data is expanded along the plot axes of wref that are
%           integration axes of win.
%           - The annotations etc. are taken from the reference dataset.
%
% Output:
% -------
%   wout    Output dataset object (or array of objects). It is dnd object
%           with the same dimensionality as wref.


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type: ensure call is with dnd-type sqw object as first argument, sqw object as second
% Note that the second argument cannot be an sqw object, as otherwise the sqw replicate method would have been
% called, because the sqw class has been defined as superior to dnd classes.

if isa(win,classname)
    if isscalar(wref) && (isa(wref,'d0d')||isa(wref,'d1d')||isa(wref,'d2d')||isa(wref,'d3d')||isa(wref,'d4d'))
        wout=replicate(sqw(win),sqw(wref));
    else
        error('Check input argument type - the second argument must be a scalar dnd object')
    end
else
    error(['Check input argument types - the first argument must be a ',classname,' object or array of objects'])
end

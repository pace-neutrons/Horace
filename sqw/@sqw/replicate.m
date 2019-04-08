function wout = replicate (win,wref)
% Make a higher dimensional dataset from a two dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
%   >> wout = replicate (win, wref)
%
% Input:
% ------
%   win     sqw object or array of sqw objects all with the same dimensionality
%           to be replicated. The signal and npix array will be
%           replicated  over the extra dimensions of the reference dataset,
%           but not the individual pixels.
%
%   wref    Reference dataset structure to use as template for expanding the
%           input straucture. Can be a dnd or sqw dataset.
%           - The plot axes of win must also be plot axes of wref, and the number
%           of points along these common axes must be the same, although the
%           numerical values of the coordinates need not be the same.
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
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)


% Do some tests on win and wref
% -----------------------------
% If came from replicate method of a dnd class, then win will be dnd-type sqw object
% Otherwise, could be any sort of object, so check it is an sqw or dnd object
if isa(win,'sqw')
    ndim=dimensions(win(1));
    for i=2:numel(win)
        if dimensions(win(i))~=ndim
            error('Check first input argument - an array of sqw objects must all have the same dimensionality')
        end
    end
elseif ~(isa(win,'d0d')||isa(win,'d1d')||isa(win,'d2d')||isa(win,'d3d')||isa(win,'d4d'))
    error('Check input argument types - the first argument must be a dnd or sqw object (scalar or array)')
end

% If came from replicate method of a dnd class, then wref will be dnd-type sqw object
% Otherwise, could be any sort of object, so check it is an sqw or dnd object, and convert to dnd-type sqw object
if isscalar(wref) && isa(wref,'sqw')
    if is_sqw_type(wref)
        wref_dnd_type=sqw(dnd(wref));
    else
        wref_dnd_type=wref;
    end
elseif isscalar(wref) && (isa(wref,'d0d')||isa(wref,'d1d')||isa(wref,'d2d')||isa(wref,'d3d')||isa(wref,'d4d'))
    wref_dnd_type=sqw(wref);
else
    error('Check input argument types - the second argument must be a scalar dnd or sqw object')
end


% Perform replication
% -------------------
wout = repmat(wref_dnd_type,size(win));  % wout will be a dnd-type sqw object
if isa(win,'sqw')
    for i=1:numel(win)
        wout(i).data = replicate_dnd(win(i).data,wref_dnd_type.data);
    end
else
    for i=1:numel(win)
        tmp=sqw(win(i));
        wout(i).data = replicate_dnd(tmp.data,wref_dnd_type.data);
    end
end

% Convert to dnd object
wout=dnd(wout);

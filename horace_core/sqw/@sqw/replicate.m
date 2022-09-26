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
%
% Original author: T.G.Perring
%

% Do some tests on win and wref
% -----------------------------
% If came from replicate method of a dnd class, then win will be dnd-type sqw object
% Otherwise, could be any sort of object, so check it is an sqw or dnd object

ndim=dimensions(win(1));
for i=2:numel(win)
    if dimensions(win(i))~=ndim
        error('HORACE:replicate:invalid_argument',...
            'Check first input argument - an array of sqw objects must all have the same dimensionality')
    end
end

% If came from replicate method of a dnd class, then wref will be dnd-type sqw object
% Otherwise, could be any sort of object, so check it is an sqw or dnd object, and convert to dnd-type sqw object
if isscalar(wref) && isa(wref,'sqw')
    wref_dnd_type=dnd(wref);
elseif isscalar(wref) && isa(wref,'DnDBase')
    wref_dnd_type=wref;
else
    error('HORACE:replicate:invalid_argument',...
        'The second argument must be a scalar dnd or sqw object, actually it has %d elements and its type is %s',...
        numel(wref),class(wref));
end


% Perform replication
% -------------------
wout = repmat(wref_dnd_type,size(win));  % wout will be a dnd-type sqw object

for i=1:numel(win)
    dnd_obj = dnd(win(i));
    rep_obj = replicate(dnd_obj,wref_dnd_type);
    wout(i) = rep_obj;
    %     % TODO: what about pixels? Should we replicate target pixels too to
    %     % have fully consistent target sqw object (if target is sqw) with whole
    %     % pixel informathion
    %     wout(i).main_header = win(i).main_header;
    %     wout(i).header = win(i).header;
    %     wout(i).runid_map = win(i).runid_map;
    %     wout(i).detpar    = win(i).detpar;
end

% Already DND object. Should it be SQW?
%wout=dnd(wout);


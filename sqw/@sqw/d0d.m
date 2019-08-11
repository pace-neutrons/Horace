function wout = d0d (win)
% Convert input 0-dimensional sqw object into corresponding d0d object
%
%   >> wout = d0d (win)

% Special case of dnd included for completeness

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


ndim_req=0;     % required dimensionality

% The code below is identical for all dnd type converter routines
for i=1:numel(win)
    if dimensions(win(i))~=ndim_req
        if numel(win)==1
            error('sqw object is not two dimensional')
        else
            error('Not all elements in the array of sqw objects are two dimensional')
        end
    end
end

wout=dnd(win);  % calls sqw method for generic dnd conversion

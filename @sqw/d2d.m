function wout = d2d (win)
% Convert input 2-dimensional sqw object or array of 2D sqw objects into d2d object or d2d object array
%
%   >> wout = d2d (win)

% Special case of dnd included for completeness

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


ndim_req=2;     % required dimensionality

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

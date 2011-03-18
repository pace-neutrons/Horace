function x = sigvar_getx (w)
% Get x values from object. Size match output of sigvar_get
% 
%   >> x = sigvar_get (w)
%
%   x   cellarray of x and y values to match the order of elements in
%   signal and error arrays

% Original author: T.G.Perring

if size(w.signal,1)~=numel(w.x)
    x = 0.5*(w.x(2:end)+w.x(1:end-1));
else
    x = w.x;
end

if size(w.signal,2)~=numel(w.y)
    y = 0.5*(w.y(2:end)+w.y(1:end-1));
else
    y = w.y;
end

x = ndgridcell({x,y});

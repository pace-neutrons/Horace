function x = sigvar_getx (w)
% Get x values from object. Size match output of sigvar_get
% 
%   >> x = sigvar_get (w)
%
%   x   cellarray of x, y an z values to match the order of elements in
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

if size(w.signal,3)~=numel(w.z)
    z = 0.5*(w.z(2:end)+w.z(1:end-1));
else
    z = w.z;
end

x = ndgridcell({x,y,z});

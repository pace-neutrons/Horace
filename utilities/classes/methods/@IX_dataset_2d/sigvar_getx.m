function x = sigvar_getx (w)
% Get x values from object. Size match output of sigvar_get
% 
%   >> x = sigvar_get (w)
%
%   x   cellarray of x and y values to match the order of elements in
%   signal and error arrays

% Original author: T.G.Perring

x = ndgridcell({w.x,w.y});

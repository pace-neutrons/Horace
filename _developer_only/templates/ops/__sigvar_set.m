function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring

w.s=sigvarobj.s;
w.e=sigvarobj.e;

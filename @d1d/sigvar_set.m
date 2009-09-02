function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

w.s=sigvarobj.s;
w.e=sigvarobj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.npix==0);
w.s(nopix)=0;
w.e(nopix)=0;

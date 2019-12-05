function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

if ~isequal(size(w.s),size(sigvarobj.s))
    error('d2d object and sigvar object have inconsistent sizes')
end

w.s=sigvarobj.s;
w.e=sigvarobj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.npix==0);
w.s(nopix)=0;
w.e(nopix)=0;


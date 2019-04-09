function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

if ~isequal(size(w.s),size(sigvarobj.s))
    error('d0d object and sigvar object have inconsistent sizes')
end

w.s=sigvarobj.s;
w.e=sigvarobj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.npix==0);
w.s(nopix)=0;
w.e(nopix)=0;

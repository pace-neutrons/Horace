function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

w.data.s=sigvarobj.s;
w.data.e=sigvarobj.e;
stmp = replicate_array(w.data.s, w.data.npix)';
etmp = replicate_array(w.data.e, w.data.npix)';
wout.data.pix(8:9,:) = [stmp;etmp]; % propagate signal into the pixel data

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.data.npix==0);
w.data.s(nopix)=0;
w.data.e(nopix)=0;

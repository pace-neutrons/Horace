function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if ~isequal(size(w.data.s),size(sigvarobj.s))
    error('sqw object and sigvar object have inconsistent sizes')
end

w.data.s=sigvarobj.s;
w.data.e=sigvarobj.e;
stmp = replicate_array(w.data.s, w.data.npix)';
etmp = replicate_array(w.data.e, w.data.npix)';

%======
%RAE edit 8/12/2010: logical inconsistency previously here. Consider the
%case of adding two dnd-type sqw objects. The output created here will have
%a pix array. Normally this does not matter, but it does matter for e.g.
%fit_func on a dnd object.
if is_sqw_type(w)
    w.data.pix(8:9,:) = [stmp;etmp]; % propagate signal into the pixel data
end
%=====

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.data.npix==0);
w.data.s(nopix)=0;
w.data.e(nopix)=0;

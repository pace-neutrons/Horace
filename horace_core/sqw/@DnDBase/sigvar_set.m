function w = sigvar_set(win, sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvarobj)

if ~isequal(size(win.s),size(sigvarobj.s))
    error([upper(class(win)) ':sigvar_set'], ...
        [class(win) ' object and sigvar object have inconsistent sizes']);
end

w = win;

w.s = sigvarobj.s;
w.e = sigvarobj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix = (w.npix==0);
w.s(nopix)=0;
w.e(nopix)=0;

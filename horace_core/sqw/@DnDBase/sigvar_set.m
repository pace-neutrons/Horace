function w = sigvar_set(win, sigvar_obj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvarobj)

if ~isequal(size(win.s),size(sigvar_obj.s))
    error([upper(class(win)) ':sigvar_set'], ...
        [class(win) ' object and sigvar object have inconsistent sizes: [%s] and [%s]'], ...
        num2str(size(win.s)), num2str(size(sigvar_obj.s)));
end

w = win;

w.s = sigvar_obj.s;
w.e = sigvar_obj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix = (w.npix==0);
w.s(nopix)=0;
w.e(nopix)=0;

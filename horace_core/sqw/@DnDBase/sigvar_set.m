function w = sigvar_set(win, sigvar_obj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvarobj)

if ~isequal(size(win.s), size(sigvar_obj.s))
    error(['HORACE:',class(win) ':invalid_argument'], ...
        '%s object and sigvar object signal have inconsistent sizes: [%s] and [%s]', ...
        class(win) ,num2str(size(win.s)), num2str(size(sigvar_obj.s)));
end

if ~isequal(size(win.e), size(sigvar_obj.e))
    error(['HORACE:',class(win) ':invalid_argument'], ...
        '%s object and sigvar object variance have inconsistent sizes: [%s] and [%s]', ...
        class(win) ,num2str(size(win.e)), num2str(size(sigvar_obj.e)));
end

w = win;

w.s_ = sigvar_obj.s;
w.e_ = sigvar_obj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix = (w.npix_==0);
w.s_(nopix)=0;
w.e_(nopix)=0;

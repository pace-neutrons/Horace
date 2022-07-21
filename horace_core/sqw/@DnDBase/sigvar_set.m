function w = sigvar_set(win, sigvar_obj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvarobj)


w = win;
w.do_check_combo_arg = false;
w.s = sigvar_obj.s;
w.e = sigvar_obj.e;

% If no pixels, then our convention is that signal and error set to zero
nopix = (w.npix_==0);
w.s_(nopix)=0;
w.e_(nopix)=0;
%
w.do_check_combo_arg = true;

w = w.check_combo_arg();

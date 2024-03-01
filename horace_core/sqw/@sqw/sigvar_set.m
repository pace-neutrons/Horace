function w = sigvar_set(win, sigvar_obj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvar_obj)


w = copy(win);
w.data = sigvar_set(win.data,sigvar_obj);
if has_pixels(w)     % RAE spotted error 8/12/2010: should only create pix field if sqw object
    page_op = PageOp_sigvar_set();
    page_op = page_op.init(w);
    w       = sqw.apply_op(w,page_op);
end


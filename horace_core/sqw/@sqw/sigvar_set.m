function w = sigvar_set(win, sigvar_obj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvar_obj)


w = copy(win);
w.data = sigvar_set(win.data,sigvar_obj);

if has_pixels(w)
    % RAE spotted error 8/12/2010: should only create pix field if sqw object
    stmp = replicate_array(w.data.s, w.data.npix)';
    etmp = replicate_array(w.data.e, w.data.npix)';
    w.pix.signal   = stmp;  % propagate signal into the pixel data
    w.pix.variance = etmp;
end


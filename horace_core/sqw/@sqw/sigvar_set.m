function w = sigvar_set(win, sigvar_obj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(win, sigvar_obj)

if ~isequal(size(win.data.s), size(sigvar_obj.s))
    error('SQW:sigvar_set', ...
        'sqw object and sigvar object have inconsistent sizes: [%s] and [%s]', ...
        num2str(size(win.data.s)), num2str(size(sigvar_obj.s)));
end

w = win;

w.data.s = sigvar_obj.s;
w.data.e = sigvar_obj.e;

if ~isempty(w.data.pix)
    % RAE spotted error 8/12/2010: should only create pix field if sqw object
    stmp = replicate_array(w.data.s, w.data.npix)';
    etmp = replicate_array(w.data.e, w.data.npix)';
    w.data.pix.signal = stmp;  % propagate signal into the pixel data
    w.data.pix.variance = etmp;
end

% If no pixels, then our convention is that signal and error set to zero
nopix=(w.data.npix==0);
w.data.s(nopix)=0;
w.data.e(nopix)=0;


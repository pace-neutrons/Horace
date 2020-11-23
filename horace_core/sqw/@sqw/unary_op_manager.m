function wout = unary_op_manager(w, unary_op)
% Implement unary arithmetic operations for objects containing a signal and variance arrays.

% Generic method edited for sqw class. Must have
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)
%   (3) have private function that returns class name
%           >> name = classname     % no argument - gets called by its association with the class

wout = w;
for i=1:numel(w)
    if has_pixels(w(i))
        wout(i).data.pix = w(i).data.pix.do_unary_op(unary_op);
        wout(i) = recompute_bin_data(wout(i));
    else
        result = unary_op(sigvar(w(i).data.s, w(i).data.e));
        wout(i) = sigvar_set(wout(i), result);
    end
end

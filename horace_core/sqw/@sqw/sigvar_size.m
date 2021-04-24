function sz = sigvar_size(w)
% Find size of signal array in sqw object
%
%   >> sz = sigvar_size (w)

sz = size(w.data.s);

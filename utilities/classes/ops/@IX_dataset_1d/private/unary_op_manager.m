function w = unary_op_manager (w1, unary_op)
% Implement unary arithmetic operations for objects containing a signal and variance arrays.
 
% Generic method for binary operations on classes that
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)
%   (3) have private function that returns class name
%           >> name = classname     % no argument - gets called by its association with the class

% Original author: T.G.Perring


w = w1;
for i=1:numel(w1)
    result = unary_op(sigvar(w1(i)));
    w(i) = sigvar_set(w(i),result);
end

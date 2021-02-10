function w = unary_op_manager (w1, unary_op)
% Apply a unary to an objects containing signal and variance arrays.
%
%   >> w = unary_op_manager (w1, unary_op)
%
% Input:
% ------
%   w1          Input object on which to apply the unary operator
%
% Output:
% -------
%   unary_op    Function handle to the unary operator
 
% Generic method for binary operations on classes that
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)
%   (3) have private function that returns class name
%           >> name = classname     % no argument - gets called by its association with the class

% The class of object on which the unary operator is to be applied must
% have the following methods:
%   sigvar      Construct a sigvar object
%   sigvar_set  
%


% Original author: T.G.Perring


w = repmat(sigvar2,size(w1));
for i=1:numel(w1)
    w(i) = unary_op(w1(i));
end

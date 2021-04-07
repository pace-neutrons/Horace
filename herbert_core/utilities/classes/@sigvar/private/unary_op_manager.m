function w = unary_op_manager (w1, unary_op)
% Apply a unary operation for objects containing signal and variance arrays.
%
%   >> w = unary_op_manager (w1, unary_op)
%
% Input:
% ------
%   w1          Input object or array of objects on which to apply the
%               unary operator
%
% Output:
% -------
%   unary_op    Function handle to the unary operator


% NOTES:
% Gives the generic behaviour for unary operation for any class, but may
% need modification of the actual unary operation calculation depending on
% the details of the class internal complexity.
%
% Requires that objects have the following methods to find the size of the
% public signal and variance arrays, create a sigvar object from those
% arrays, and set them from another sigvar object.
%
%	>> sz = sigvar_size(obj)    % Returns size of public signal and variance
%                               % arrays
%	>> w = sigvar(obj)          % Create a sigvar object from the public
%                               % signal and variance arrays
%	>> obj = sigvar_set(obj,w)  % Set signal and variance in an object from
%                               % those in a sigvar object


w = w1;
for i=1:numel(w1)
    result = unary_op(sigvar(w1(i)));
    w(i) = sigvar_set(w(i),result);
end

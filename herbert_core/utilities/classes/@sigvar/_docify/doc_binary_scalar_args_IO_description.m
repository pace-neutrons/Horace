% -----------------------------------------------------------------------------
% <#doc_def:>
%   list_operator_arg = '#1'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
% Input:
% ------
%   w1, w2      Objects on which the binary operation is to be performed.
%               One of these can be a Matlab double (i.e. double precision)
%               array, in which case the variance array is taken to be zero.
%
%               If w1, w2 are scalar objects with the same signal array sizes:
%               - The operation is performed element-by-element.
%
%               If one of w1 or w2 is a double array (and the other is a
%               scalar object):
%               - If a scalar, apply to each element of the object signal.
%               - If it is an array of the same size as the object signal
%                 array, apply the operation element by element.
%
% <list_operator_arg:>
%   binary_op   Function handle to a binary operation. All binary operations
%               on Matlab double or single arrays are permitted (+, -, *,
%               /, \)
%
% <list_operator_arg/end:>
% Output:
% -------
%   w           Output object or array of objects.
% <#doc_end:>
% -----------------------------------------------------------------------------

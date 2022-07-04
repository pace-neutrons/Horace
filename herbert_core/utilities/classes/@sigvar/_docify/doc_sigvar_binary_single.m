% Implement w1 <func_operator> w2 for objects
%
%   >> w = <func_name>_single(w1, w2)
%
% Input:
% ------
%   w1, w2      Scalar sigvar objects:
%               - signal arrays are the same size
%               - one of sigvar objects has a scalar signal array
%
% Output:
% -------
%   w           Output sigvar object.
%               - signal array the same size as the input objects if they
%                 both had the same size
%               - signal array the same size as the sigvar object with the
%                 larger number of elements if one was a scalar

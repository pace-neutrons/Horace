function w = mrdivide (w1, w2)
% Implements w1 / w2 for objects
%
%   >> w = w1 / w2
%
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
%               If one or both of w1 and w2 are arrays of objects:
%               - If objects have same array sizes, the binary operation is
%                applied object element-by-object element.
%               - If one of the objects is scalar (i.e. only one object),
%                then it is applied by the binary operation to each object
%                in the other array.
%
%               If one of w1, w2 is an array of objects and the other is a
%               double array:
%               - If the double is a scalar, it is applied to every object
%                in the array.
%               - If the double is an array with the same size as the object
%                array, then each element is applied as a scalar to the
%                corresponding object in the object array.
%               - If the double is an array with larger size than the object
%                array, then the array is resolved into a stack of arrays,
%                where the stack has the same size as the object array, and
%                the each array in the stack is applied to the corresponding
%                object in the object array. [Note that for this operation
%                to be valid, each object must have the same signal array
%                size.]
%
% Output:
% -------
%   w           Output object or array of objects.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_binary_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_binary_general_args_IO_description.m')
%
%   list_operator_arg = 0
%   func_operator = '/'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
%
%   <#file:> <doc_file_IO> <list_operator_arg>
% <#doc_end:>
% -----------------------------------------------------------------------------

w = binary_op_manager(w1,w2,@mrdivide);

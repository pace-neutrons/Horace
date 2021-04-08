function w = binary_op_manager (w1, w2, binary_op)
% Implement a binary operation for objects with a signal and a variance array.
%
%   >> wout = binary_op_manager(w1, w2, binary_op)
%
% All binary operations on Matlab double or single arrays are permitted
% (+, -, *, /, \) and are applied element by element to the signal and
% variance arrays.
%
% Input:
% ------
%   w1, w2      Objects on which the binary operation is to be performed.
%               One of these can be a real (i.e. double or single precision)
%               array, in which case the variance array is taken to be zero.
%
%               If w1, w2 are scalar objects with the same signal array sizes:
%               - The operation is performed element-by-element.
%
%               If one of w1 or w2 is a real array (the other a scalar object):
%               - If a scalar, apply to each element of the object signal.
%               - If an array of the same size as the object signal array,
%                 apply element by element.
%
%               If one or both of w1, w2 are arrays of objects:
%               - If objects have same array sizes, the binary operation is
%                applied object element-by-object element.
%               - If one of the objects is scalar (i.e. only one object),
%                then it is applied by the binary operation to each object
%                in the other array.
%
%               If one of w1, w2 is an array of objects and the other is a
%               real array:
%               - If the real is a scalar, it is applied to every object in
%                the array.
%               - If the real is an array with the same size as the object
%                array, then each element is applied as a scalar to the 
%                corresponding object in the object array.
%               - If the real is an array with larger size than the object
%                array, then the array is resolved into a stack of arrays,
%                where the stack has the same size as the object array, and
%                the each array in the stack is applied to the corresponding
%                object in the object array. [Note that for this operation
%                to be valid, each object must have the same signal array
%                size.]
%
%   binary_op   Function handle to binary operation. All binary operations
%               on Matlab double or single arrays are permitted (+, -, *,
%               /, \)
%
% Output:
% -------
%   wout        Output object. Assumed to have same class as the superior
%               of the two input objects.


% NOTES:
% This is a generic method - works for any class (including sigvar)
% so long as the methods below are defined on that class.
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


% Get array sizes of the input arguments
% ---------------------------------------
% One of w1 or w2 must be of the class type, because otherwise the method
% would not have been called.
% The dominant class is also this class type, for the same reason.
%
% Think of a numeric array as a stack of objects, each one a smaller array

thisClassname = mfilename('class');

if isobject(w1)
    % w1 is not an intrinsic matlab class
    outputClassname = class(w1);
    size_stack1 = size(w1);
    size_root1 = [1,1];
    
elseif isfloat(w1)
    % w1 is a float array; w2 must have class 'classname'
    if ~isscalar(w1)
        size_stack1 = size(w2);
        [size_root1, ok] = size_array_split (size(w1), size(w2));
        if ~ok
            mess = ['Unable to resolve the numeric array into a stack of arrays, ',...
                'with stack size matching the object array size '];
            error([upper(thisClassname),':binary_op_manager'], mess);
        end
    else
        size_stack1 = [1,1];    % want the scalar to apply to each object in w2
        size_root1 = [1,1];
    end
else
    % Error state: w1 is a matlab intrinsic class but not a float
    % (e.g.  logical, character, cell array)
    error([upper(thisClassname),':binary_op_manager'], ...
        ['Invalid first argument to binary operation - ' ...
        'it must be an object, or a float (i.e. double or single precision).'])
end


if isobject(w2)
    % w2 is not an intrinsic matlab class
    if ~isobject(w1)
        outputClassname = class(w2);
    end
    size_stack2 = size(w2);
    size_root2 = [1,1];
    
elseif isfloat(w2)
    % w1 is a float array; w2 must have class 'classname'
    if ~isscalar(w2)
        size_stack2 = size(w1);
        [size_root2, ok] = size_array_split (size(w2), size(w1));
        if ~ok
            mess = ['Unable to resolve the numeric array into a stack of arrays, ',...
                'with stack size matching the object array size '];
            error([upper(thisClassname),':binary_op_manager'], mess);
        end
    else
        size_stack2 = [1,1];    % want the scalar to apply to each object in w1
        size_root2 = [1,1];
    end
    
else
    % Error state: w2 is a matlab intrinsic class but not a float
    % (e.g.  logical, character, cell array)
    error([upper(thisClassname),':binary_op_manager'], ...
        ['Invalid second argument to binary operation - ' ...
        'it must be an object, or a float (i.e. double or single precision).'])
end


% Perform binary operation
% --------------------------
% In the following, recall that if w1 or w2 is a numeric array, it can be
% thought of as being resolved into an array of 'objects', each of those
% 'objects' being an array with size size_root1 (in the case of w1) or
% size_root2 (in the case of w2). The size of the array of 'objects' is
% size_stack1 or size_stack2 (in the case of w2).
%
% The trick in the following is to reshape the real array where necessary
% into a two dimensional array, where the first dimension gives the
% elements of the inner array, the second dimension gives the elements of
% the stack.

constructor_handle = str2func(outputClassname);   % handle to output class constructor

nroot1 = prod(size_root1);
nroot2 = prod(size_root2);
nobj1 = prod(size_stack1);
nobj2 = prod(size_stack2);

if (nobj1 == nobj2 && nobj1 == 1)
    % w1 and w2 both scalar instances of objects
    w = binary_op_manager_single(w1, w2, binary_op);
    
elseif isequal(size_stack1, size_stack2)
    % w1 and w2 are both non-scalar arrays of objects (scalar case caught above)
    w = repmat(constructor_handle(), size_stack1);
    w1_2D = reshape(w1, nroot1, nobj1);
    w2_2D = reshape(w2, nroot2, nobj2);
    for i = 1:nobj1
        obj1 = reshape(w1_2D(:,i), size_root1);
        obj2 = reshape(w2_2D(:,i), size_root2);
        w(i) = binary_op_manager_single(obj1, obj2, binary_op);
    end
    
elseif (nobj1 == 1 && nobj2 > 1)
    % w1 scalar, w2 an array of objects
    w = repmat(constructor_handle(), size_stack2);
    w2_2D = reshape(w2, nroot2, nobj2);
    for i = 1:nobj2
        obj2 = reshape(w2_2D(:,i), size_root2);
        w(i) = binary_op_manager_single(w1, obj2, binary_op);
    end
    
elseif (nobj1 > 1 && nobj2 == 1)
    % w1 an array of objects, w2 scalar
    w = repmat(constructor_handle(), size_stack1);
    w1_2D = reshape(w1, nroot1, nobj1);
    for i = 1:nobj1
        obj1 = reshape(w1_2D(:,i), size_root1);
        w(i) = binary_op_manager_single(obj1, w2, binary_op);
    end
    
else
    error([upper(thisClassname),':binary_op_manager'], ...
        ['Array lengths are incompatible.\n'...
        'Both arrays must have an equal number of elements or the ' ...
        'number of elements in one of the arrays must be 1.\n' ...
        'Arrays have number of elements ''%i'' & ''%i''.'], nobj1, nobj2);
end

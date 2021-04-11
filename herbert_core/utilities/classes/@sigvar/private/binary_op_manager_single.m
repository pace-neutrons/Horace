function wout = binary_op_manager_single(w1, w2, binary_op)
% Implement a binary operation for objects with a signal and a variance array.
%
%   >> wout = binary_op_manager_single(w1, w2, binary_op)
%
% Input:
% ------
%   w1, w2      Objects on which the binary operation is to be performed.
%               One of these can be a real (i.e. double or single precision)
%               array, in which case the variance array is taken to be zero.
%
%               If w1, w2 are objects with the same signal array sizes:
%               - The operation is performed element-by-element.
%
%               If one of w1 or w2 is a real array (the other a scalar object):
%               - If a scalar, apply to each element of the object signal.
%               - If an array of the same size as the object signal array,
%                 apply element by element.
%
%   binary_op   Function handle to binary operation. All binary operations
%               on Matlab double or single arrays are permitted (+, -, *,
%               /, \).
%
% Output:
% -------
%   wout        Output object. Assumed to have same class as the superior
%               of the two input objects.


% NOTES:
% Gives the generic behaviour for handling objects and floats for any class,
% but may need modification of the actual binary operation calculation
% depending on the details of the class internal complexity.
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


% One or both of w1, w2 is an instance of the class for which this a method
% because otherwise this method would not have been called. Furthermore, it
% must be the superior class (assuming that a method with this name is
% defined for both classes)
%
% We make a copy of whichever of w1 or w2 is the superior class, so that
% any of the additional properties are carried through unchanged. If both
% are instances of class classname, then w1 is assumed dominant.

thisClassname = mfilename('class');

if ~isa(w1, 'double') && ~isa(w2, 'double')
    % Neither of w1, w2 is a double array
    if isequal(sigvar_size(w1), sigvar_size(w2))
        %----------------------------------------------------------------------
        % The following block may be class specific
        if isa(w1,thisClassname)
            wout = w1;  % if w1 and w2 are both of class classname, use w1
        else
            wout = w2;
        end
        result = binary_op(sigvar(w1), sigvar(w2));
        wout = sigvar_set(wout, result);
        %----------------------------------------------------------------------
    else
        error([upper(thisClassname),':binary_op_manager_single'], ...
            'Sizes of signal arrays in the objects are different.');
    end
    
elseif isa(w2, 'double')
    % w1 is an instance of classname, w2 is a double
    if isscalar(w2) || isequal(sigvar_size(w1), size(w2))
        %----------------------------------------------------------------------
        % The following block may be class specific
        wout = w1;
        result = binary_op(sigvar(w1), sigvar(w2));
        wout = sigvar_set(wout, result);
        %----------------------------------------------------------------------
    else
        error([upper(thisClassname),':binary_op_manager_single'], ...
            ['Check that the numeric variable is scalar or array ' ...
            'with same size as object signal.']);
    end
    
elseif isa(w1, 'double')
    % w2 is an instance of classname, w1 is a double
    if isscalar(w1) || isequal(sigvar_size(w2),size(w1))
        %----------------------------------------------------------------------
        % The following block may be class specific
        wout = w2;
        result = binary_op(sigvar(w1), sigvar(w2));
        wout = sigvar_set(wout, result);
        %----------------------------------------------------------------------
    else
        error([upper(thisClassname),':binary_op_manager_single'], ...
            ['Check that the numeric variable is scalar or array ' ...
            'with same size as object signal.']);
    end

end

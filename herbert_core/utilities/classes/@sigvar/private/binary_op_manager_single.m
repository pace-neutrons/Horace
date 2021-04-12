function wout = binary_op_manager_single(w1, w2, binary_op)
% Implements a binary operation for objects with a signal and a variance array.
%
%   >> w = binary_op_manager(w1, w2, binary_op)
%
% All binary operations on Matlab double arrays are permitted
% (+, -, *, /, \) and are applied element by element to the signal and
% variance arrays.
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
%   binary_op   Function handle to a binary operation. All binary operations
%               on Matlab double or single arrays are permitted (+, -, *,
%               /, \)
%
% Output:
% -------
%   w           Output object or array of objects.
%
%
% NOTES:
% This is a generic template method - works for any class (including sigvar)
% but the indicated blocks may need to be edited for a particular class.
% Note that the variant for the sigvar class does not apply the sigvar
% constructor to an input double array.
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

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_binary_op_manager_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_binary_scalar_args_IO_description.m')
%   doc_file_notes = fullfile(doc_dir,'doc_binary_op_manager_single_notes.m')
%   doc_file_sigvar_notes = fullfile(doc_dir,'doc_sigvar_notes.m')
%
%   list_operator_arg = 1
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
%
%   <#file:> <doc_file_IO> <list_operator_arg>
%
%
% NOTES:
%   <#file:> <doc_file_notes>
%
%   <#file:> <doc_file_sigvar_notes>
% <#doc_end:>
% -----------------------------------------------------------------------------


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

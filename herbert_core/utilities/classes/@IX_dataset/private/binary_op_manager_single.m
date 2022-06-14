function wout = binary_op_manager_single(w1, w2, binary_op)
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
        result = binary_op(sigvar(w1), w2);
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
        result = binary_op(w1, sigvar(w2));
        wout = sigvar_set(wout, result);
        %----------------------------------------------------------------------
    else
        error([upper(thisClassname),':binary_op_manager_single'], ...
            ['Check that the numeric variable is scalar or array ' ...
            'with same size as object signal.']);
    end

end

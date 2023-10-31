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
sz1 = sigvar_size(w1);
sz2 = sigvar_size(w2);
if ~(isequal(sz1,sz2) || isequal(sz1,[1,1]) || isequal(sz2,[1,1]))
    error('HERBERT:data_op_interface:binary_op_manager_single', ...
        'Size of signal array for obj1(%d) differs from size of obj2(%d) and any is not unit size', ...
        mat2str(sz1),mat2str(sz2));
end
if data_op_interface.is_superior(w1,w2)
    wout = w1;
else
    wout = w2;    
end
result = sigvar(w1).binary_op_manager(sigvar(w2),binary_op);
wout   = sigvar_set(wout, result);

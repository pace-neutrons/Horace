function w = unary_op_manager (obj, unary_op)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_unary_op_manager_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_unary_general_args_IO_description.m')
%   doc_file_notes = fullfile(doc_dir,'doc_unary_op_manager_notes.m')
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


w = obj;
for i=1:numel(obj)
    %----------------------------------------------------------------------
    w(i) = unary_op(obj(i));
    %----------------------------------------------------------------------
end

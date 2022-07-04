function w = mrdivide (w1, w2)
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

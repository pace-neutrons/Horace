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


op_name = func2str(binary_op);
% identify order operands superiority and the type of operation to be
% performed over operands
[flip,page_op_kind] = data_op_interface.get_operation_order( ...
    w1,w2,op_name );
if flip
    wout    = copy(w2);
    operand = w1;
else
    wout    = copy(w1);
    operand = w2;
end


switch(page_op_kind)
    case(0) % operation betwen two objects convertible to sigvar
        result = binary_op(sigvar(w1),sigvar(w2));
        wout   = sigvar_set(wout, result);
        return
    case(1) % operation between object with pixels and numeric constant
        page_op = PageOp_binary_sqw_double();
    case(2) % operation between object with pixels and image and object
        %     equivalent to image
        page_op = PageOp_binary_sqw_img();
    case(3) % operation between two objects with pixels and images
        page_op = PageOp_binary_sqw_sqw();
    otherwise
        error('HERBERT:data_op_interface:invalid_argument', ...
            'unsupported type of operation %d for operation %s between objects of class %s and class %s', ...
            page_op_kind,op_name,class(w1),class(w2));
end
page_op = page_op.init(wout,operand,binary_op,flip);
wout    = wout.apply_op(wout,page_op);
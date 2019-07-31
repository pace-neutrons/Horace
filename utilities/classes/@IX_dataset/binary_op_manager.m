function w = binary_op_manager (w1, w2, binary_op)
%Implement binary arithmetic operations for objects containing a double array.
if isa(w1,'IX_dataset')
    class_name = class(w1);
elseif isa(w2,'IX_dataset')
    class_name = class(w1);
else
    error('IX_dataset:invalid_argument',...
        ' binary operation needs at least one operand to be a IX_dataset');
end
w = binary_op_manager_(w1, w2, binary_op,class_name);


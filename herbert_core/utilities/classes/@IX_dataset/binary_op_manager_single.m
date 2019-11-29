function wout = binary_op_manager_single(w1,w2,binary_op)
% Implement binary operator for objects with a signal and a variance array.
if isa(w1,'IX_dataset')
    class_name = class(w1);
elseif isa(w2,'IX_dataset')
    class_name = class(w1);
else
    error('IX_dataset:invalid_argument',...
        ' binary operation needs at least one operand to be a IX_dataset');
end
wout = binary_op_manager_single_(w1,w2,binary_op,class_name);


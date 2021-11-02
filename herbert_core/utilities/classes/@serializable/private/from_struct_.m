function obj = from_struct_(inputs)
% Restore object from the fields, previously obtained by struct method
% Input:
% inputs  -- structure or structure array of data, fully defining the
%            internal state of the object
% Output:
% obj    --  fully defined object or array of objects
%
if ~isfield(inputs,'serial_name')
    error('HERBERT:serializable:invalid_argument',...
        ['Class has not been converted into a structure, using serializable',...
        ' class "to_struct" operation. This method can not restore the class'])
end
%
class_name = inputs.serial_name;
%
obj = feval(class_name);
if isfield(inputs,'array_dat')
    obj = obj.from_class_struct(inputs.array_dat);
else
    obj = obj.from_class_struct(inputs);
end

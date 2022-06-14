function obj = from_struct_(inputs,existing_obj)
% Restore object from the fields, previously obtained by struct method
% Input:
% inputs  -- structure or structure array of data, fully defining the
%            internal state of the object
% Optional:
% existing_obj -- existing instance of the class to restore
%
% Output:
% obj    --  fully defined object or array of objects, with its state
%            restored from inputs
%
if isempty(existing_obj) && ~isfield(inputs,'serial_name')
    error('HERBERT:serializable:invalid_argument',...
        ['Class has not been converted into a structure, using serializable',...
        ' class "to_struct" operation. This method can not restore the class'])
end
%
if isempty(existing_obj)
    class_name = inputs.serial_name;
    obj = feval(class_name);
else
    obj  = existing_obj;
end

if isfield(inputs,'version')
    if inputs.version == obj.classVersion()
        if isfield(inputs,'array_dat')
            obj = obj.from_bare_struct(inputs.array_dat);
        else
            obj = obj.from_bare_struct(inputs);
        end
    else
        obj = obj.from_old_struct(inputs);
    end
else
    obj = obj.from_old_struct(inputs);
end

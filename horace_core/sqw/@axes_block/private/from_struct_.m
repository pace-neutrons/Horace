function  [obj,remain_inputs] = from_struct_(obj,input)
% set up axis_block object from the input structure, shared with sqw_dnd
% object
%
%
flds = obj.fields_to_save_;
remain_inputs = input;
for i=1:numel(flds )
    fld = flds{i};
    if isfield(input,fld)
        obj.(fld) = input.(fld);
        remain_inputs  = rmfield(remain_inputs,fld);
    end
end

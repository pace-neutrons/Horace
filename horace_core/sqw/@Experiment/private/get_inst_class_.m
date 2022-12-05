function [inst, all_inst] = get_inst_class_(obj)
% Determine the instrument type in the collection of
% instruments and verify unique instruments
%

inst = obj.instruments.unique_objects;
if isempty(inst)
    all_inst = false;
    inst = [];
    return;
end
is_empty = cellfun(@(x)isa(x,'IX_null_inst'),inst);
if any(is_empty)
    all_inst = false;
    inst = inst(~is_empty);
else
    all_inst = true;
end

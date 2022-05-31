function iseq = iseq_(obj,other_obj)
% compare two serializable objects using their public fields for comparison
%
flds = obj.saveableFields();
for i=1:numel(flds)
    iseq = equal_to_tol(obj.(flds{i}),other_obj.(flds{i}));
    if ~iseq
        return;
    end
end
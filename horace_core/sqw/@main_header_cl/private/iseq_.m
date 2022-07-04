function [iseq,mess] = iseq_(obj,other_obj,ignore_string)
% compare two serializable objects using their public fields for comparison
%
if nargin == 2
    ignore_string = false;
end

flds = obj.saveableFields();
for i=1:numel(flds)
    fld = flds{i};
    val = obj.(fld);
    if ignore_string && (ischar(val)|| isstring(val))
        continue;
    end
    iseq = equal_to_tol(val,other_obj.(fld));
    if ~iseq
        mess = sprintf('Two objects have different field: %s.\n Obj1.%s == %s Obj2.%s == %s',...
            fld,fld,evalc('disp(obj.(fld))'),fld,evalc('disp(other_obj.(fld))'));
        return;
    end
end
mess = '';
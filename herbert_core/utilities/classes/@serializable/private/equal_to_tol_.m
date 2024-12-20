function [iseq, mess] =equal_to_tol_(obj1, obj2,opt)
% Check equality of two serializable objects


mess = '';
for i=1:numel(obj1)
    [iseq, mess] = eq_single (obj1(i), obj2(i), opt);
    if ~iseq
        return;
    end
end
end


%-------------------------------------------------------------------------------
function [iseq, mess] = eq_single (obj1, obj2, opt)
% Compare single pair of serializeble objects

flds = obj1.saveableFields();

for i=1:numel(flds)
    lopt = opt;
    lopt.name_a = [opt.name_a,'.',flds{i}];
    lopt.name_b = [opt.name_b,'.',flds{i}];

    tmp1 = obj1.(flds{i});
    tmp2 = obj2.(flds{i});
    [iseq,mess] = equal_to_tol (tmp1 , tmp2, lopt);
    if ~iseq
        return;
    end
end
end

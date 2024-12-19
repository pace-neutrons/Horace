function [iseq, mess] =equal_to_tol_(obj1, obj2,opt)
% Check equality of two serializable objects


iseq = false(numel(obj1),1);
mess = cell(numel(obj1),1);
for i=1:numel(obj1)
    [iseq(i), mess{i}] = eq_single (obj1(i), obj2(i), opt);
end

if narg_out > 1
    if any(~iseq)
        mess = strjoin(mess,'; ');
    else
        mess = '';
    end
end

end


%-------------------------------------------------------------------------------
function [iseq, mess] = eq_single (obj1, obj2, opt)
% Compare single pair of serializeble objects

struc1 = obj1.to_bare_struct();
struc2 = obj2.to_bare_struct();
[iseq,mess] = equal_to_tol (struc1, struc2, opt);

end

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

struc1 = obj1.to_bare_struct();
struc2 = obj2.to_bare_struct();
[iseq,mess] = equal_to_tol (struc1, struc2, opt);

end

function [is,mess] = eq_(obj,other_obj,narg_out,names,varargin)
% Check equality of two serializable objects
%
[is,mess,name_a,name_b,namer,argi] = obj.process_inputs_for_eq(other_obj,narg_out,names,varargin{:});
if ~is
    return
end
is = false(numel(obj),1);
for i=1:numel(obj)
    if nargout == 2
        name_1 = namer(name_a,i);
        name_2 = namer(name_b,i);
        [is(i),mess{i}] = eq_single(obj(i),other_obj(i), ...
            'name_a',name_1,'name_b',name_2,argi{:});
    else
        is(i) = eq_single(obj(i),other_obj(i), ...
            'name_a',name_a,'name_b',name_b,argi{:});
    end
end
if narg_out > 1
    if any(~is)
        mess = strjoin(mess,'; ');
    else
        mess = '';
    end
end

function [iseq,mess] = eq_single(obj1,obj2,name_a,name_a_val,name_b,name_b_val,varargin)
% compare single pair of serializeble objects
%
struc1 = obj1.to_bare_struct();
struc2 = obj2.to_bare_struct();
[iseq,mess] = equal_to_tol(struc1,struc2, ...
        name_a,name_a_val,name_b,name_b_val,varargin{:});



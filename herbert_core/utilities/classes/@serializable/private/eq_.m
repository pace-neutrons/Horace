function [iseq, mess] = eq_ (obj1, obj2, narg_out, names, varargin)
% Check equality of two serializable objects

[iseq, mess, name_a, name_b, namer, argi] = obj1.process_inputs_for_eq (obj2, ...
    narg_out, names, varargin{:});
if ~iseq
    return
end

iseq = false(numel(obj1),1);
for i=1:numel(obj1)
    if nargout == 2
        name_1 = namer(name_a,i);
        name_2 = namer(name_b,i);
        [iseq(i), mess{i}] = eq_single (obj1(i), obj2(i), ...
            'name_a', name_1, 'name_b', name_2, argi{:});
    else
        iseq(i) = eq_single(obj1(i),obj2(i), ...
            'name_a', name_a, 'name_b', name_b, argi{:});
    end
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
function [iseq, mess] = eq_single (obj1, obj2, ...
    name_a, name_a_val, name_b, name_b_val, varargin)
% Compare single pair of serializeble objects

struc1 = obj1.to_bare_struct();
struc2 = obj2.to_bare_struct();
[iseq,mess] = equal_to_tol (struc1, struc2, ...
        name_a, name_a_val, name_b, name_b_val, varargin{:});

end

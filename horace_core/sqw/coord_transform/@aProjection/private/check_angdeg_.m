function angdeg = check_angdeg_(val)
% verify if input lattice angles belong to acceptable range
%
if numel(val) == 1
    val = abs(val);
    angdeg = [val,val,val];
elseif size(val,2)==3 && size(val,1)==1
    angdeg = abs(val);
elseif size(val,1)==3 && size(val,2)==1
    angdeg = abs(val');
else
    error('aPROJECTION:invalid_argument',...
        'input value for angdeg may be a single number or 3-element vector. In fact it is: %s',...
        evalc('disp(val)'));
end
valid = arrayfun(@(x)(x>0 && x<180),val,'UniformOutput',true);
if ~all(valid)
    error('aPROJECTION:invalid_argument',...
        'input value for angdeg may be a number in the range 0<x<180. In fact it is: %s',...
        evalc('disp(val)'));
end

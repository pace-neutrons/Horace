function angdeg = check_angdeg_return_standard_val_(obj,val)
% verify if input lattice angles belong to acceptable range (+-180 deg,
% negative angles treated as positive) and have
% acceptable form (either 3-vector of angles or single value, defining 3 equal
% lattice parameters)
%
% return acceptable lattice angles in standard form,i.e.
% [1x3] vector of lattice parameters.
%
% Throws if lattice angles can not be transformed into standard form
%
%
if numel(val) == 1
    val = abs(val);
    angdeg = [val,val,val];
elseif size(val,2)==3 && size(val,1)==1
    angdeg = abs(val);
elseif size(val,1)==3 && size(val,2)==1
    angdeg = abs(val');
else
    error('HORACE:aProjection:invalid_argument',...
        'input value for angdeg may be a single number or 3-element vector. In fact it is: %s',...
        evalc('disp(val)'));
end
valid = arrayfun(@(x)(x>obj.tol_ && x<180),val,'UniformOutput',true);
if ~all(valid)
    error('HORACE:aProjection:invalid_argument',...
        'input value for angdeg may be a number in the range 0<x<180. In fact it is: %s',...
        evalc('disp(val)'));
end

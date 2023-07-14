function [alat,defined] = check_alatt_return_standard_val_(obj,val)
% verify if input lattice parameters belong to acceptable range and have
% acceptable form (either 3-vector or single value, defining 3 equal
% lattice parameters)
%
% return acceptable lattice parameters in standard form,i.e.
% [1x3] vector of lattice parameters
%
% Throws if lattice parameters can not be transformed into standard form
%
 defined = false;
if isempty(val)
    alat = [];
    return;
end

if numel(val) == 1
    val = abs(val);
    alat = [val,val,val];
elseif size(val,2)==3 && size(val,1)==1
    alat = abs(val);
elseif size(val,1)==3 && size(val,2)==1
    alat = abs(val');
else
    error('HORACE:aProjectionBase:invalid_argument',...
        'input value for lattice may be a single positive number or 3-element vector, with any element bigger then 0 In fact it is: %s',...
        disp2str(val));
end
if any(val<obj.tol_)
    error('HORACE:aProjectionBase:invalid_argument',...
        'input value for lattice may be a single positive number or 3-element vector, with any element bigger then 0. In fact it is: %s',...
        disp2str(val));
end
defined = true;

function alat = check_alatt_(val)
% verify if input lattice parameters belong to acceptable range
if numel(val) == 1
    val = abs(val);
    alat = [val,val,val];
elseif size(val,2)==3 && size(val,1)==1
    alat = abs(val);
elseif size(val,1)==3 && size(val,2)==1
    alat = abs(val');
else
    error('aPROJECTION:invalid_argument',...
        'input value for lattice may be a single number or 3-element vector. In fact it is: %s',...
        evalc('disp(val)'));
end

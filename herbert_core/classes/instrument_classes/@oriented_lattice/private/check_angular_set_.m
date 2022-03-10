function val=check_angular_set_(obj,val)
% function checks if single angular value one tries to set is correct
%
if ~isnumeric(val)
    error('HERBERT:oriented_lattice:invalid_argument',...
        'angular value has to be numeric but it is: %s',...
        evalc('disp(val)'));
end
if numel(val)>1
    error('HERBERT:oriented_lattice:invalid_argument',...
        'angular value has to have a single value but it is array of %d elements',...
        numel(val));
end
if obj.angular_is_degree_
    lim = 360;
    mess = '+-360deg';
else
    lim = 2*pi;
    mess = '+-2*pi(rad)';
end
if abs(val)>lim
    error('HERBERT:oriented_lattice:invalid_argument',...
        'An angular value should be in the range of %s but it equal to: %g',...
        mess, val);
end


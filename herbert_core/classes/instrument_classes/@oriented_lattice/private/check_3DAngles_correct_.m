function val =  check_3DAngles_correct_(obj,val)
% check correct angular values for lattice angles
%
if isempty(val)
    error('HERBERT:oriented_lattice:invalid_argument',...
        'oriented_lattice angles can not be empty')
end
if numel(val)==1
    val = [val,val,val];
end
%
if numel(val) ~= 3
    error('HERBERT:oriented_lattice:invalid_argument',...
        ' lattice angles have to be either 3-element vector, or a single value')
end
if ~all(isnumeric(val))
    error('HERBERT:oriented_lattice:invalid_argument',...
        ' attempt to set non-numeric lattice angles')
end
%
if size(val,2)==1
    val = val';
end
if obj.angular_is_degree_
    lim = 180;
    mess = ']0-180[deg';
else
    lim = pi;
    mess = ']0-pi[rad';
end

if max(val) >= lim || min(val)< 0
    error('HERBERT:oriented_lattice:invalid_argument',...
        ' lattice angle has to be angles in degree in the range %s but setting: [%f,%f,%f]',...
        val(1),val(2),val(3),mess)
end

% check correct angular values for lattice
if (val(1)>=(val(2)+val(3)))||...
        (val(2)>=(val(3)+val(1)))||...
        (val(3)>=(val(1)+val(2)))
    error('HERBERT:oriented_lattice:invalid_argument',...
        'lattice angles can not define correct 3D lattice');
end

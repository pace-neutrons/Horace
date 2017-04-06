function val =  check_3DAngles_correct_(val)
% check correct angular values for lattice angles
%
if isempty(val)
    error('ORIENTED_LATTICE:invalid_argument',...
        'oriented_lattice angles can not be empty')
end
if numel(val)==1
    val = [val,val,val];
end
%
if numel(val) ~= 3
    error('ORIENTED_LATTICE:invalid_argument',...
        ' lattice angles have to be either 3-element vector, or a single value')
end
if ~all(isnumeric(val))
    error('ORIENTED_LATTICE:invalid_argument',...
        ' attempt to set non-numeric lattice angles')
end
%
if size(val,2)==1
    val = val';
end
if max(val) >= 180 || min(val)<=0
    error('ORIENTED_LATTICE:invalid_argument',...
        ' lattice angle has to be angles in degree in the range ]0-180[ deg but setting: [%f,%f,%f]',...
        val(1),val(2),val(3))
end

% check correct angular values for lattice
if (val(1)>=(val(2)+val(3)))||...
        (val(2)>=(val(3)+val(1)))||...
        (val(3)>=(val(1)+val(2)))
    
    error('ORIENTED_LATTICE:invalid_argument',...
        'lattice angles do not define correct 3D lattice');
end


function val=check_angular_set_(val)
% function checks if single angular value one tries to set is correct
%
if ~isnumeric(val)
    error('ORIENTED_LATTICE:invalid_argument',...
        'angular value has to be numeric but it is not');
end
if numel(val)>1
    error('ORIENTED_LATTICE:invalid_argument',...
        'angular value has to have a single value but it is array of %d elements',numel(val));
end
if abs(val)>360
    error('ORIENTED_LATTICE:invalid_argument',...
        'angular value should be in the range of +-360 deg but it equal to: %f',val);
end

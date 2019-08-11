function vector = check_3Dvector_correct_(obj,val)
% function verifies if 3D vector is correct and transforms single value (if
% provided) into 3D vector;
%
if isempty(val)
    error('ORIENTED_LATTICE:invalid_argument',...
        'Oriented lattice do not accept empty vectors')
end
if ~all(isnumeric(val))
    error('ORIENTED_LATTICE:invalid_argument',...
        ' attempt to set non-numeric  lattice parameter')
end

vector = val;

if numel(val)==1
    vector = [val,val,val];
end

if numel(vector) ~= 3
    error('ORIENTED_LATTICE:ivalid_argument',...
        ' lattice parameters have to be either 3-element vector, or single value')
end

if size(vector,2)==1
    vector = vector';
end

norm = vector*vector';
if norm<obj.tol_*obj.tol_
    error('ORIENTED_LATTICE:invalid_argument',...
        'norm of 3-vectors used by oriented_lattice can not be smaller then tolerance=%d',...
        obj.tol_)
end

function vector = check_3Dvector(val)
% function verifies if 3D vector is correct and transforms single value (if
% provider) into 3D vector;

vector = val;
if numel(val)==1
    vector = [val,val,val];
end
if numel(vector) ~= 3
    error('RUNDATA:set_lattice_param',' lattice parameters have to be either 3-element vector, or single value')
end
if ~all(isnumeric(vector))
    error('RUNDATA:set_lattice_param',' attempt to set non-numeric  lattice parameter')
end
if size(vector,2)==1
    vector = vector';
end

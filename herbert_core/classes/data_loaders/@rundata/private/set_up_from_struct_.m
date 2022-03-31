function obj = set_up_from_struct_(struc)
% Set up rundata from the structure, obtained from loadobj method

if isfield(struc,'lattice')
    lat = oriented_lattice();
    struc.lattice = lat.from_bare_struct(struc.lattice);
end
cln = struc.class_name;
if isempty(struc.par_file_name)
    obj = feval(cln,struc.data_file_name);
else
    obj = feval(cln,struc.data_file_name,struc.par_file_name);    
end

struc = rmfield(struc,{'data_file_name','par_file_name','class_name'});


fields = fieldnames(struc);
for nf = 1:numel(fields)
    obj.(fields{nf}) = struc.(fields{nf});    
end


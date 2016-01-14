function rd = rundata_from_string(str)
% build rundata object from its string representation obrained earlier by
% serialize function

len = numel(str)/3;
sa = reshape(str,len,3);
iarr = uint8(str2num(sa));

str = hlp_deserialize(iarr);
if isfield(str,'lattice')
    str.lattice = oriented_lattice(str.lattice);
end
if isempty(str.par_file_name)
    rd = rundata(str.data_file_name);
else
    rd = rundata(str.data_file_name,str.par_file_name);    
end

str = rmfield(str,{'data_file_name','par_file_name'});

fields = fieldnames(str);
for nf = 1:numel(fields)
    rd.(fields{nf}) = str.(fields{nf});
end

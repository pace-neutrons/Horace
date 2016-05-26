function [rd,size] = deserialize_(iarr)
% Deserialize rundata object serialized earlier into series of bytes
size = typecast(iarr(1:8),'uint64');
if size>numel(iarr)-8
    error('RUNDATA:deserialize',' The stored rundata object size is larger then byte array size provided');
end

if verLessThan('matlab','7.12')
    str = hlp_deserialize(iarr(9:double(size+8)));    
else
    str = hlp_deserialize(iarr(9:size+8));
end
%size = size+8;

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


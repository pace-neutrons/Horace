function output_byte_array = serialize_(run)
% Serialize rundata object in a way, which allows it to be restored 
% by deserialize operation

[undefined,fields_from_loader,fields_undef] = check_run_defined(run);
if (undefined>2)
    undef_str = strjoin(fields_undef,'; ');
    error('RUNDATA:to_string','Can not confvert to string undefined rundata class due to undefined fields %s',undef_str)
end
fields = {'data_file_name','par_file_name','efix','emode'};


in_loader = ismember(fields,fields_from_loader);
left_fields = fields(~in_loader);

out_struct = struct();
for nf=1:numel(left_fields)
    out_struct.(left_fields{nf}) = run.(left_fields{nf});
end
if run.is_crystal
    out_struct.lattice = run.oriented_lattice__.struct();
end
%-------------------- Store data in memory if necessary.
if ~isfield(out_struct,'data_file_name')
    out_struct.data_file_name = run.data_file_name;
end
%
if isempty(out_struct.data_file_name) || ...
        ~(exist(out_struct.data_file_name,'file')==2) || ...
        run.is_loaded() %
    data_fields = {'S','ERR','en'};
    for i=1:numel(data_fields)
        out_struct.(data_fields{i}) = run.(data_fields{i});
    end    
end
%-------------------- Store detector info if necessary
if ~isfield(out_struct,'par_file_name')
    out_struct.par_file_name = run.par_file_name;
end

if (isempty(out_struct.par_file_name) ...
        || ~(exist(out_struct.par_file_name,'file')==2)) && ...
    ~isempty(run.det_par)
    out_struct.det_par = run.det_par;
    out_struct.par_file_name='';
end
    

if ~isempty(run.instrument)
    out_struct.instrument = run.instrument;
end
if ~isempty(run.sample)
    out_struct.sample = run.sample;
end
out_struct.class_name = class(run);

v = hlp_serialize(out_struct);

szv = uint64(numel(v));
szvb = typecast(szv,'uint8')';
output_byte_array = [szvb;v];

end


function output_byte_array = serialize_(run)
% Serialize rundata object in a way, which allows it to be restored 
% by deserialize operation

[undefined,~,fields_undef] = check_run_defined(run);
if (undefined>2)
    undef_str = strjoin(fields_undef,'; ');
    error('RUNDATA:to_string','Can not confvert to string undefined rundata class due to undefined fields %s',undef_str)
end
%
out_struct = run.saveobj();
%
v = serialise(out_struct);

szv = uint64(numel(v));
szvb = typecast(szv,'uint8')';
output_byte_array = [szvb;v];

end


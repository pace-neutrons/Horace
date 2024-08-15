function output_byte_array = serialize_(run)
% Serialize rundata object in a way, which allows it to be restored 
% by deserialize operation

[undefined,~,fields_undef] = check_run_defined(run);
if (undefined>2)
    undef_str = strjoin(fields_undef,'; ');
    error('HERBERT:rundata:invalid_argument',...
    'Can not convert to string undefined rundata class due to undefined fields %s',undef_str)
end
%
out_struct = run.saveobj();
%
v = serialize(out_struct);

szv = uint64(numel(v));
szvb = typecast(szv,'uint8')';
output_byte_array = [szvb;v];

end


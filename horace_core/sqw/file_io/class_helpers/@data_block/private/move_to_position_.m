function move_to_position_(obj,fid,pos)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
if isempty(pos)
    pos = obj.position;
end
fseek(fid,pos,'bof');
[mess,res] = ferror(fid);
if res ~= 0 
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'Error "%s" moving to the start of the record %s.%s in the target file: %s', ...
        mess,obj.base_prop_name,obj.level2_prop_name,file);

end

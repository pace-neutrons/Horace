function obj=put_footer_(obj)
% serialized structure, which contains all positions for different data
% fields, to be found in an sqw file of appropriate version and store these
% positions on hdd for subsequent recovery and use in read/write operations
%

fields2save = obj.fields_to_save();
data_block = struct('data_type',obj.data_type);
for i=1:numel(fields2save)
    fld = fields2save{i};
    data_block.(fld) = obj.(fld);
end


form = obj.get_is_form();
bytes = obj.sqw_serializer_.serialize(data_block,form);
sz = uint32(numel(bytes));
byte_sz = typecast(sz,'uint8');
bytes = [bytes,byte_sz];

pos = obj.position_info_pos_;
fseek(obj.file_id_,pos,'bof');
check_error_report_fail_(obj,'can not move to the positions block start');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Can not write the positions block');

%
obj.real_eof_pos_ = ftell(obj.file_id_);
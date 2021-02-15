function obj = write_v2_obj_header_(obj)
% write v3 file as v2 file
%
head = obj.build_app_header();
head.version = 2;
%
head_form = obj.app_header_form_;

% write sqw header
bytes = obj.sqw_serializer_.serialize(head,head_form);
fseek(obj.file_id_,0,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the file');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the sqw file header');

obj=obj.delete();

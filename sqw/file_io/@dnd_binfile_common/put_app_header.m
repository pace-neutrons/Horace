function obj = put_app_header(obj)
% store binary data boock, which describes object as sqw or dind object
%
% $Revision$ ($Date$)
%
obj.check_obj_initated_properly();
%
% store sqw file header
head = obj.build_app_header();
%
head_form = obj.app_header_form_;

% write sqw header
bytes = obj.sqw_serializer_.serialize(head,head_form);
fseek(obj.file_id_,0,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the file');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the sqw file header');



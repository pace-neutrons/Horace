function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
%
check_obj_initated_properly_(obj);
%
% store sqw file header
head = obj.build_app_header();
% just in case we are trying to save data into dnd file
head.sqw_type = false;
%
head_form = obj.app_header_form_;

% write sqw header
bytes = obj.sqw_serializer_.serialize(head,head_form);
fseek(obj.file_id_,0,'bof');
check_error_report_fail(obj,'Error moving to the beginning of the file');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail(obj,'Error writing the file header');
%
% write image methadata
data_form = obj.get_data_form('-head');
bytes = obj.sqw_serializer_.serialize(obj.sqw_holder_,data_form);
fseek(obj.file_id_,obj.data_pos_,'bof');
check_error_report_fail(obj,'Error moving to the beginning of the data record');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail(obj,'Error writing the dnd obhect methadata');
clear bytes
%
% write signal, error and npix
fseek(obj.file_id_,obj.s_pos_,'bof');
check_error_report_fail(obj,'Error moving to the beginning of the signal record');

fwrite(obj.file_id_,obj.sqw_holder_.s,'float32');
check_error_report_fail(obj,'Error writing signal record');
fseek(obj.file_id_,obj.e_pos_,'bof');

check_error_report_fail(obj,'Error moving to the beginning of the error record');
fwrite(obj.file_id_,obj.sqw_holder_.e,'float32');
check_error_report_fail(obj,'Error writing error record');

fseek(obj.file_id_,obj.npix_pos_,'bof');
check_error_report_fail(obj,'Error moving to the beginning of the npix record');
fwrite(obj.file_id_,obj.sqw_holder_.npix,'uint64');
check_error_report_fail(obj,'Error writing npix record');
%
% put urange if necessary
if obj.urange_pos_ ~= 0
    fseek(obj.file_id_,obj.urange_pos_,'bof');
    check_error_report_fail(obj,'Error moving to the beginning of the urange record');
    fwrite(obj.file_id_,obj.sqw_holder_.urange,'float32');
    check_error_report_fail(obj,'Error writing urange record');
end


function check_error_report_fail(obj,pos_mess)
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('DND_BINFILE_COMMON:io_error',...
        ['put_sqw: ',pos_mess,' reason: ',mess]);
end

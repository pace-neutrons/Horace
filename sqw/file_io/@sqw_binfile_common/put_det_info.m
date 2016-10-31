function   obj = put_det_info(obj,varargin)
% Save or replace main sqw header into properly initalized
% binary sqw file
%Usage:
%>>obj.put_main_header();
%>>obj.put_main_header('-update');
%>>obj.put_header(sqw_obj_new_source_for_update); -- updates main header
%                               informaion using new object as source
%
% If update options is selected, header have to exist. This option keeps
% exisitng file information untouched;

[ok,mess,update,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_BINFILE_COMMON:invalid_argument',mess);
end
%
obj.check_obj_initated_properly();
%
[detpar,new_obj] = extract_correct_subobj_(obj,'detpar',argi{:});
if new_obj
    update = true;
end

if update
    %det_form = obj.get_detpar_form('-update');
    error('SQW_BINFILE_COMMON:not_implemented','Update detinfor is not yet implemented');
else
    det_form = obj.get_detpar_form();
end


bytes = obj.sqw_serializer_.serialize(detpar,det_form);
if update
    start_pos = obj.main_head_pos_info_.nfiles_pos_;
    %     sz = obj.header_pos_-start_pos;
    %     if sz ~= numel(bytes)
    %         error('SQW_BINFILE_COMMON:invalid_argument',...
    %             'unavble to update main header as new data size is not equal to the space remaining')
    %     end
else
    start_pos = obj.detpar_pos_;
end
fseek(obj.file_id_,start_pos ,'bof');
check_error_report_fail_(obj,'Error moving to the start of the detectors record');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the detectors information');


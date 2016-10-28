function obj=put_dnd_methadata(obj,varargin)
% Write dnd methadata or upgrade existing methadata with new records, which
% occupy the same space on hdd
%
% Usage:
%>> put_dnd_methadata(obj)
%>> put_dnd_methadata(obj,'-update')
%>> put_dnd_methadata(obj,dnd_obj)
%>> put_dnd_methadata(obj,sqw_obj)
%

%
[ok,mess,update,argi]=parse_char_options(varargin,{'-update'});
if ~ok
    error('DND_BINFILE_COMMON:invalid_artgument',...
        ['put_dnd_methadata: Error: ',mess]);
end
% verify we use this method on an properly initialized file accessor
check_obj_initiated_properly_(obj);
%
if update % are we going to write new or update existing data
    head_arg = {'-head','-const'};
else
    head_arg = {'-head'};
end
%
data_form = obj.get_data_form(head_arg{:});
%
if isempty(argi)
    input_obj = obj.sqw_holder_;
else
    input_obj = argi{1};
    update = true;
end
if isa(input_obj,'sqw')
    input_obj = input_obj.data;
end

%
bytes = obj.sqw_serializer_.serialize(input_obj,data_form);
%
if update
    % identify the values of the first and last fields of format structure
    % in the structure, which describes the fields positions
    [fn_start,fn_end,is_last] = dnd_binfile_common.extract_field_range(...
        obj.data_fields_locations_,data_form);
    start_pos = obj.data_fields_locations_.(fn_start);
    if is_last
        end_pos = obj.s_pos_;
    else
        end_pos  = obj.data_fields_locations_.(fn_end);
    end
    sz = end_pos - start_pos;
    if numel(bytes) ~= sz
        error('DND_BINFILE_COMMON:runtime_error',...
            'Can not upgrade methadata as their disk size is different')
    end
end

fseek(obj.file_id_,obj.data_pos_,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the methadata record');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the dnd object methadata');





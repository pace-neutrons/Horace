function obj=put_dnd_metadata(obj,varargin)
% Write dnd metadata or upgrade existing metadata with new records, which
% occupy the same space on hdd
%
% Usage:
%>> put_dnd_metadata(obj)
%>> put_dnd_metadata(obj,'-update')
%>> put_dnd_metadata(obj,dnd_obj)
%>> put_dnd_metadata(obj,sqw_obj)
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%

% ignore nopix if it comes as input
[ok,mess,update,~,argi]=parse_char_options(varargin,{'-update','-nopix'});
if ~ok
    error('SQW_FILE_IO:invalid_artgument',...
        ['put_dnd_metadata: Error: ',mess]);
end
% verify we use this method on an properly initialized file accessor
check_obj_initiated_properly_(obj);
%
[input_obj,new_obj] = obj.extract_correct_subobj('data',argi{:});
if new_obj
    update = true;
end
%
if update % are we going to write new or update existing data
    head_arg = {'-head','-const'};
else
    head_arg = {'-head'};
end
%
data_form = obj.get_dnd_form(head_arg{:});
%
%
if update && ~obj.upgrade_mode
    error('SQW_FILE_IO:runtime_error',...
        'DND_BINFILE_COMMON::put_dnd_metadata : input object has not been initiated for update mode');
end

%
bytes = obj.sqw_serializer_.serialize(input_obj,data_form);
%
if update
    % identify the values of the first and last fields of format structure
    % in the structure, which describes the fields positions
    val = obj.upgrade_map_.cblocks_map('dnd_methadata');
    pos = val(1);
    sz = val(2);
    if numel(bytes) ~= sz
        error('SQW_FILE_IO:runtime_error',...
            'DND_BINFILE_COMMON::put_dnd_metadata: Can not upgrade metadata as their disk size is different from memory size')
    end
else
    pos = obj.data_pos_;
end

fseek(obj.file_id_,pos,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the metadata record');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the dnd object metadata');



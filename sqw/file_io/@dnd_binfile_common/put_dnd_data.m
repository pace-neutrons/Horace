function obj=put_dnd_data(obj,varargin)
% Write dnd image data, namely signal, error and npixs or upgrade existing 
% data with new records, which occupy the same space on hdd
%
% Usage:
%>>obj= put_dnd_data(obj)
%>>obj= put_dnd_data(obj,'-update')
%>>obj= put_dnd_data(obj,dnd_obj)
%>>obj= put_dnd_data(obj,sqw_obj)
%>>obj= put_dnd_data(obj,sqw_obj/dnd_obj, '-update')
%
% if only -update key is specified, the class has to be initialized by appropriate dnd object.

%
% $Revision$ ($Date$)
%

% ignore nopix if it come as input
[ok,mess,update,~,argi]=parse_char_options(varargin,{'-update','-nopix'});
if ~ok
    error('DND_BINFILE_COMMON:invalid_artgument',...
        ['put_dnd_metadata: Error: ',mess]);
end
% verify we use this method on an properly initialized file accessor
check_obj_initiated_properly_(obj);
%
%
%
[input_obj,new_obj] = obj.extract_correct_subobj('data',argi{:});
if new_obj
    update = true;
end
%
if update && ~obj.upgrade_mode
    error('SQW_FILE_IO:runtime_error',...
        'put_dnd_metadata : input object has not been initiated for update mode');
end

%
if update % are we going to write new or update existing data
    val = obj.upgrade_map_.cblocks_map('dnd_data');
    pos = val(1);
    cur_size = val(2);
    % evaluate size of the object, provided for upgrade.
    data_form = obj.get_dnd_form('-data');
    size_str = obj.sqw_serializer_.calculate_positions(data_form,input_obj,obj.s_pos_);
    sz = obj.dnd_eof_pos_ -size_str.s_pos_;
    if cur_size  ~= sz
        error('SQW_FILE_IO:runtime_error',...
            'put_dnd_data: Can not upgrade dnd data as current disk size is different from provided')
    end
else
    pos = obj.s_pos_;
end
%
% write signal, error and npix
fseek(obj.file_id_,pos,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the signal record');

fwrite(obj.file_id_,input_obj.s,'float32');
check_error_report_fail_(obj,'Error writing signal record');
fseek(obj.file_id_,obj.e_pos_,'bof');

check_error_report_fail_(obj,'Error moving to the beginning of the error record');
fwrite(obj.file_id_,input_obj.e,'float32');
check_error_report_fail_(obj,'Error writing error record');

fseek(obj.file_id_,obj.npix_pos_,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the npix record');
fwrite(obj.file_id_,input_obj.npix,'uint64');
check_error_report_fail_(obj,'Error writing npix record');



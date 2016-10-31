function obj=put_dnd_data(obj,varargin)
% Write dnd data or upgrade existing data with new records, which
% occupy the same space on hdd
%
% Usage:
%>> put_dnd_data(obj)
%>> put_dnd_data(obj,'-update')
%>> put_dnd_data(obj,dnd_obj)
%>> put_dnd_data(obj,sqw_obj)
%

%
[ok,mess,update,argi]=parse_char_options(varargin,{'-update'});
if ~ok
    error('DND_BINFILE_COMMON:invalid_artgument',...
        ['put_dnd_methad: Error: ',mess]);
end
% verify we use this method on an properly initialized file accessor
check_obj_initiated_properly_(obj);
%
%
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
if update % are we going to write new or update existing data
    data_form = obj.get_dnd_form('-data');
    size_str = obj.sqw_serializer_.calculate_positions(data_form,input_obj,obj.s_pos_);
    sz = size_str.dnd_eof_pos_ -size_str.s_pos_;
    cur_size = obj.dnd_eof_pos_-obj.s_pos_;
    if cur_size  ~= sz
        error('DND_BINFILE_COMMON:runtime_error',...
            'Can not upgrade dnd data as their disk size is different from existing')
    end
end
%
% write signal, error and npix
fseek(obj.file_id_,obj.s_pos_,'bof');
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



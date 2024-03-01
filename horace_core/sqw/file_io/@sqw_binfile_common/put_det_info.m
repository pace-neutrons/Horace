function   obj = put_det_info(obj,varargin)
% Save or replace main sqw header into properly initialized
% binary sqw file
%Usage:
%>>obj.put_main_header();
%>>obj.put_main_header('-update');
%>>obj.put_header(sqw_obj_new_source_for_update); -- updates main header
%                               information using new object as source
%
% If update options is selected, header have to exist. This option keeps
% existing file information untouched;

[ok,mess,update,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_BINFILE_COMMON:invalid_argument',mess);
end
%
obj=obj.check_obj_initated_properly();
%
% this now extracts the detector arrays from the faccess object
% rather than an old-style detpar struct
[detpar,new_obj] = obj.extract_correct_subobj('detpar',argi{:});
% but now converting to old detpar representation for old file format
% as the old file format presumably needs exactly that
detpar = detpar{1}.get_detpar_representation();
if new_obj
    update = true;
end

if update
    det_form = obj.get_detpar_form('-const');
else
    det_form = obj.get_detpar_form();
end


bytes = obj.sqw_serializer_.serialize(detpar,det_form);
if update
    if ~obj.upgrade_mode
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_det_info: input object has not been initiated for update mode');
    end
    val   = obj.upgrade_map_.cblocks_map('detpar');
    start_pos = val(1);
    sz = val(2);
    if sz ~= numel(bytes)
        error('SQW_FILE_IO:runtime_error',...
            'put_det_info: unable to update detectors as new data size is not equal to the existing space')
    end
else
    start_pos = obj.detpar_pos_;
end

try
    do_fseek(obj.file_id_,start_pos ,'bof');
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Error moving to the start of the detectors record');
    throw(exc.addCause(ME))
end
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the detectors information');

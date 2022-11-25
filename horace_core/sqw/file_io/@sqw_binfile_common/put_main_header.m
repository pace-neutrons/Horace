function   obj = put_main_header(obj,varargin)
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
%


[ok,mess,update,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_FILE_IO:runtime_error',...
        'SQW_BINFILE_COMMON:put_main_header: %s',mess);
end
%
obj.check_obj_initated_properly();
%
[main_header,new_obj] = obj.extract_correct_subobj('main_header',argi{:});
current_creation_date_defined = main_header.creation_date_defined;
if ~current_creation_date_defined
    main_header.creation_date = datetime('now');
end
if new_obj
    update = true;
end


if update
    head_form = obj.get_main_header_form('-const');
else
    head_form = obj.get_main_header_form();
end


if update && ~obj.upgrade_mode
    error('SQW_FILE_IO:runtime_error',...
        'put_main_header : input object has not been initiated for update mode');
end
% support upgrade mode. Do not modify main header creation date if it has
% not been modified before
if (update || ~obj.upgrade_headers_ ) && ~current_creation_date_defined
    head_form = struct('filename','','filepath','',...
        'title','','nfiles',int32(1));
end


bytes = obj.sqw_serializer_.serialize(main_header,head_form);
if update
    val = obj.upgrade_map_.cblocks_map('main_header');
    start_pos = val(1);
    sz = val(2);
    if sz ~= numel(bytes)
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'unable to update main header as new data size is not equal to the space remaining')
    end
else
    start_pos = obj.main_header_pos_;
end

try
    do_fseek(obj.file_id_,start_pos ,'bof');
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Error moving to the start of the main header position');
    throw(exc.addCause(ME))
end
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the main header information');

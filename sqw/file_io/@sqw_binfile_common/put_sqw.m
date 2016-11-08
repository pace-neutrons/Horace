function    obj = put_sqw(obj,varargin)
% Save sqw data into new binary file or fully overwrite an existing file
%
%
% $Revision$ ($Date$)
%
%
%
[ok,mess,update,argi]=parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_FILE_IO:invalid_artgument',...
        ['DND_BINFILE_COMMON::put_sqw Error: ',mess]);
end
%
if update
    if ~obj.upgrade_mode % set up info for upgrade mode and the mode itself
        obj.upgrade_mode = true;
    end
    %return update option to argument list
    argi{end+1} = '-update';
end

% store header, which describes file as sqw file
obj.put_app_header();
%
obj.put_main_header(argi{:});
%
obj.put_headers(argi{:});
%
obj.put_det_info(argi{:});
%
% write dnd image methadata
obj.put_dnd_methadata(argi{:});
% write dnd image data
obj.put_dnd_data(argi{:});
%
obj.put_pix(argi{:});

%
fseek(obj.file_id_,0,'eof');
obj.real_eof_pos_ = ftell(obj.file_id_);

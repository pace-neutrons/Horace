function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
% store header, which describes file as dnd file
%
%
% $Revision$ ($Date$)
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

obj.put_app_header();

% write dnd image methadata
obj.put_dnd_methadata(argi{:});
% write dnd image data
obj.put_dnd_data(argi{:});
%

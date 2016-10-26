function [ok,obj,mess]=should_load(obj,filename)
% check if this loader should load selected file
%
%Usage:
% [ok,obj] = obj.should_load(filename)
%
% where
% filename -- name of file to check
%
% Returns ok if this filename can be loaded
%
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%

if ~isnumeric(filename)
    [ok,mess,full_data_name] = check_file_exist(filename,'*');
else
    full_data_name = filename;
end
%
if ~ok
    mess = regexprep(mess,'[\\]','/');
    error('SQW_BINFILE_COMMON:invalid_arguments','should_load function: %s',mess);
end

[stream,fh] = dnd_file_interface.get_file_header(full_data_name);

% call child function to check if the stream should be loaded by
% appropriate loader
[ok,obj,mess]=obj.should_load_stream(stream,fh);


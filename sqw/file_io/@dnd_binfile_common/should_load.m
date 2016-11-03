function [ok,objinit,mess]=should_load(obj,filename)
% check if this loader should load selected file
%
%Usage:
% [ok,objinit,message] = obj.should_load(filename)
%
% where
% filename -- name of file to check
%
% Returns:
% ok          --  true if this filename can be loaded or
% objinit     --  initialized obj_init class containing initialization
%                 information of ok is true or empty of not
% mess        --  text containing additional information on reasons of false
%                 if ok is false. Empty if ok is true
%
% $Revision$ ($Date$)
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

[header,fh] = dnd_file_interface.get_file_header(full_data_name);

% call child function to check if the stream should be loaded by
% appropriate loader
[ok,objinit,mess]=obj.should_load_stream(header,fh);


function [ok,objinit,mess]=should_load(obj,filename)
% Check if this loader should load selected file
%
%Usage:
% [ok,objinit,message] = obj.should_load(filename)
%
% where
% filename -- name of file to check
%
% Returns:
% ok          --  true if this filename can be loaded or false if not.
% objinit     --  initialized obj_init class containing initialization
%                 information if ok is true or empty of not. See <a href="matlab:help('obj_init');">obj_init</a>
%                 class description for the details of the initialization
%                 information.
% mess        --  text containing additional information on reasons of false
%                 if ok is false. Empty if ok is true
%
% The method is simple wrapper which packs dnd_file_interface.get_file_header
% and this class should_load_stream method together.
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
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


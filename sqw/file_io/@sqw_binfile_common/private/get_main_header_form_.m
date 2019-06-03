function header = get_main_header_form_(varargin)
% Return the structure of the main header in the form it
% is written on hdd.
%
% Usage:
% >>header = obj.get_main_header_form();
% >>header = obj.get_main_header_form('-const');
%
% Second option returns only the fields which do not change if filename
% or title changes 
%
% Fields in file are:
% --------------------------
%   main_header.filename   Name of sqw file that is being read, excluding path
%   main_header.filepath   Path to sqw file that is being read, including terminating file separator
%   main_header.title      Title of sqw data structure
%   main_header.nfiles     Number of spe files that contribute
%
% The value of the fields define the number of dimensions of
% the data except strings, which defined by the string length
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%


[ok,mess,update]=parse_char_options(varargin,{'-const'});
if ~ok
    error('SQW_BINILE_COMMON:invalid_argument',mess);
end
if update
    header = struct('nfiles',int32(1));
else
    header = struct('filename','','filepath','','title','',...
        'nfiles',int32(1));
end

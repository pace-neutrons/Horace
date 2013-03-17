function [file_name,lext] = check_file_exist(file_name,supported_file_extensions)
% Function checks if file belongs to the group of files with specified extensions
% and exists regardless of the case of the file extension (on Unix)
%
%   >>[file_name,ext]=check_file_exist(file_name,{'.spe','.nxspe','.spe_h5'})
%   >>[file_name,ext]=check_file_exist('MAR10001.spe','.spe')
%
% Input:
% ------
%   file_name           The name of the file with full path, you want to check;
%   {'.a','.b','.c'}    List of the permitted extensions
%
% Output:
% -------
%   file_name           The name of existing file. If the file is not found with 
%                      the case of the input file_name, but found with other case
%                      for the constituent characters, the output name has the case
%                      of the found file.
%   ext                 Lower case extension of the existing file.

% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)

[filepath,filename,ext]=fileparts(strtrim(file_name));
lext = lower(ext);
if ~iscell(supported_file_extensions)
    supported_file_extensions={supported_file_extensions};
end
if ~ismember(supported_file_extensions,lext)
    error('CHECK_FILE_EXIST:wrong_argument',' cannot identify  the format of  the file %s, described by first argument',file_name);
end

% make the file independent on the extension case;
file_l =fullfile(filepath,[filename,lext]);
if ~exist(file_l,'file')
    if ispc
        error('CHECK_FILE_EXIST:wrong_argument',' can not find file: %s \n',file_name);
    end
    file_u=fullfile(filepath,[filename,upper(ext)]);
    if ~exist(file_u,'file');
        error('CHECK_FILE_EXIST:wrong_argument',' can not find file: %s, and extesnions: %s or %s',...
            fullfile(filepath,filename),lext,upper(ext));
    end
    file_name = file_u;
else
    file_name = file_l;
end

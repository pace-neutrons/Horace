function [file_name,lext] = check_file_exist(file_name,supported_file_extensions)
% function checks if file belongs to the group of files with specified extensions 
% and exist regardless of the case of the file extension
%
%usage:
%>>[file_name,ext]=check_file_exist(file_name,{'.spe','.nxspe','.spe_h5'})
%>>[file_name,ext]=check_file_exist('MAR10001.spe','.spe')
%Input:
% file_name:    the name of the file with full path, you want to check; 
% {'.a','.b','.c'}   list of the extensions the file with name above should have
%
% Output:
%file_name: the name of existing file; If the file is not found in case, specified as input argument, 
%           but found in other case, the output name have the case of the existing file. 
%ext        low case extension of the existing file.  
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%
[filepath,filename,ext]=fileparts(strtrim(file_name));  
lext = lower(ext);
if ~iscell(supported_file_extensions)
    supported_file_extensions={supported_file_extensions};
end
if ~ismember(supported_file_extensions,lext)
        error('CHECK_FILE_EXIST:wrong_argument',' can not indentify  the format of  the file %s, described by first argument',file_name);
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




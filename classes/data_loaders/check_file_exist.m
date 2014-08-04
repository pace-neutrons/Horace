function [ok,mess,file_name,lext] = check_file_exist(file_name,supported_file_extensions)
% Function checks if file belongs to the group of files with specified extensions
% and exists regardless of the case of the file extension (on Unix)
%
%   >>[ok,mess,file_name,ext]=check_file_exist(file_name,{'.spe','.nxspe','.spe_h5'})
%   >>[ok,mess,file_name,ext]=check_file_exist('MAR10001.spe','.spe')
%
% Input:
% ------
%   file_name           The name of the file with full path, you want to check;
%   {'.a','.b','.c'}    List of the permitted extensions
%
% Output:
% -------
%   file_name      The name of existing file. If the file is not found with
%                  the case of the input file_name, but found with other case
%                  for the constituent characters, the output name has the case
%                  of the found file.
%   ext            Lower case extension of the existing file.

% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)

if ~isa(file_name,'char')
    ok=false;
    mess = ' A file name should be a string';
    return
end


[filepath,filename,ext]=fileparts(strtrim(file_name));

file_name='';
lext = lower(ext);
if ~iscell(supported_file_extensions)
    supported_file_extensions={supported_file_extensions};
    % memfile always exist but found only when searchinf for all files    %
end
if ~(any(ismember(supported_file_extensions,lext)) || strncmp(supported_file_extensions{1},'*',1))
    ok = false;
    mess = [' The extension ',lext,' of file: ',filename,' is not among supported extensions'];
    return;
end

% make the file independent on the extension case;
file_l =fullfile(filepath,[filename,lext]);
if strcmp('.memfile',lext)
    ok = memfile_fs.instance().file_exist(filename);
    if ok
        mess='';
    else
        mess = ['*** Can not find file: ',file_l];
    end
    file_name=[filename,lext];
    return
end

% deal with normal files.
if ~exist(file_l,'file')
    if ispc
        ok = false;
        file_l= regexprep(file_l,'\\','/');
        mess = ['*** Can not find file: ',file_l];
        return;
    end
    file_u=fullfile(filepath,[filename,upper(ext)]);
    if ~exist(file_u,'file');
        ok = false;
        fp = regexprep(fullfile(filepath,filename),'\\','/');
        mess = ['*** Can not find file: ',fp,' with extensions: ',lext,' or ',upper(ext)];
        return;
    end
    file_name = file_u;
else
    file_name = file_l;
end
ok=true;
mess='';

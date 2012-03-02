function [file_out,ok,mess] = translate_read (file)
% Recursively resolve a global path or environment variable in a file name for reading.
%
%   >> file_out = translate_read (file)             % error thrown if not OK
%
%   >> [file_out,ok,mess] = translate_read (file)   % return ok flag and non-empty message if ~ok
%
% Global path or environment variable prefix indicted in the file name by the form 
%       inst_data:::my_file.dat
%  *OR* inst_data:my_file.dat

if ~isempty(file) && ischar(file) && size(file,1)==1 && numel(size(file))==2
    ind=strfind(file,':::');
    if ~isempty(ind) && numel(ind)==1 && ind>1 && length(file)>ind+2     % has form xxx:::yyy with xxx, yyy not empty
        pathname=file(1:ind-1);
        filename=file(ind+3:end);
        file_out=translate_read_private (pathname,filename);
    else
        ind=strfind(file,':'); 
        if ~isempty(ind) && numel(ind)==1 && ind>1 && length(file)>ind     % has form xxx:yyy with xxx, yyy not empty
            pathname=file(1:ind-1);
            filename=file(ind+1:end);
            file_out=translate_read_private (pathname,filename);
        else
            file_out='';
        end
    end
    % Unable to resolve global path or environment variable, so assume true file name (e.g. 'c:\temp\a.dat')
    if isempty(file_out)
        file_out=file;
        if ~(exist(file_out,'file')==2)
            file_out='';
            ok=false;
            mess=['Cannot find file: ',file];
            if nargout==1 && ~ok, error(mess); end  % If not given ok as output argument, fail if ~ok
            return
        end
    end
else
    file_out='';
    ok=false;
    mess='Filename input argument must be non-empty character string';
    if nargout==1 && ~ok, error(mess); end  % If not given ok as output argument, fail if ~ok
    return
end

if nargout>1, ok=true; mess=''; end

%--------------------------------------------------------------------------------------------------
function file_out = translate_read_private (pathname,filename)
% Resolve a global path or environment variable to find a file to be read
%
%   >> file_out = translate_read_private (pathname,filename)
%
% Resolves environment variables recursively, checking always if the name is a global variable
% first. This ensures consistency with treatment of global paths in e.g. getgpath
%
% Input:
% ------
%   pathname    Character string, to be interpreted as global variable or environment variable
%   filename    File name
%
% Output:
% -------
%   file_out    Translated file name; empty if none found

while true
    if existgpath(pathname)
        dir=getgpath(pathname,'full');
        break
    else
        dir=getenv(pathname);
        if ~isempty(dir)
            pathname=dir;
        else
            dir={pathname};
            break
        end
    end
end

for i=1:numel(dir)
    file_out=fullfile(dir{i},filename);
    if exist(file_out,'file')
        return
    end
end
file_out='';

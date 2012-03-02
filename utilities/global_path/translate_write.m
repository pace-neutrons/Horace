function [file_out,ok,mess] = translate_write (file)
% Recursively resolve a global path or environment variable in a file name for writing.
%
%   >> file_out = translate_write (file)            % error thrown if not OK
%
%   >> [file_out,ok,mess] = translate_write (file)  % return ok flag and non-empty message if ~ok
%
% Global path or environment variable prefix indicted in the file name by the form 
%       inst_data:::my_file.dat
%  *OR* inst_data:my_file.dat

if ~isempty(file) && ischar(file) && size(file,1)==1 && numel(size(file))==2
    ind=strfind(file,':::');
    if ~isempty(ind) && numel(ind)==1 && ind>1 && length(file)>ind+2     % has form xxx:::yyy with xxx, yyy not empty
        pathname=file(1:ind-1);
        filename=file(ind+3:end);
        file_out=translate_write_private (pathname,filename);
    else
        ind=strfind(file,':'); 
        if ~isempty(ind) && numel(ind)==1 && ind>1 && length(file)>ind     % has form xxx:yyy with xxx, yyy not empty
            pathname=file(1:ind-1);
            filename=file(ind+1:end);
            file_out=translate_write_private (pathname,filename);
        else
            file_out='';
        end
    end
    % Unable to resolve global path or environment variable, so assume true file name (e.g. 'c:\temp\a.dat')
    if isempty(file_out)
        file_out=file;  % assume file
        [pathname,filename,ext]=fileparts(file_out);
        if ~(isempty(pathname) || exist(pathname,'dir')==7)
            file_out='';
            ok=false;
            mess=['Cannot find folder to write file: ',file];
            if nargout==1 && ~ok, error(mess); end  % If not given ok as output argument, fail if ~ok
            return
        end
        if ~isvalidfilename(filename)
            file_out='';
            ok=false;
            mess=['Invalid file name or extension: ',file];
            if nargout==1 && ~ok, error(mess); end  % If not given ok as output argument, fail if ~ok
            return
        end
        if ~(isempty(ext)||(numel(ext)>1 && isvalidfileext(ext(2:end))))     % allow extension to be empty
            file_out='';
            ok=false;
            mess=['Invalid file name or extension: ',file];
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
function file_out = translate_write_private (pathname,filename)
% Resolve a global path or environment variable to find a location for a file to be written
%
%   >> file_out = translate_write_private (pathname,filename)
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
%   file_out    Translated file name; empty if no output location found

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
    if exist(dir{i},'dir')
        file_out=fullfile(dir{i},filename);
        return
    end
end
file_out='';

%-------------------------------------------------------------------------------------------
function ok=isvalidfilename(str)
% Check if valid file name
%
%   >> ok=isvalidfilename(str)
%
% Depending on operating system, certain non-alphanumeric characters may be
% permitted in file names
%
% *** CURRENTLY A DUMMY FUNCTION

ok=true;

%-------------------------------------------------------------------------------------------
function ok=isvalidfileext(str)
% Check if valid file extension
%
%   >> ok=isvalidfileext(str)
%
% Depending on operating system, certain non-alphanumeric characters may be
% permitted in file names
%
% *** CURRENTLY A DUMMY FUNCTION

ok=true;

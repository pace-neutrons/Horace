function [mess, position] = put_application (fid, application)
% Write application information data strcuture to file
%
%   >> [mess, position] = put_application (fid, application)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   application     Data structure with fields below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position of the start of the application block
%
%
% Fields written to file are:
% ---------------------------
%   application.name        Name of application that wrote the file
%   application.version     Version of the application
%   application.file_format Version of the file format


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = ftell(fid);

file_format=application.file_format;
ver3p1=appversion(3.1);

try
    % Write application name
    % ----------------------
    % Must stick with the following write format for name and version for get_application to work
    n=length(application.name);
    fwrite(fid,n,'int32');              % write length of name
    fwrite(fid,application.name,'char*1');

    % Write application version and file format
    % -----------------------------------------
    % The file format version must be written and read in version 3.1 form in all future releases
    if file_format>=ver3p1
        flag=-1;    % -1 indicates change from numeric to character string version format
        fwrite(fid,flag,'float64');
        write_sqw_var_char (fid, ver3p1, version_str(application.version));
        write_sqw_var_char (fid, ver3p1, version_str(file_format));
    else
        % Horace version and file format version assumed to be the same for Horace v3 and below
        % Can only be '-v3' or '-v1' file format; 
        fmt_num=version_num(file_format);
        fwrite(fid,fmt_num(1),'float64');  
    end
    
catch
    mess='Error writing application block to file';
end

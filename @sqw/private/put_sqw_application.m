function [mess, pos_start] = put_sqw_application (fid, application)
% Write application information data strcuture to file
%
%   >> [mess, pos_start] = put_sqw_application (fid, application)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   application     Data structure with fields below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   pos_start       Position of the start of the application block
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
pos_start = ftell(fid);

ver3p1=appversion(3,1);
len_ch=256; % fixed length of character string
try
    % Write application name
    % ----------------------
    % Must stick with the following write format for name and version for get_sqw_application to work
    n=length(application.name);
    fwrite(fid,n,'int32');              % write length of name
    fwrite(fid,application.name,'char*1');

    % Write application version and file format
    % -----------------------------------------
    % The file format version must be written and read in version 3.1 form in all future releases
    if application.file_format>=ver3p1
        flag=-1;    % -1 indicates change from numeric to character string version format
        fwrite(fid,flag,'float64');
        write_sqw_var_char (fid, ver3p1, version_str(application.version), len_ch);
        write_sqw_var_char (fid, ver3p1, version_str(application.file_format), len_ch);
    else
        % Horace version and file format version assumed to be the same for Horace v3 and below
        % Can only be '-v3' or '-v1' file format; 
        fmt_num=version_num(application.file_format);
        if fmt_num(1)==3
            fwrite(fid,3,'float64');
        else
            fwrite(fid,2,'float64');    % Horace version 2 was the stable release version
        end
    end
    
catch
    mess='Error writing application block to file';
end

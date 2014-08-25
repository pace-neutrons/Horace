function [mess, application, pos_start] = get_sqw_application (fid, expected_name)
% Read the application block that gives information about the application that wrote the file
%
%   >> [mess, application, pos_start] = get_sqw_application (fid, expected_name)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   expected_name   Expected application name. An error is returned
%                  if the application name recorded in the file does not match
%                  the expected name
%
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   application     Structure containing fields read from file (details below)
%   pos_start       Position of the start of the application block
%
%
% Fields read from file are:
% --------------------------
%   application.name        Name of application that wrote the file
%   application.version     Version of the application (appversion object)
%   application.file_format Version of file format (appversion object)
%
%
% NOTE: The prototype file format ('-v0') is not directly recognised, but is
%       assigned if the first entry is a double followed by a character string
%       of that length. An informatinal message is given.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
pos_start = ftell(fid);

% Read data from file. We require:
% (1) the application name is a valid variable name
% (2) the version to be real and greater or equal to zero
try
    n = fread (fid,1,'int32');
    % Need to try to catch case of e.g. text file where number of characters is read as a stupidly high number
    if n>0 && n<4096   % allow up to 4096 characters
        
        % Get application name
        % --------------------
        name = fread (fid,[1,n],'*char*1');
        if strcmpi(name,expected_name)
            application.name = name;
        else
            % Prototype version happens to start with a file name. Try this.
            disp('File does not have one of the current Horace data file formats. Attempting to read as prototype format Horace .sqw file...')
            application.name = expected_name;
            application.version = appversion(0);
            application.file_format = appversion(0);
            fseek(fid,pos_start,'bof');          % return to position in file that entered this function
        end
        
        % Get application version number
        % ------------------------------
        ver_num = fread (fid,1,'float64');
        ver3p1=appversion(3,1);
        
        if ~isscalar(ver_num) || ver_num<-1 || ver_num>99999999
            mess = 'Version must be greater or equal to zero';
            application = [];
            return
        end
        if ver_num==-1
            % New formt; must read as version 3.1 format
            ver_str = read_sqw_var_char(fid, ver3p1);
            application.version = appversion(ver_str);
        else
            % Will only be version 1 or 3
            application.version = appversion(ver_num);
        end
        
        % Get file format version
        % -----------------------
        % File format entry needs to be read in the format saved by the '-v3.1' file format,
        % even for versions after 3.1, for the file to be properly interpreted.
        % For Horace versions prior to 3.1 file format is constructed from the Horace version number
        if application.version>=ver3p1
            % File format version stored from Horace 3.1 onwards
            fmt_str = read_sqw_var_char(fid, ver3p1);
            application.file_format = appversion(fmt_str);
        else
            % File format version is '-v1' (Hoace 1,2) or '-v3' (Horace 3) for earlier versions
            if ver_num==3
                application.file_format = appversion(3);
            else
                application.file_format = appversion(1);
            end
        end
            
    else
        mess = 'Unrecognised format for application and version';
        application = [];
        return
    end
    
catch
    mess='Problems reading application information from file';
    application = [];

end

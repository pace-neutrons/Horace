function [mess, application, position] = get_application (fid, expected_name)
% Read the application block that gives information about the application that wrote the file
%
%   >> [mess, application, position] = get_application (fid)
%   >> [mess, application, position] = get_application (fid, expected_name)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   expected_name   [Optional] Expected application name. An error is returned
%                  if the application name recorded in the file does not match
%                  the expected name
%
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   application     Structure containing fields read from file (details below)
%   position        Position of the start of the application block
%
%
% Fields read from file are:
% --------------------------
%   application.name        Name of application that wrote the file
%   application.version     Version number of the application


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
application = [];
position = ftell(fid);

% Read data from file. We require:
% (1) the application name is a valid variable name
% (2) the version to be real and greater or equal to zero
try
    n = fread (fid,1,'int32');
    % Need to try to catch case of e.g. text file where n is read as a stupidly high number
    if n>0 && n<1024   % allow up to 1024 characters
        name = fread (fid,[1,n],'*char');
        if ~isvarname(name)
            mess = 'Application name must be a valid Matlab variable name'; return
        else
            if nargin==2 && ~strcmpi(name,expected_name)
                mess = 'Application name recorded in file does not match the expected name'; return
            end
        end
        version = fread (fid,1,'float64');
        if ~isscalar(version) || version<0 || version>99999999
            mess = 'Version must be greater or equal to zero'; return
        end
        application.name = name;
        application.version = version;
    else
        mess = 'Unrecognised format for application and version'; return
    end
    
catch
    mess='Problems reading application information from file';
end

function [application, mess] = get_application (fid, application_in)
% Read the application block that gives information about the applciation that wrote the file
%
%   >> [application, mess] = get_application (fid)
%   >> [application, mess] = get_application (fid, application_in)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   application_in  [optional] Data structure to which the data
%                  fields below will be added or overwrite.
%
% Output:
% -------
%   application     Structure containing fields read from file (details below)
%   mess            Error message; blank if no errors, non-blank otherwise
%
% Fields read from file are:
%   application.name        Name of application that wrote the file
%   application.version     Version number of the application


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if nargin==2
    if isstruct(application_in)
        application = application_in;
    else
        application = [];
        mess = 'Check the type of input argument application_in';
        return
    end
end

% Read data from file. We require:
% (1) the application name is a valid variable name
% (2) the version to be real and greater or equal to zero

try
    n = fread (fid,1,'int32');
    % Need to try to catch case of e.g. text file where n is read as a stupidly high number
    if n>0 && n<1024   % allow up to 1024 characters
        name = fread (fid,[1,n],'*char');
        if ~isvarname(name)
            application = []; mess = 'Application name must be a valid Matlab variable name'; return
        end
        version = fread (fid,1,'float64');
        if ~isscalar(version) || version<0
            application = []; mess = 'Version must be greater or equal to zero'; return
        end
        application.name = name;
        application.version = version;
        mess='';
    else
        application = []; mess = 'Unrecognised format for application and version'; return
    end
    
catch
    application = []; mess='Problems reading data file';
end

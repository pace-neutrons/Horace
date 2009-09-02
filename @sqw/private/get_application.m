function [application, mess] = get_application (fid, application_in)
% Read the application block that gives information about the applciation that wrote
% the file
%
% Syntax:
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

% Generalise (with put_application) to read field names, together with
% precisions and sizes, then branch on this info. For now, just write name
% and version.

if nargin==2
    if isstruct(application_in)
        application = application_in;
    else
        application = [];
        mess = 'Check the type of input argument application_in';
        return
    end
else
    application = [];
end

mess='';

% Read data from file:
try
    n = fread (fid,1,'int32');
    application.name = fread (fid,[1,n],'*char');
    application.version = fread (fid,1,'float64');
catch
    mess='problems reading data file';
end

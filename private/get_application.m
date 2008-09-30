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
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

% Generalise (with put_application) to read field names, together with
% precisions and sizes, then branch on this info. For now, just write name
% and version.

if nargin==2
    if isstruct(application_in)
        application = application_in;
    else
        mess = 'Check the type of input argument application_in';
        return
    end
else
    application = [];
end

% Read data from file:
[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[application.name, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[application.version, count, ok, mess] = fread_catch(fid,1,'float64'); if ~all(ok); return; end;

function mess = put_application (fid, application)
% Write application information data strcuture to file
%
%   >> mess = put_application (application)
%
% Input:
%   fid             File identifier of output file (opened for binary writing)
%   application     Data structure with fields below
%
% Output:
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields written to file are:
%   application.name        Name of application that wrote the file
%   application.version     Version number of the application

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Generalise (with put_application) to write field names, together with
% precisions and sizes, then branch on this info. For now, just write name
% and version.

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file
n=length(application.name);
fwrite(fid,n,'int32');              % write length of name
fwrite(fid,application.name,'char');

fwrite(fid,application.version,'float64');

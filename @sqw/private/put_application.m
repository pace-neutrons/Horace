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
%   application.version     Version number of the application


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = ftell(fid);

try
    n=length(application.name);
    fwrite(fid,n,'int32');              % write length of name
    fwrite(fid,application.name,'char');
    
    fwrite(fid,application.version,'float64');
    
catch
    mess='Error writing application block to file';
end

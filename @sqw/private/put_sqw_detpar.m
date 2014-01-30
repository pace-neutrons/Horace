function [mess, position] = put_sqw_detpar (fid, det)
% Write detector information to binary file.
%
%   >> [mess, position] = put_sqw_detpar (fid, det)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   det             Structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position of start of detector parameter block
%
%
% Fields written to file are:
% ---------------------------
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number
%   det.x2          Row vector of secondary flightpath (m)
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)
%
%
% Notes:
% ------
% The list of detector information will in general be the
% accumulation of unique detector elements in a series of .spe files. For the
% moment we assume that the detectors are the same for all .spe files that are
% written to the binary file. At a later date we may want to introduce a unique
% detector group for the general case.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = ftell(fid);

try
    n=length(det.filename);
    fwrite(fid,n,'int32');
    fwrite(fid,det.filename,'char');
    
    n=length(det.filepath);
    fwrite(fid,n,'int32');
    fwrite(fid,det.filepath,'char');
    
    ndet=size(det.x2,2);    % no. detectors
    fwrite(fid,ndet,'int32');
    
    fwrite(fid,det.group,'float32');
    fwrite(fid,det.x2,'float32');
    fwrite(fid,det.phi,'float32');
    fwrite(fid,det.azim,'float32');
    fwrite(fid,det.width,'float32');
    fwrite(fid,det.height,'float32');
catch
    mess='Error writing detector parameter block to file';
end

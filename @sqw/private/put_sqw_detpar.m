function mess = put_sqw_detpar (fid, det)
% Write detector information to binary file. 
%
%   >> mess = put_sqw_detpar (fid, par)
%
% Input:
%   fid             File identifier of output file (opened for binary writing)
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields written to file are:
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
% Notes:
% ------
% The list of detector information will in general be the
% accumulation of unique detector elements in a series of .spe files. For the
% moment assume that the detectors are the same for all .spe files that are
% written to the binary file. We may want to introduce a unique detector group
% for the general case.

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file
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

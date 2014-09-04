function [mess, det] = get_sqw_detpar (fid, fmt_ver)
% Read the detector parameter from a binary file.
%
%   >> [mess, det] = get_sqw_detpar (fid, fmt_ver)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   fmt_ver         Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   det             Structure containing fields read from file (details below)
%
%
% Fields read from file are:
% --------------------------
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number
%   det.x2          Row vector of secondary flightpath (m)
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


mess='';

[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);

try
    det.filename = read_sqw_var_char (fid, fmt_ver);
    det.filepath = read_sqw_var_char (fid, fmt_ver);
    
    ndet = fread(fid, 1, fmt_int);
    det.group  = fread(fid, [1,ndet], fmt_dble);
    det.x2     = fread(fid, [1,ndet], fmt_dble);
    det.phi    = fread(fid, [1,ndet], fmt_dble);
    det.azim   = fread(fid, [1,ndet], fmt_dble);
    det.width  = fread(fid, [1,ndet], fmt_dble);
    det.height = fread(fid, [1,ndet], fmt_dble);
    
catch
    mess='Error reading detector parameter block from file';
    det = [];

end

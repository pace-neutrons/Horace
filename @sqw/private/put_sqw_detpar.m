function [mess, pos_start] = put_sqw_detpar (fid, fmt_ver, det)
% Write detector information to binary file.
%
%   >> [mess, pos_start] = put_sqw_detpar (fid, fmt_ver, det)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   det             Structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   pos_start       Position of start of detector parameter block
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
pos_start = ftell(fid);

[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);
len_name_max=1024;  % fixed length of name string
try
    write_sqw_var_char (fid, fmt_ver, det.filename, len_name_max);
    write_sqw_var_char (fid, fmt_ver, det.filepath, len_name_max);
    
    ndet=size(det.x2,2);    % no. detectors
    fwrite(fid,ndet,fmt_int);
    
    fwrite(fid, det.group,  fmt_dble);
    fwrite(fid, det.x2,     fmt_dble);
    fwrite(fid, det.phi,    fmt_dble);
    fwrite(fid, det.azim,   fmt_dble);
    fwrite(fid, det.width,  fmt_dble);
    fwrite(fid, det.height, fmt_dble);
    
catch
    mess='Error writing detector parameter block to file';
end

function [mess, fmt, pos_start] = get_sqw_fmt (fid, fmt_ver)
% Get the formats of various key arrays in the sqw file
%
%   >> [mess, fmt, pos_start] = get_sqw_fmt (fid, fmt_ver)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%   fmt         Structure with information about format of key arrays
%   position    Position of the start of the information block
%
%
% Fields read from file are:
% --------------------------
%   fmt.s           Format of array s
%   fmt.e           Format of array e
%   fmt.npix        Format of array npix (='' if npix not written)
%   fmt.urange      Format of array urange (='' if urange not written)
%   fmt.npix_nz     Format of array npix_nz (='' if npix_nz not written)
%   fmt.pix_nz      Format of array pix_nz (='' if pix_nz not written)
%   fmt.pix         Format of array pix  (='' if pix not written)


% Original author: T.G.Perring
%
% $Revision: 880 $ ($Date: 2014-07-16 08:18:58 +0100 (Wed, 16 Jul 2014) $)

mess = '';
pos_start = ftell(fid);

try
    fmt = struct('s',[],'e',[],'npix',[],'urange',[],'npix_nz',[],'pix_nz',[],'pix',[]);
    nam=fieldnames(fmt);
    for i=1:numel(nam)
        fmt.(nam(i)) = read_sqw_var_char (fid, fmt_ver);
    end
    
catch
    mess = 'Unable to read position information from file';
    fmt=[];
    
end

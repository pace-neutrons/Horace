function [mess, pos_start] = put_sqw_fmt (fid, fmt_ver, fmt)
% Write some key information about the sqw file
%
%   >> [mess, pos_start] = put_sqw_fmt (fid, fmt_ver, fmt)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver     Version of file format e.g. appversion('-v3')
%   fmt         Structure with information about format of key arrays
%
% Output:
% -------
%   mess        Error message; blank if no errors, non-blank otherwise
%   pos_start   Position of the start of this block
%
%
% Fields written to file are:
% ---------------------------
%   fmt.s           Format of array s
%   fmt.e           Format of array e
%   fmt.npix        Format of array npix (='' if npix not written)
%   fmt.urange      Format of array urange (='' if urange not written)
%   fmt.npix_nz     Format of array npix_nz (='' if npix_nz not written)
%   fmt.pix_nz      Format of array pix_nz (='' if pix_nz not written)
%   fmt.pix         Format of array pix  (='' if pix not written)


% Original author: T.G.Perring
%
% $Revision: 885 $ ($Date: 2014-07-29 17:35:24 +0100 (Tue, 29 Jul 2014) $)


mess='';
pos_start = ftell(fid);

len_ch=256;  % fixed length of character string
try
    nam=fieldnames(fmt);
    for i=1:numel(nam)
        write_sqw_var_char (fid, fmt_ver, fmt.(nam{i}), len_ch);
    end

catch
    mess='Error writing format summary block to file';
end

function [mess, pos_start] = put_sqw_info (fid, fmt_ver, info)
% Write some key information about the sqw file
%
%   >> [mess, pos_start] = put_sqw_info (fid, fmt_ver, info)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver     Version of file format e.g. appversion('-v3')
%   info        Structure with various basic pieces of information about the file contents:
%
% Output:
% -------
%   mess        Error message; blank if no errors, non-blank otherwise
%   pos_start   Position of the start of this block
%
%
% Fields written to file are:
% ---------------------------
%   info.sparse      =true if signal fields are in sparse format; =false otherwise
%   info.sqw_data    =true if file contains valid sqw data (i.e. dnd-type or sqw-type data)
%   info.sqw_type    Type of sqw object written to file: =true if sqw-type; =false if dnd-type
%   info.buffer_type   =true if npix-and-pix buffer file; =false if not
%   info.nfiles      sqw-type: Number of contributing spe data sets; dnd-type: =NaN
%                    buffer:   Number of spe files if sparse; non-sparse then =NaN
%   info.ne          sqw-type: Column vector of no. energy bins in each spe file; dnd-type: =NaN
%                    buffer:   Column vector of no. energy bins if sparse; =NaN if non-sparse
%   info.ndet        sqw-type: Number of detectors; dnd-type: =NaN
%                    buffer:   Number of detectors if sparse; =NaN if non-sparse
%   info.ndims       Number of dimensions of npix array
%   info.sz_npix     Number of bins along each dimension ([1,4] array; excess elements = NaN)
%   info.npixtot     Total number of pixels
%   info.npixtot_nz  Total number of non-zero signal pixels


% Original author: T.G.Perring
%
% $Revision: 885 $ ($Date: 2014-07-29 17:35:24 +0100 (Tue, 29 Jul 2014) $)


mess='';
pos_start = ftell(fid);

try
    tmp=[double(info.sparse),double(info.sqw_data),double(info.sqw_type),double(info.buffer_type),...
        info.nfiles, info.ne, info.ndet, info.ndims, info.sz_npix, info.npixtot, info.npixtot_nz];
    fwrite(fid, numel(tmp), 'float64');
    fwrite(fid, tmp, 'float64');

catch
    mess='Error writing contents information summary block to file';
end

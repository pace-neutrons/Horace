function [mess, info] = get_sqw_info (fid, fmt_ver)
% Read some key information about the sqw file
%
%   >> [mess, info] = get_sqw_info (fid, fmt_ver)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   mess        Error message; blank if no errors, non-blank otherwise
%   info        Structure with various basic pieces of information about the file contents:
%
%
% Fields read from file are:
% --------------------------
%   info.sparse      =true if signal fields are in sparse format; =false otherwise
%   info.sqw_data    =true if file contains valid sqw data (i.e. dnd-type or sqw-type data)
%   info.sqw_type    Type of sqw object written to file: =true if sqw-type; =false if dnd-type
%   info.buffer_type =true if npix-and-pix buffer file; =false if not
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

try
    n = fread(fid,1,'float64');
    tmp = fread(fid,[1,n],'float64');
    info=struct('sparse',logical(tmp(1)),'sqw_data',logical(tmp(2)),...
        'sqw_type',logical(tmp(3)),'buffer_type',logical(tmp(4)),...
        'nfiles',tmp(5),'ne',tmp(6:end-8),'ndet',tmp(end-7),'ndims',tmp(end-6),'sz_npix',tmp(end-5:end-2),'npixtot',tmp(end-1),'npixtot_nz',tmp(end));
    
catch
    mess='Error reading contents information summary block from file';
    info=[];
    
end

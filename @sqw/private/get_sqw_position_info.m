function [mess, position] = get_sqw_position_info (fid)
% Get the positions of the various key data blocks in the sqw file
%
%   >> [mess, position] = get_sqw_position_info (fid)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Structure containing fields read from file (details below)
%
%
% Fields read from file are: 
% --------------------------
%   position.main_header    start of main_header block (=[] if not written)
%   position.header         start of each header block (column vector, length main_header.nfiles)
%                          (=[] if not written)
%   position.detpar         start of detector parameter block (=[] if not written)
%   position.data           start of data block
%   position.s              position of array s
%   position.e              position of array e
%   position.npix           position of array npix (=[] if npix not written)
%   position.urange         position of array urange (=[] if urange not written)
%   position.npix_nz        position of array npix_nz (=[] if npix_nz not written)
%   position.ipix_nz        position of array ipix_nz (=[] if ipix_nz not written)
%   position.pix_nz         position of array pix_nz (=[] if pix_nz not written)
%   position.pix            position of array pix  (=[] if pix not written)
%   position.instrument     start of header instrument blocks (=[] if not written)
%   position.sample         start of header sample blocks (=[] if not written)
%   position.position_info  start of the position block


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = [];

try
    position = get_variable_from_binfile(fid);
catch
    mess = 'Unable to read position information from file';
end

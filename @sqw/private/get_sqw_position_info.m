function [data, mess] = get_sqw_position_info (fid)
% Get the positions of the various key data blocks in the sqw file
%
%   >> [data, mess] = get_sqw_position_info (fid)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   data            Structure containing fields read from file (details below)
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields read from file are: 
%   data.main_header    start of main_header block (=[] if not written)
%   data.header         start of each header block (column vector, length main_header.nfiles)
%                      (=zeros(0,1) if not written)
%   data.detpar         start of detector parameter block (=[] if not written)
%   data.data           start of data block
%   data.s              position of array s
%   data.e              position of array e
%   data.npix           position of array npix (=[] if npix not written)
%   data.urange         position of array urange (=[] if urange not written)
%   data.pix            position of array pix  (=[] if pix not written)
%   data.header_opt     start of each header optional block (column vector, length main_header.nfiles)
%                      (=zeros(0,1) if not written)
%   data.position_info  position of start of the position block


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

data = [];
mess = '';

try
    data = get_variable_from_binfile(fid);
catch
    mess = 'Unable to read position information from file';
end

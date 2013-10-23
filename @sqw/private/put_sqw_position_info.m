function mess = put_sqw_position_info (fid, data)
% Write the positions of the various key data blocks in the sqw file
%
%   >> mess = put_sqw_position_info (fid, data)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields written to file are: 
%   data.main_header    start of main_header block (=[] if not written)
%   data.header         start of each header block (column vector, length main_header.nfiles)
%                          (=zeros(0,1) if not written)
%   data.detpar         start of detector parameter block (=[] if not written)
%   data.data           start of data block
%   data.s              position of array s
%   data.e              position of array e
%   data.npix           position of array npix (=[] if npix not written)
%   data.urange         position of array urange (=[] if urange not written)
%   data.pix            position of array pix  (=[] if pix not written)
%   data.header_opt     start of each header optional block (column vector, length main_header.nfiles)
%                          (=zeros(0,1) if not written)
%   data.position_info  position of start of the position block


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file
try
    put_variable_to_binfile(fid,data)
catch
    mess='Unable to write position information to file';
end

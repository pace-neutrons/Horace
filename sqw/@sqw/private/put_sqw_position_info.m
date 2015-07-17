function [mess, position] = put_sqw_position_info (fid, position_in, update)
% Write the positions of the various key data blocks in the sqw file
%
%   >> [mess, position] = put_sqw_position_info (fid, position_in, update)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   position_in     Structure which must contain (at least) the fields listed below
%   update          If false, then write the field 'position_info' as stored in position_in
%                   If true, then update position_info as the current position in the file
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position structure with field position_info updated to the
%                  true value determined in this function
%
%
% Fields written to file are: 
% ---------------------------
%   position.main_header    start of main_header block (=[] if not written)
%   position.header         start of each header block (column vector, length main_header.nfiles)
%                          (=[] if not written)
%   position.detpar         start of detector parameter block (=[] if not written)
%   position.data           start of data block
%   position.s              position of array s
%   position.e              position of array e
%   position.npix           position of array npix (=[] if npix not written)
%   position.urange         position of array urange (=[] if urange not written)
%   position.pix            position of array pix  (=[] if pix not written)
%   position.instrument     start of header instrument blocks (=[] if not written in the file)
%   position.sample         start of header sample blocks (=[] if not written in the file)
%   position.position_info  start of the position block


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position=position_in;
if update
    position.position_info=ftell(fid);
end

try
    put_variable_to_binfile(fid,position)
catch
    mess='Unable to write position information to file';
end

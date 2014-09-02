function [mess, pos_start] = put_sqw_position (fid, fmt_ver, position, update)
% Write the positions of the various key data blocks in the sqw file
%
%   >> [mess, position] = put_sqw_position (fid, fmt_ver, position_in, update)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   position        Structure which must contain (at least) the fields listed below
%   update          [Optional] Control the value of the field 'position' in the structure:
%                    - if false, then write the field 'position' as stored in position
%                    - if true,  then update the field 'position' to the current position
%                                in the file before writing to file [default]
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   pos_start       Position of the start of the position block
%
%
% Fields written to file are:
% ---------------------------
%   position.application    start of application block (for prototype file format is NaN)
%   position.info           start of info block (for file formats prior to 3.1 is NaN)
%   position.position       start of position block (for file formats prior to 3.1 is NaN)
%   position.fmt            start of format block (for file formats prior to 3.1 is NaN)
%   position.main_header    start of main_header block (=NaN if not written)
%   position.header         start of header block (=NaN if not written)
%   position.instrument     start of header instrument blocks (=NaN if not written)
%   position.sample         start of header sample blocks (=NaN if not written)
%   position.detpar         start of detector parameter block (=NaN if not written)
%   position.data           start of data block
%   position.s              position of array s
%   position.e              position of array e
%   position.npix           position of array npix
%   position.urange         position of array urange (=NaN if urange not written)
%   position.npix_nz        position of array npix_nz (=NaN if npix_nz not written)
%   position.pix_nz         position of array pix_nz (=NaN if pix_nz not written)
%   position.pix            position of array pix  (=NaN if pix not written)


% Original author: T.G.Perring
%
% $Revision: 880 $ ($Date: 2014-07-16 08:18:58 +0100 (Wed, 16 Jul 2014) $)


mess = '';
pos_start = ftell(fid);

try
    position_tmp=position;
    if nargin==3 || update
        position_tmp.position=pos_start;
    end
    
    nam=fieldnames(position_tmp);
    tmp=NaN(1,numel(nam));
    for i=1:numel(nam)
        tmp(i)=position_tmp.(nam(i));
    end
    fwrite(fid, numel(tmp), 'float64')
    fwrite(fid, tmp, 'float64');
    
catch
    mess='Unable to write position information to file';
end

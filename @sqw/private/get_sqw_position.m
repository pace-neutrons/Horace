function [mess, position, pos_start] = get_sqw_position (fid, fmt_ver)
% Get the positions of the various key data blocks in the sqw file
%
%   >> [mess, position] = get_sqw_position (fid, fmt_ver)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   fmt_ver         Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Structure containing fields read from file (details below)
%   pos_start       Position of the start of the position block
%
%
% Fields read from file are:
% --------------------------
%   position.application    start of application block
%   position.info           start of info block
%   position.position       start of position block
%   position.fmt            start of format block
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
    position=struct('application',NaN,'info',NaN,'position',NaN,'fmt',NaN,...
        'main_header',NaN,'header',NaN,'instrument',NaN,'sample',NaN,'detpar',NaN,'data',NaN,...
        's',NaN,'e',NaN,'npix',NaN,'urange',NaN,'npix_nz',NaN,'pix_nz',NaN,'pix',NaN);
    n = fread(fid,1,'float64');
    tmp = fread(fid,[1,n],'float64');
    
    nam=fieldnames(position);
    for i=1:numel(nam)
        position.(nam(i))=tmp(i);
    end
    
catch
    mess = 'Unable to read position information from file';
    position = [];
    
end

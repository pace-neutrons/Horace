function S = sqwfile
% Create an sqwfile structure
%
%   >> S = sqwfile
%
%
% sqwfile fields:
% ---------------
%   fid         File identifier
%   filename    Name of file
%
%   application.name        Name of application that wrote the file
%   application.version     Version number of the application
%   application.file_format Version of file format (appversion object)
%
%   info.sparse      =true if signal fields are in sparse format; =false otherwise
%   info.sqw_data    =true if file contains valid sqw data (i.e. dnd-type or sqw-type data)
%   info.sqw_type    Type of sqw object written to file: =true if sqw-type; =false if dnd-type
%   info.buffer_type =true if npix-and-pix buffer file; =false if not
%   info.ndims       Number of dimensions of npix array
%   info.nfiles      Number of contributing spe data sets (=0 if not sqw-type; =NaN if buffer file)
%   info.sz_npix     Number of bins along each dimension ([1,4] array; excess elements = NaN)
%   info.npixtot     Total number of pixels
%   info.npixtot_nz  Total number of non-zero signal pixels
%   
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
%   position.npix           position of array npix (=NaN if npix not written)
%   position.urange         position of array urange (=NaN if urange not written)
%   position.npix_nz        position of array npix_nz (=NaN if npix_nz not written)
%   position.pix_nz         position of array pix_nz (=NaN if pix_nz not written)
%   position.pix            position of array pix  (=NaN if pix not written)
%
%   fmt.s           Format of array s
%   fmt.e           Format of array e
%   fmt.npix        Format of array npix
%   fmt.urange      Format of array urange (='' if urange not written)
%   fmt.npix_nz     Format of array npix_nz (='' if npix_nz not written)
%   fmt.pix_nz      Format of array pix_nz (='' if pix_nz not written)
%   fmt.pix         Format of array pix  (='' if pix not written)

S.fid=-1;
S.filename='';

S.application=struct('name','','version',appversion(0),'file_format',appversion(0));

S.info=struct('sparse',false,'sqw_data',false,'sqw_type',false,'buffer_type',false,...
    'ndims',NaN,'nfiles',NaN,'sz_npix',NaN(1,4),'npixtot',NaN,'npixtot_nz',NaN);

S.position = struct('application',NaN,'info',NaN,'position',NaN,'fmt',NaN,...
    'main_header',NaN,'header',NaN,'instrument',NaN,'sample',NaN,'detpar',NaN,'data',NaN,...
    's',NaN,'e',NaN,'npix',NaN,'urange',NaN,'npix_nz',NaN,'pix_nz',NaN,'pix',NaN);

S.fmt = struct('s','','e','','npix','','urange','','npix_nz','','pix_nz','','pix','');

S=class(S,'sqwfile');

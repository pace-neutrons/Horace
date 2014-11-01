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
%   info.buffer_data =true if npix-and-pix buffer file; =false if not
%   info.nfiles      sqw-type: Number of contributing spe data sets; dnd-type: =NaN
%                    buffer:   1 (single spe) or NaN (multiple spe) if sparse; non-sparse then =NaN
%   info.ne          sqw-type: Column vector of no. energy bins in each spe file; dnd-type: =NaN
%                    buffer:   Maximum value of no. energy bins if sparse; =NaN if non-sparse
%   info.ndet        sqw-type: Number of detectors; dnd-type: =NaN
%                    buffer:   Number of detectors if sparse; =NaN if non-sparse
%   info.ndims       sqw_data: Dimensionality of the sqw data
%                    buffer:   NaN
%   info.sz          sqw_data: Number of bins along each dimension ([1,4] array; excess elements = NaN)
%                    buffer:   Size of npix array
%   info.nz_npix     Number of non-zero values of npix; =NaN if non-sparse
%   info.nz_npix_nz  Number of non-zero values of npix_nz; =NaN if non-sparse
%   info.npixtot     Total number of pixels
%   info.npixtot_nz  Total number of non-zero signal pixels; =NaN if non-sparse
%   
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
%   position.npix           position of array npix (=NaN if npix not written)
%   position.urange         position of array urange (=NaN if urange not written)
%   position.npix_nz        position of array npix_nz (=NaN if npix_nz not written)
%   position.pix_nz         position of array pix_nz (=NaN if pix_nz not written)
%   position.pix            position of array pix  (=NaN if pix not written)
%   position.data_end       end of data block (equivalent to start of following section)
%
%   fmt.s           Format of array s
%   fmt.e           Format of array e
%   fmt.npix        Format of array npix
%   fmt.urange      Format of array urange (='' if urange not written)
%   fmt.npix_nz     Format of array npix_nz (='' if npix_nz not written)
%   fmt.pix_nz      Format of array pix_nz (='' if pix_nz not written)
%   fmt.pix         Format of array pix  (='' if pix not written)


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


S.fid=-1;
S.filename='';

S.application=struct('name','','version',appversion(0),'file_format',appversion(0));

S.info=struct('sparse',false,'sqw_data',false,'sqw_type',false,'buffer_data',false,...
    'nfiles',NaN,'ne',NaN,'ndet',NaN,'ndims',NaN,'sz',NaN(1,4),...
    'nz_npix',NaN,'nz_npix_nz',NaN,'npixtot',NaN,'npixtot_nz',NaN);

S.position = struct('application',NaN,'info',NaN,'position',NaN,'fmt',NaN,...
    'main_header',NaN,'header',NaN,'instrument',NaN,'sample',NaN,'detpar',NaN,'data',NaN,...
    's',NaN,'e',NaN,'npix',NaN,'urange',NaN,'npix_nz',NaN,'pix_nz',NaN,'pix',NaN,'data_end',NaN);

S.fmt = struct('s','','e','','npix','','urange','','npix_nz','','pix_nz','','pix','');

function [main_header,header,detpar,data,mess,position,npixtot,type] = get_sqw (infile,opt)
% Load an sqw file from disk
%
% Syntax:
%   >> [main_header, header, detpar, data, position, npixtot] = get_sqw (infile)
%   >> [main_header, header, detpar, data, position, npixtot] = get_sqw (infile, opt)
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%   opt         [optional] Determines which fields to read
%                   '-h'     header-type information only: fields read: 
%                               uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                              (If file was written from a strucutre of type 'b' or 'b+', then
%                               urange does not exist, and the output field will not be created)
%                   '-nopix' Pixel information not read (only meaningful for sqw data type 'a')
%
%                    Default: read all fields of the corresponding sqw data type ('b','b+','a','a-')
%
% Output:
% --------
%   main_header Main header block (for details of data structure, type >> help get_sqw_main_header)
%   header      Header block (for details of data structure, type >> help get_sqw_header)
%   detpar      Detector parameters (for details of data structure, type >> help get_sqw_detpar)
%   data        Output data structure which will contain the fields listed below (for details, type >> help get_sqw_data) 
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%                       type 'a-'   uoffset,...,s,e,npix,urange
%               or header information   
%   mess        Error message; blank if no errors, non-blank otherwise
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%                   position.main_header    start of main_header block
%                   position.header         start of each header block (header is column vector, length main_header.nfiles)
%                   position.detpar         start of detector parameter block
%                   position.data           start of data block
%                   position.s      position of array s
%                   position.e      position of array e
%                   position.npix   position of array npix (=[] if npix not written)
%                   position.pix    position of array pix  (=[] if pix not written)
%   npixtot     Total number of pixels written to file (=[] if pix not present)
%   type        Type of sqw data written to file: 
%               Valid sqw data structure, which must contain the fields listed below 
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%               or if the pix field is not read from type 'a', in which case 
%                       type 'a-'   uoffset,...,s,e,npix,urange


% T.G.Perring   27/06/2007


% Initialise output
main_header = [];
header = [];
detpar = [];
data = [];
position=[];
npixtot = [];
type = '';

% Open file
if isnumeric(infile)
    fid = infile;       % copy fid
    if isempty(fopen(fid))
        mess = 'No open file with given file identifier';
        return
    end
    close_file = false; % do not close file
else
    fid=fopen(infile,'r');
    if fid<0
        mess=['Unable to open file ',infile];
        return
    end
    close_file = true;  % close file before (succesful) return
end


% Get main header
pos_tmp = ftell(fid);
[main_header,mess]=get_sqw_main_header(fid);
if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading main header block - ',mess]; return; end

nfiles = main_header.nfiles;    % expected number of headers
position = struct('main_header',pos_tmp,'header',zeros(nfiles,1),'detpar',0,'data',0,'s',0,'e',0,'npix',0,'pix',0);

% Get headers for each contributing spe file
if nfiles==1
    position.header(1)=ftell(fid);
    [header,mess]=get_sqw_header(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading header block - ',mess]; return; end
else
    header = cell(nfiles,1);
    for i=1:nfiles
        position.header(i)=ftell(fid);
        [header{i},mess]=get_sqw_header(fid);
        if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading header block - ',mess]; return; end
    end
end

% Get detector parameters
position.detpar(1)=ftell(fid);
[detpar,mess]=get_sqw_detpar(fid);
if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading detector parameter block - ',mess]; return; end

% Get data
position.data=ftell(fid);
if ~exist('opt','var')
    [data,mess,position_data,npixtot,type]=get_sqw_data(fid);
else
    [data,mess,position_data,npixtot,type]=get_sqw_data(fid,opt);
end
if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading data block - ',mess]; return; end
position.s=position_data.s;
position.e=position_data.e;
position.npix=position_data.npix;
position.pix=position_data.pix;

% Closedown
if close_file   % opened file in this routine, so close again
    fclose(fid);
end

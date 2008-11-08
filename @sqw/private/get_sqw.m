function [main_header,header,detpar,data,mess,position,npixtot,type] = get_sqw (infile,varargin)
% Load an sqw file from disk
%
% Syntax:
%   >> [main_header, header, detpar, data, position, npixtot] = get_sqw (infile)
%   >> [main_header, header, detpar, data, position, npixtot] = get_sqw (infile, '-h')
%   >> [main_header, header, detpar, data, position, npixtot] = get_sqw (infile, '-nopix')
%   >> [main_header, header, detpar, data, position, npixtot] = get_sqw (infile, npix_lo, npix_hi)
%
%   >> [sqw_type, ndim] = get_sqw(infile, '-sqw_type') % To determine if sqw_type or not, and dimensionality of object
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%   opt         [optional] Determines which fields to read
%                   '-h'     header-type information only: fields read: 
%                               uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                              (If file was written from a structure of type 'b' or 'b+', then
%                               urange does not exist, and the output field will not be created)
%                   '-nopix' Pixel information not read (only meaningful for sqw data type 'a')
%
%                    Default: read all fields of the corresponding sqw data type ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file
%   npix_hi     -|
%
% Output:
% --------
%   main_header Main header block (for details of data structure, type >> help get_sqw_main_header)
%   header      Header block (for details of data structure, type >> help get_sqw_header)
%              Cell array if more than one contributing spe file.
%   detpar      Detector parameters (for details of data structure, type >> help get_sqw_detpar)
%   data        Output data structure which will contain the fields listed below (for details, type >> help get_sqw_data) 
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%                       type 'a-'   uoffset,...,s,e,npix,urange
%               or header information
%   mess        Error message; blank if no errors, non-blank otherwise
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%                   position.main_header    start of main_header block (=[] if not written)
%                   position.header         start of each header block (header is column vector, length main_header.nfiles)
%                   position.detpar         start of detector parameter block (=[] if not written)
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

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

application=horace_version;

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

% Read application and version number
[app_wrote_file,mess]=get_application(fid);
if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading file type - ',mess]; return; end
if ~strcmpi(application.name,app_wrote_file.name) || application.version~=app_wrote_file.version
    if close_file
        fclose(fid);
    end
    mess='Unrecognised format for sqw file';
    return
end


% Get sqw type and dimensions
[sqw_type,ndims,mess]=get_sqw_object_type(fid);
if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading sqw file type - ',mess]; return; end

% return if only wished to inquire of sqw_type
if numel(varargin)==1 && ischar(varargin{1}) && isequal(lower(varargin{1}),'-sqw_type')
    main_header=sqw_type;   % the first output argument must be sqw_type
    header=ndims;            % second output argument is dimensionality
    if close_file   % opened file in this routine, so close again
        fclose(fid);
    end
    return
end


% Get main header
if sqw_type
    pos_tmp = ftell(fid);
    [main_header,mess]=get_sqw_main_header(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading main header block - ',mess]; return; end
    nfiles = main_header.nfiles;    % expected number of headers
else
    pos_tmp=[];
    main_header=struct([]);
    nfiles = 0;
end
position = struct('main_header',pos_tmp,'header',zeros(nfiles,1),'detpar',[],'data',0,'s',0,'e',0,'npix',[],'pix',[]);


% Get headers for each contributing spe file
% (nfiles=0 is special case of dnd-type data)
if nfiles==0
    header=struct([]);
elseif nfiles==1
    position.header(1)=ftell(fid);
    [header,mess]=get_sqw_header(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading header block - ',mess]; return; end
elseif nfiles>1
    header = cell(nfiles,1);
    for i=1:nfiles
        position.header(i)=ftell(fid);
        [header{i},mess]=get_sqw_header(fid);
        if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading header block - ',mess]; return; end
    end
end

% Get detector parameters
if nfiles==0
    detpar=struct([]);
else
    position.detpar(1)=ftell(fid);
    [detpar,mess]=get_sqw_detpar(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading detector parameter block - ',mess]; return; end
end

% Get data
position.data=ftell(fid);
if isempty(varargin)
    [data,mess,position_data,npixtot,type]=get_sqw_data(fid);
else
    [data,mess,position_data,npixtot,type]=get_sqw_data(fid,varargin{:});
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

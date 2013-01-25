function [main_header,header,detpar,data,mess,position,npixtot,type,current_format] = get_sqw (infile,varargin)
% Load an sqw file from disk
%
% Syntax:
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format] = get_sqw (infile)
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format] = get_sqw (infile, '-h')
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format] = get_sqw (infile, '-hverbatim')
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format] = get_sqw (infile, '-nopix')
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format] = get_sqw (infile, npix_lo, npix_hi)
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%   opt         [optional] Determines which fields to read from the data block:
%                   '-h'            Header-type information only: fields read: 
%                                       filename, filepath, title, alatt, angdeg,...
%                                           uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                                  (If file was written from a structure of type 'b' or 'b+', then
%                                  urange does not exist, and the output field will not be created)
%                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-nopix'        Pixel information not read (only meaningful for sqw data type 'a')
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
%                       type 'b'    fields: filename,...,dax,s,e
%                       type 'b+'   fields: filename,...,dax,s,e,npix
%                       type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                       type 'a-'   fields: filename,...,dax,s,e,npix,urange
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
%                       type 'b'    fields: filename,...,dax,s,e
%                       type 'b+'   fields: filename,...,dax,s,e,npix
%                       type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%               or if the pix field is not read from type 'a', in which case 
%                       type 'a-'   fields: filename,...,dax,s,e,npix,urange

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

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
pos_tmp=ftell(fid);
[app_wrote_file,mess]=get_application(fid);
%RAE modification - comment out 3rd part of if statement. This is because
%we got failure when trying to use v2 to read v1 data, and vice versa. In
%fact we only need to check that there is some app_wrote_file.name info.
%For pre-sqw data this info is missing, which is all we really need to
%check for.
if isempty(mess) && strcmpi(application.name,app_wrote_file.name) %&& application.version==app_wrote_file.version
    % Current version of Horace wrote file
    current_format=true;
else
    % Assume sqw file old format
    disp('File does not have current Horace data file format. Attempting to read as old format Horace .sqw file...')
    current_format=false;
    fseek(fid,pos_tmp,'bof');
end


% Get sqw type
if current_format
    [sqw_type,ndims,mess]=get_sqw_object_type(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading sqw file type - ',mess]; return; end
else    % Assume old sqw file format
    sqw_type=true;
end


% Get main header
if sqw_type
    pos_tmp = ftell(fid);
    if numel(varargin)==1 && ischar(varargin{1}) && strcmpi(varargin{1},'-hverbatim')
        [main_header,mess]=get_sqw_main_header(fid,'-hverbatim');
    else
        [main_header,mess]=get_sqw_main_header(fid);
    end
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
if current_format
    if isempty(varargin)
        [data,mess,position_data,npixtot,type]=get_sqw_data(fid);
    else
        [data,mess,position_data,npixtot,type]=get_sqw_data(fid,varargin{:});
    end
else
    if isempty(varargin)
        [data,mess,position_data,npixtot,type]=get_sqw_data(fid,'-prototype');
    else
        [data,mess,position_data,npixtot,type]=get_sqw_data(fid,varargin{:},'-prototype');
    end
    % Fill fields not held in data section from the header
    data.title=main_header.title;
    header_ave=header_average(header);
    data.alatt=header_ave.alatt;
    data.angdeg=header_ave.angdeg;
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

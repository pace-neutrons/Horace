function [main_header,header,detpar,data,mess,position,npixtot,type,current_format,format_flag] = get_sqw (infile,varargin)
% Load an sqw file from disk
%
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format,format_flag] = get_sqw (infile)
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format,format_flag] = get_sqw (infile, '-h')
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format,format_flag] = get_sqw (infile, '-hverbatim')
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format,format_flag] = get_sqw (infile, '-nopix')
%   >> [main_header,header,detpar,data,mess,position,npixtot,type,current_format,format_flag] = get_sqw (infile, npix_lo, npix_hi)
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
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
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
%              or header information only
%   mess        Error message; blank if no errors, non-blank otherwise
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%              These field are correctly filled even if the header only has been requested, that is,
%              if input option '-h' or '-hverbatim' was given
%                   position.main_header    start of main_header block (=[] if not written)
%                   position.header         start of each header block (column vector, length main_header.nfiles)
%                                          (=zeros(0,1) if not written)
%                   position.detpar         start of detector parameter block (=[] if not written)
%                   position.data           start of data block
%                   position.s              position of array s
%                   position.e              position of array e
%                   position.npix           position of array npix (=[] if npix not written)
%                   position.urange         position of array urange (=[] if urange not written)
%                   position.pix            position of array pix  (=[] if pix not written)
%                   position.header_opt     start of each header optional block (column vector, length main_header.nfiles)
%                                          (=zeros(0,1) if not written)
%                   position.position_info  position of start of the position block
%
%   npixtot     Total number of pixels written to file (=[] if pix not present)
%   type        Type of sqw data written to file: 
%               Valid sqw data structure, which must contain the fields listed below 
%                       type 'b'    fields: filename,...,dax,s,e
%                       type 'b+'   fields: filename,...,dax,s,e,npix
%                       type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%               or if the pix field is not read from type 'a', in which case 
%                       type 'a-'   fields: filename,...,dax,s,e,npix,urange
%   current_format  =true if the file format is the current format, =false if not
%   format_flag     Format of file
%                       Current formats:  '-v2', '-v3'
%                       Obsolete formats: '-prototype'
% 
%
% NOTES:
% ======
% Supported file Formats
% ----------------------
% The current sqw file format comes in two variants:
%   - version 1 and version 2
%      (Autumn 2008 onwards.) Does not contain instrument and sample fields in the header block.
%       This format is the one still written if these fields are empty in the sqw object (or result of a
%       cut on an sqw file assembled only to a file - see below).
%   - version 3
%       (February 2013 onwards.) Writes optional instrument and sample fields in the header block, and
%      positions of the start of major data blocks in the sqw file. Finally, finishes with the positon
%      of the position data block and the end of the data block as the last two 8 byte entries.
%
% Additionally, this routine will read the prototype sqw file format:
%       (July 2007(?) - Autumn 2008). Almost the same format, except that data saved as type 'b' is
%       uninterpretable by Horace because the npix information that is needed to normalise the
%       signal and error in each bin is not stored.


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


% Read application and file format version number
% -----------------------------------------------
% If version 3, then get the position information written in the file, and the data type ('b','b+','a-' or 'a')
pos_start=ftell(fid);
[app_wrote_file,mess]=get_application(fid);

if isempty(mess) && strcmpi(application.name,app_wrote_file.name)
    % Post-prototype format sqw file
    current_format=true;
    file_format_version=app_wrote_file.version;
    if file_format_version==3
        format_flag='-v3';
        pos_tmp=ftell(fid);
        
        % Get position block location and data type
        fseek(fid,0,'eof');     % go to end of file
        [position_info_location,data_type,mess]=get_sqw_file_footer(fid);
        if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading footer data - ',mess]; return; end
        
        % Get position information
        fseek(fid,position_info_location,'bof');
        [pos_info_from_file,mess]=get_sqw_position_info(fid);
        if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading position locator block - ',mess]; return; end
        
        % Return to end of application block
        fseek(fid,pos_tmp,'bof');
        
    elseif file_format_version<=2   % file format 1.0 or 2.0
        format_flag='-v2';
        position_info_location=[];  % no position information block
        data_type='';               % unknown data type
        
    else
        if close_file; fclose(fid); end;
        mess='Unrecognised sqw file format version';
        return
    end
    
else
    % Assume prototype sqw file format
    disp('File does not have current Horace data file format. Attempting to read as old format Horace .sqw file...')
    current_format=false;
    format_flag='-prototype';
    % Return to start of file (no application block was found in the file)
    fseek(fid,pos_start,'bof');
    position_info_location=[];  % no position information block
    data_type='';               % unknown data type
end


% Get sqw type
% ------------
if current_format
    [sqw_type,ndims,mess]=get_sqw_object_type(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading sqw file type - ',mess]; return; end
else    % Assume old sqw file format
    sqw_type=true;
end


% Get main header
% ---------------
if sqw_type
    pos_main_header = ftell(fid);
    if numel(varargin)==1 && ischar(varargin{1}) && strcmpi(varargin{1},'-hverbatim')
        [main_header,mess]=get_sqw_main_header(fid,'-hverbatim');
    else
        [main_header,mess]=get_sqw_main_header(fid);
    end
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading main header block - ',mess]; return; end
    nfiles = main_header.nfiles;    % expected number of headers
else
    pos_main_header=[];
    main_header=struct([]);
    nfiles = 0;
end

% Construct position information structure now we have the number of files
position = struct('main_header',pos_main_header,'header',zeros(nfiles,1),'detpar',[],...
    'data',[],'s',[],'e',[],'npix',[],'urange',[],'pix',[],'header_opt',zeros(nfiles,1),'position_info',position_info_location);


% Get headers for each contributing spe file
% ------------------------------------------
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
% -----------------------
if nfiles==0
    detpar=struct([]);
else
    position.detpar(1)=ftell(fid);
    [detpar,mess]=get_sqw_detpar(fid);
    if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading detector parameter block - ',mess]; return; end
end


% Get data
% --------
position.data=ftell(fid);
[data,mess,position_data,npixtot,type]=get_sqw_data(fid,varargin{:},format_flag,data_type);
if ~current_format
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
position.urange=position_data.urange;
position.pix=position_data.pix;


% Get header optional information, if present
% -------------------------------------------
if file_format_version>=3
    if nfiles==1
        position.header_opt(1)=ftell(fid);
        [header_opt,mess]=get_sqw_header_opt(fid);
        if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading optional header block - ',mess]; return; end
        header.instrument=header_opt.instrument;
        header.sample=header_opt.sample;
        
    elseif nfiles>1
        for i=1:nfiles
            position.header_opt(i)=ftell(fid);
            [header_opt,mess]=get_sqw_header_opt(fid);
            if ~isempty(mess); if close_file; fclose(fid); end; mess=['Error reading header block - ',mess]; return; end
            header{i}.instrument=header_opt.instrument;
            header{i}.sample=header_opt.sample;
        end
    end
end


% Closedown
% ---------
if close_file   % opened file in this routine, so close again
    fclose(fid);
end


% -------------------------------------------
% Check consistency of file
% -------------------------------------------
if file_format_version>=3
    if ~isequal(position,pos_info_from_file)
        display('***********************')
        display('WARNING: Internal inconsistency of data file - check it is not corrupted')
        display('***********************')
    end
end

function [mess,main_header,header,detpar,data,position,npixtot,data_type,file_format,current_format] = get_sqw (infile,varargin)
% Load an sqw file from disk
%
%   >> [mess,main_header,header,detpar,data,position,npixtot,data_type,file_format,current_format]...
%            = get_sqw (infile)
%   >> [...] = get_sqw (infile, '-h')
%   >> [...] = get_sqw (infile, '-his')
%   >> [...] = get_sqw (infile, '-hverbatim')
%   >> [...] = get_sqw (infile, '-hisverbatim')
%   >> [...] = get_sqw (infile, '-nopix')
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%
%   opt         [optional] Determines which fields to read:
%                   '-h'            - header block without instrument and sample information, and
%                                   - data block fields: filename, filepath, title, alatt, angdeg,...
%                                                          uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                                    (If the file was written from a structure of type 'b' or 'b+', then
%                                    urange does not exist, and the output field will not be created)
%                   '-his'          - header block in full i.e. with without instrument and sample information, and
%                                   - data block fields as for '-h'
%                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-hisverbatim'  Similarly as for '-his'
%                   '-nopix'        Pixel information not read (only meaningful for sqw data type 'a')
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file
%   npix_hi     -|
%
%
% Output:
% --------
%   mess        Error message; blank if no errors, non-blank otherwise
%
%   main_header Main header block (for details of data structure, type >> help get_sqw_main_header)
%
%   header      Header block (for details of data structure, type >> help get_sqw_header)
%              Cell array if more than one contributing spe file.
%
%   detpar      Detector parameters (for details of data structure, type >> help get_sqw_detpar)
%
%   data        Output data structure actually read from the file. Will be one of:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,urange]
%                   type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%                   type 'sp'   fields: filename,...,uoffset,....dax,s,e,npix,urange,pix,npix_nz,ipix_nz,pix_nz (sparse format)
%               The final field urange is present for type 'h' if the header information was read from an sqw-type file.
%
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%              These field are correctly filled even if the header only has been requested, that is,
%              if input option '-h' or '-hverbatim' was given
%                   position.main_header    start of main_header block (=[] if not written in the file)
%                   position.header         start of each header block (column vector, length main_header.nfiles)
%                                          (=[] if not written in the file)
%                   position.detpar         start of detector parameter block (=[] if not written in the file)
%                   position.data           start of data block
%                   position.s              position of array s
%                   position.e              position of array e
%                   position.npix           position of array npix (=[] if npix not written in the file)
%                   position.urange         position of array urange (=[] if urange not written in the file)
%                   position.npix_nz        position of array npix_nz (=[] if npix_nz not written in the file)
%                   position.ipix_nz        position of array ipix_nz (=[] if ipix_nz not written in the file)
%                   position.pix_nz         position of array pix_nz (=[] if pix_nz not written in the file)
%                   position.pix            position of array pix  (=[] if pix not written in the file)
%                   position.instrument     start of header instrument blocks (=[] if not written in the file)
%                   position.sample         start of header sample blocks (=[] if not written in the file)
%                   position.position_info  position of start of the position block (=[] if not written in the file)
%
%   npixtot     Total number of pixels written to file (=[] if pix not present in the file)
%
%   data_type   Type of sqw data written in the file 
%                   type 'b'    fields: filename,...,dax,s,e
%                   type 'b+'   fields: filename,...,dax,s,e,npix
%                   type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                   type 'a-'   fields: filename,...,dax,s,e,npix,urange
%                   type 'sp-'  fields: filename,...,dax,s,e,npix,urange (sparse format)
%                   type 'sp'   fields: filename,...,dax,s,e,npix,urange,pix,npix_nz,ipix_nz,pix_nz (sparse format)
%
%   file_format     Format of file
%
%   current_format  =true if the file format has one of the current formats, =false if not



% Original author: T.G.Perring
%
% $Revision$ ($Date$)

application=horace_version();

% Initialise output
main_header = [];
header = [];
detpar = [];
data = [];
position = struct('main_header',[],'header',[],'detpar',[],...
    'data',[],'s',[],'e',[],'npix',[],'urange',[],'npix_nz',[],'ipix_nz',[],'pix_nz',[],'pix',[],...
    'instrument',[],'sample',[],'position_info',[]);
npixtot = [];
data_type = '';
file_format = '';
current_format = false;

% Check options
opt_h=false;
opt_his=false;
verbatim=false;
opt_nopix=false;
pix_range=false;
opt_char={'-h','-his','-hverbatim','-hisverbatim','-nopix'};
if numel(varargin)==1 && ischar(varargin{1}) && any(strcmpi(varargin{1},opt_char))   % single option that is a character string
    if strcmpi(varargin{1},'-h')||strcmpi(varargin{1},'-hverbatim')
        opt_h=true;
    end
    if strcmpi(varargin{1},'-his')||strcmpi(varargin{1},'-hisverbatim')
        opt_his=true;
    end
    if strcmpi(varargin{1},'-hverbatim')||strcmpi(varargin{1},'-hisverbatim')
        verbatim=true;
    end
    if strcmpi(varargin{1},'-nopix')
        opt_nopix=true;
    end
    
elseif numel(varargin)==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
                             isscalar(varargin{1}) && isscalar(varargin{2})
    pix_range=true;
    npix_lo=varargin{1};
    npix_hi=varargin{2};
    
elseif numel(varargin)>0
    mess='Unrecognised options to get_sqw';
    return
end

% Open file
[mess,filename,fid,fid_input]=get_sqw_open(infile);
if tidy_close(mess,fid_input,fid), return, end


% Get file format, and recorded sqw_type and data_type if available
% --------------------------------------------------------------
% If '-v3', then get the position information written in the file, and the data type
pos_start=ftell(fid);
[mess,app_wrote_file]=get_application(fid,application.name);

%if app_wrote_file.file_format

if isempty(mess)
    % Post-prototype format sqw file
    current_format=true;
    if app_wrote_file.version==3
        file_format='-v3';
        pos_tmp=ftell(fid);
        
        % Get position block location and data type
        fseek(fid,0,'eof');     % go to end of file
        [mess,position_info_location,data_type_from_file]=get_sqw_file_footer(fid);
        if tidy_close(mess,fid_input,fid), return, end

        % Get position information
        fseek(fid,position_info_location,'bof');
        [mess,pos_info_from_file]=get_sqw_position_info(fid);
        if tidy_close(mess,fid_input,fid), return, end
        position.position_info=position_info_location;

        % Return to end of application block
        fseek(fid,pos_tmp,'bof');
        
    elseif app_wrote_file.version<=2
        file_format='-v2';
        data_type_from_file='';            % unknown data type
        
    else
        mess='Unrecognised sqw file format version';
        if tidy_close(mess,fid_input,fid), return, end
    end
    [mess,sqw_type]=get_sqw_object_type(fid);
    if tidy_close(mess,fid_input,fid), return, end
    
else
    % Assume prototype sqw file format
    disp('File does not have current Horace data file format. Attempting to read as prototype format Horace .sqw file...')
    fseek(fid,pos_start,'bof');         % return to start of file
    n = fread_catch(fid,1,'int32');     % first entry is length of character string with file name
    if n<0 || n>1024
        mess='Unable to read file as prototype Horace .sqw file';
        if tidy_close(mess,fid_input,fid), return, end
    end
    
    current_format=false;
    file_format='-prototype';
    sqw_type=true;          % assume old sqw file format
    data_type_from_file=''; % unknown data type

    % Return to start of file (no application block was found in the file)
    fseek(fid,pos_start,'bof');
end


% Get main header
% ---------------
if sqw_type
    if ~verbatim
        [mess, main_header, position.main_header] = get_sqw_main_header (fid);
    else
        [mess, main_header, position.main_header] = get_sqw_main_header (fid, '-verbatim');
    end
    if tidy_close(mess,fid_input,fid), return, end
    nfiles = main_header.nfiles;
else
    main_header=struct([]);
    nfiles = 0;
end


% Get headers for each contributing spe file
% ------------------------------------------
if sqw_type
    [mess, header, position.header] = get_sqw_header (fid, nfiles);
    if tidy_close(mess,fid_input,fid), return, end
else
    header=struct([]);
end


% Get detector parameters
% -----------------------
if sqw_type
    [mess, detpar, position.detpar] = get_sqw_detpar (fid);
    if tidy_close(mess,fid_input,fid), return, end
else
    detpar=struct([]);
end


% Get data
% --------
if (opt_h||opt_his) && ~verbatim
    data_opt={'-h'};
elseif (opt_h||opt_his) && verbatim
    data_opt={'-hverbatim'};
elseif opt_nopix
    data_opt={'-nopix'};
elseif pix_range
    data_opt={npix_lo,npix_hi};
else
    data_opt={};
end
[mess, data, position_data, npixtot, data_type] = get_sqw_data (fid, data_opt{:}, file_format, data_type_from_file);
if tidy_close(mess,fid_input,fid), return, end

% Fill fields not held in data section from the header
if strcmp(file_format,'-prototype')
    data.title=main_header.title;
    header_ave=header_average(header);
    data.alatt=header_ave.alatt;
    data.angdeg=header_ave.angdeg;
end

% Fill position structure
position.data=position_data.data;
position.s=position_data.s;
position.e=position_data.e;
position.npix=position_data.npix;
position.urange=position_data.urange;
position.pix=position_data.pix;
position.npix_nz=position_data.npix_nz;
position.ipix_nz=position_data.ipix_nz;
position.pix_nz=position_data.pix_nz;


% Get header optional information, if present
% -------------------------------------------
if strcmp(file_format,'-v3') && ~opt_h
    fseek(fid,pos_info_from_file.instrument,'bof');     % might need to skip redundant bytes
    % Instrument information
    [mess, header, position.instrument] = get_sqw_header_inst (fid, header);
    if tidy_close(mess,fid_input,fid), return, end
    % Sample information
    [mess, header, position.sample] = get_sqw_header_samp (fid, header);
    if tidy_close(mess,fid_input,fid), return, end
    
    % Check consistency of file - debugging tool
    % -------------------------------------------
    if strcmp(file_format,'-v3')
        if ~isequal(position,pos_info_from_file)
            display('***********************')
            display('WARNING: Internal inconsistency of data file - check it is not corrupted')
            display('***********************')
        end
    end
end


% Closedown
% ---------
if ~fid_input   % opened file in this routine, so close again
    fclose(fid);
end


%--------------------------------------------------------------------------------------------------
function status=tidy_close(mess,file_already_open,fid)
% Tidy shut down of file if there was an error
%
%   >> status=tidy_close(mess,file_already_open,fid)
%
% Input:
% ------
%   mess                Message; if empty, then assume there was no error; otherwise assume an error
%   file_already_open   True if the output sqw file was already open on input (so don't close it)
%   fid                 File identifier of sqw file. If not 
%
% Output:
% -------
%   status              True if input argument 'mess' reported an error; false otherwise

if isempty(mess)
    status=false;
else
    status=true;
    % Close sqw file, if open
    if ~file_already_open && fid>=3 && ~isempty(fopen(fid))
        fclose(fid);
    end
end

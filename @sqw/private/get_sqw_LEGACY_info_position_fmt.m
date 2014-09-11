function [mess, info, position, fmt] = get_sqw_LEGACY_info_position_fmt (fid, fmt_ver)
% Get file information in latest Horace version form
%
%   >> [mess, info, position, fmt] = get_sqw_LEGACY_info_position_fmt (fid, fmt_ver)
%
% Assumes that get_application has already been called, so that:
% - if ver3 or ver1 file format: at start of object_type block
% - if ver0 file format: at start of main_header block of sqw-type file (we will not
%   read dnd-type,s npix information was not stored)
%
% The file pointer will be left at the start of the main_header section


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


S=sqwfile();
info=S.info;
position=S.position;
fmt=S.fmt;

ver3=appversion(3);
ver1=appversion(1);
ver0=appversion(0);


% Read data from sqw file required to fill the information section
% ----------------------------------------------------------------
% Read in object type (ver1 or ver3)
if fmt_ver==ver3 || fmt_ver==ver1
    [mess,sqw_type]=get_sqw_LEGACY_object_type(fid);
    if ~isempty(mess), return, end
else
    sqw_type=true;  % we only try to read sqw files
end


% For ver3, ver1, ver0:
% (Note that if version 0, a likely problem is that the data was dnd type, and because
% we try to read as sqw type, some awful formatting error occured)
pos_on_exit=ftell(fid);
try
    [mess, main_header, header, detpar, data, pos_main_sections] = get_sqw_LEGACY_header_sections (fid, fmt_ver, sqw_type);
    if ~isempty(mess), return, end
catch
    if fmt_ver==ver0
        mess='Attempt to interpret file as prototype format Horace sqw data failed';
    else
        mess='Fatal error attempting to read file';
    end
    return
end
ndims=numel(data.pax);
sz_npix=NaN(1,4);
for i=1:ndims
    sz_npix(i)=numel(data.p{i})-1;
end
nbins=prod(sz_npix(1:ndims));


% Read position information, if any, and work out/read npixtot
if fmt_ver<ver3
    pos_arr.s=ftell(fid);
    pos_arr.e=pos_arr.s + 4*nbins;
    pos_arr.npix=pos_arr.e + 4*nbins;
    if sqw_type
        pos_arr.urange=pos_arr.npix + 8*nbins;
        pos_arr.pix=pos_arr.npix + 8*nbins + 44;    % bytes: 2x4xfloat32 for urange, 4 blank, 8 for npixtot
        % Work out npixtot from the length from start of signal array to end of file
        fseek(fid,0,'eof');
        pos_endfile=ftell(fid);
        nbytes=pos_endfile-pos_arr.s;
        npixtot=(nbytes-(16*nbins+44))/36;
        if npixtot<0 || rem(npixtot,1)~=0
            mess='Error reading sqw-type data from version 1 or prototype format file (npixtot error)';
            return
        end
    end
else
    % Get position block location and data type
    fseek(fid,0,'eof');     % go to end of file
    [mess,position_info_location,data_type_from_file]=get_sqw_LEGACY_file_footer(fid);
    if ~isempty(mess), return, end
    
    if ~(strcmp(data_type_from_file,'b+') || strcmp(data_type_from_file,'a'))
        mess='File does not contain dnd-type or sqw-type data';
        return
    end
    
    % Get position information
    fseek(fid,position_info_location,'bof');
    [mess,pos_info_from_file]=get_sqw_LEGACY_position_info(fid);
    if ~isempty(mess), return, end

    % Get npixtot from file (cannot use the trick for ver1 or ver0 above, as more in the file after data section)
    if sqw_type
        fseek(fid,pos_info_from_file.pix-8,'bof');  % npixtot immediately before pix array
        npixtot=fread(fid,1,'int64');
    end
    
    % Positions of s,e,npix,urange,pix arrays
    pos_arr.s=pos_info_from_file.s;
    pos_arr.e=pos_info_from_file.e;
    pos_arr.npix=pos_info_from_file.npix;
    if sqw_type
        pos_arr.urange=pos_info_from_file.urange;
        pos_arr.pix=pos_info_from_file.pix;
    end
    
end


% Fill the sqwfile structure
% --------------------------
% Only update from the defaults as required

% info block:
info.sparse=false;
info.sqw_data=true;
info.sqw_type=sqw_type;
info.buffer_type=false;
if sqw_type
    info.nfiles=main_header.nfiles;
else
    info.nfiles=NaN;
end
info.ndims=ndims;
if sqw_type
    if isstruct(header)
        ne=numel(header.en)-1;
    else
        nfiles=main_header.nfiles;
        ne=zeros(nfiles,1);
        for i=1:nfiles
            ne(i)=numel(header{i}.en)-1;
        end
    end
    info.ne=ne;
else
    info.ne=NaN;
end
if sqw_type
    info.ndet=numel(detpar.x2);
else
    info.ndet=NaN;
end
info.sz_npix=sz_npix;
if sqw_type
    info.npixtot=npixtot;
end

% position block:
position=updatestruct(position,pos_main_sections);
if fmt_ver==ver3
    if ~isempty(pos_info_from_file.instrument)  % empty indicates not written
        position.instrument=pos_info_from_file.instrument;
    end
    if ~isempty(pos_info_from_file.sample)      % empty indicates not written
        position.sample=pos_info_from_file.sample;
    end
end
position=updatestruct(position,pos_arr);

% fmt block:
fmt.s='float32';
fmt.e='float32';
fmt.npix='int64';
if sqw_type
    fmt.urange='float32';
    fmt.pix='float32';
end

% Leave at start of main_header
% -----------------------------
mess='';
fseek(fid,pos_on_exit,'bof');


%==================================================================================================
function [mess, sqw_type, ndims, position] = get_sqw_LEGACY_object_type (fid)
% Read the type of sqw object written to file
%
%   >> [mess, sqw_type, ndims, position] = get_sqw_object_type (fid)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%
% Output:
% -------
%   mess        Error message; blank if no errors, non-blank otherwise
%   sqw_type    Type of sqw object written to file: =1 if sqw type; =0 if dnd type
%   ndims       Number of dimensions of sqw object
%   position    Position of the start of the sqw object type block


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)


mess='';
sqw_type=[];
ndims=[];
position = ftell(fid);

try
    tmp = fread (fid,1,'int32');
    sqw_type = logical(tmp);
    ndims = fread (fid,1,'int32');
catch
    mess='Error reading sqw type and dimensions block from file';
end

%==================================================================================================
function [mess, main_header, header, detpar, data, position] = get_sqw_LEGACY_header_sections (fid, fmt_ver, sqw_type)
% Read the header sections
%
%   >> [mess, main_header, header, detpar, data, position] = get_sqw_LEGACY_header_sections (fid, fmt_ver, sqw_type)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   sqw_type        =true if sqw-type data; =false if dnd-type data
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   main_header     Main header section
%   header          Header section
%   detpar          Detector parameter section
%   data            Header part of data section (i.e. fields filename...p,dax)
%   position        Structure containing start of sections
%       position.main_header    start of main_header block (=NaN if not written)
%       position.header         start of header block (=NaN if not written)
%       position.detpar         start of detector parameter block (=NaN if not written)
%       position.data           start of data block

position=struct();

if sqw_type
    % Main header
    position.main_header = ftell(fid);
    verbatim=false;
    [mess, main_header] = get_sqw_main_header (fid, fmt_ver, verbatim);
    if ~isempty(mess), return, end

    % Header
    position.header = ftell(fid);
    [mess, header] = get_sqw_header (fid, fmt_ver, main_header.nfiles);
    if ~isempty(mess), return, end

    % Detectors
    position.detpar = ftell(fid);
    [mess, detpar] = get_sqw_detpar (fid, fmt_ver);
    if ~isempty(mess), return, end

else
    main_header = struct([]);
    header = struct([]);
    detpar = struct([]);
    position.main_header = NaN;
    position.header = NaN;
    position.detpar = NaN;
end

% Data
position.data=ftell(fid);
S=sqwfile();
read_header=true;
verbatim=false;
make_full_fmt=false;
opt=struct('dnd',false,'sqw',false,'nopix',false,'buffer',false,...
    'npix',false,'npix_nz',false,'pix_nz',false,'pix',false);
[mess, data] = get_sqw_data (fid, fmt_ver, S, read_header, verbatim, make_full_fmt, opt);
if ~isempty(mess), return, end


%==================================================================================================
function [mess, position_info_location, data_type, position] = get_sqw_LEGACY_file_footer (fid)
% Read final entry to sqw file: location of position information in the file and data_type
%
%   >> [mess, position_info_location, data_type, position] = get_sqw_file_footer (fid)
%
% It is assumed that on entry that the pointer is just after the end of this block,
% which should in fact be the end of the file.
%
% Input:
% ------
%   fid                     File pointer to (already open) binary file
%
% Output:
% -------
%   mess                    Message if there was a problem writing; otherwise mess=''
%   position_info_location  Position of the position information block
%   data_type               Type of sqw data contained in the file: will be one of
%                               type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                               type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                               type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%                               type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%   position                Position of the file footer in the file

position_info_location=[];
data_type='';
position = ftell(fid);

% Read data from file:
try
    fseek(fid,-4,'cof');        % we assume that we are at the end of the block of data
    n = fread(fid,1,'int32');   % length of data_type
    fseek(fid,-(n+12),'cof');   % move to start of the block of data (8-byte position + n-byte string + 4-byte string length)
    position_info_location = fread(fid,1,'float64');
    data_type = fread(fid,[1,n],'*char*1');
catch
    mess='Error reading footer block from file';
end


%==================================================================================================
function [mess, position] = get_sqw_LEGACY_position_info (fid)
% Get the positions of the various key data blocks in the sqw file
%
%   >> [mess, position] = get_sqw_position_info (fid)
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Structure containing fields read from file (details below)
%
%
% Fields read from file are: 
% --------------------------
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
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

mess = '';
position = [];

try
    position = get_variable_from_binfile(fid);
catch
    mess = 'Unable to read position information from file';
end

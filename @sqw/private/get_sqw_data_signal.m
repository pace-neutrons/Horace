function [mess,position,data,npixtot] = get_sqw_data_signal (fid, fmt_ver, is_sqw, sz, varargin)
% Read data structure
%
%   >> [mess,position,data,npixtot] = get_sqw_data_signal (fid, fmt_ver, is_sqw, sz)
%   >> [mess,position,data,npixtot] = get_sqw_data_signal (fid, fmt_ver, is_sqw, sz, '-skip')
%   >> [mess,position,data,npixtot] = get_sqw_data_signal (fid, fmt_ver, is_sqw, sz, '-dnd')
%   >> [mess,position,data,npixtot] = get_sqw_data_signal (fid, fmt_ver, is_sqw, sz, '-nopix')
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary reading). The file position
%              indicator on entry to be at the start of the signal array.
%               The input file is assumed to have either dnd-type or sqw-type data.
%   fmt_ver     Version of file format e.g. appversion('-v3')
%   is_sqw      =true if the dat file is known to contain sqw-type data, =false if dnd-type data
%   sz          Size of the signal array [n1,n2,...] for as many dimensions as the data
%   opt         [Optional] control which fields to read
%                   '-skip'     Do not read any information into data
%                   '-dnd'      Only read fields s,e,n
%                   '-nopix'    Do not read pix array
%
% Output:
% -------
%   mess        Error message; ='' if all OK, non-empty if a problem
%   position    Structure with positions of fields; an entry is set to [] if
%              corresponding field was not present in the file (the position will be
%              filled even for fields that ar present but were not read).
%       position.s      Start of signal array
%       position.e      Start of error array
%       position.npix   Start of npix array
%       position.urange Start of urange array
%       position.pix    Start of pix array
%
%   data        Contains data read from file )if '-skip'
%                   dnd-type data read from file: s,e,npix
%                   sqw-type data read from file: s,e,npix,urange,pix
%                   '-skip' : empty strucure, struct()
%                   '-nopix':   'a-' format data: s,e,npix,urange
%               where the fields are:
%       data.s          Average signal in the bins (sparse column vector)
%       data.e          Corresponding variance in the bins (sparse column vector)
%       data.npix       Number of contributing pixels to each bin as a sparse column vector
%       data.urange     True range of the data along each axis [urange(2,4)]. This is in the
%                      coordinates of the plot/integration projection axes, NOT the projection
%                      axes of the individual pixel info.
%       data.pix        Array containing data for each pixel:
%                      Where npixtot=sum(npix), then pix(9,npixtot) contains:
%                       u1      -|
%                       u2       |  Coordinates of pixel in the projection axes of the original sqw file(s)
%                       u3       |
%                       u4      -|
%                       irun        Run index in the header block from which pixel came
%                       idet        Detector group number in the detector listing for the pixel
%                       ien         Energy bin number for the pixel in the array in the (irun)th header
%                       signal      Signal array
%                       err         Error array (variance i.e. error bar squared)
%
% Note: for '-v0', '-v1' and '-v3', the number of bytes is
%   'b+': 16*nbins
%   'a':  16*nbins + 36*npixels + 44


mess='';
position = struct('s',[],'e',[],'npix',[],'urange',[],'pix',[]);
npixtot=[];

% Check input options
% -------------------
if numel(varargin)>0
    if strcmpi(varargin{1},'-skip')
        skip=true;
    elseif strcmpi(varargin{1},'-dnd')
        skip=false;
        skip_urange=true;
        skip_pix=true;
    elseif strcmpi(varargin{1},'-nopix')
        skip=false;
        skip_urange=false;
        skip_pix=true;
    end
else
    skip=false;
end

[fmt_dble,fmt_int,nbyte_dble,nbyte_int]=fmt_sqw_fields(fmt_ver);
is_ver0=(fmt_ver==appversion(0));
is_ver_lt_3p1=(fmt_ver<appversion(3,1));


% Read s and e
% ------------
position.s=ftell(fid);
if ~skip
    tmp = fread(fid, prod(sz), '*float32');
    data.s = reshape(double(tmp),sz);
    clear tmp
else
    fseek(fid,4*(prod(sz)),'cof');  % skip field s
end

position.e=ftell(fid);
if ~skip
    tmp = fread(fid, prod(sz), '*float32');
    data.e = reshape(double(tmp),sz);
    clear tmp
else
    fseek(fid,4*(prod(sz)),'cof');  % skip field e
end


% Read npix
% ----------
% Catch case of '-v0' dnd file - this is not readable as information about pixels was not recorded
if is_ver0 && fnothingleft(fid)
    mess = 'File does not contain number of pixels for each bin - unable to convert old format dnd-type data';
    return
end

if ~skip
    tmp = fread(fid, prod(sz), '*int64');
    data.npix = reshape(double(tmp),sz);
    clear tmp
    if is_ver0
        [data.s,data.e]=convert_signal_error(data.s,data.e,data.npix);
    end
else
    fseek(fid,8*(prod(sz)),'cof');  % skip field e
end

% Return if only dnd data in the file - have reached the end of the data section
if ~is_sqw
    return  
end


% Read urange
% -----------
position.urange=ftell(fid);
if ~skip && ~skip_urange
    data.urange = fread(fid, [2,4], fmt_dble);
else
    fseek(fid,8*nbyte_dble,'cof');
end


% Read pix
% --------
% *** Redundant field prior to '-v3.1':
if is_ver_lt_3p1
fseek(fid,4,'cof');
end

% npixtot
npixtot=fread(fid, 1, 'int64');

% pix
position.pix=ftell(fid);
if ~skip && ~skip_pix
    if npixtot>0
        tmp=fread(fid, [9,npixtot] ,'*float32');
        data.pix=double(tmp);
    else
        data.pix=zeros(9,0);
    end
else
    fseek(fid,36*npixtot,'cof');
end


%==================================================================================================
function answer=fnothingleft(fid)
% Determine if there is any more data in the file. Do this by trying to advance one byte
% Alternative is to go to end of file (fseek(fid,0,'eof') and see if location is the same.
status=fseek(fid,1,'cof');  % try to advance one byte
if status~=0;
    answer=true;
else
    answer=false;
    fseek(fid,-1,'cof');    % go back one byte
end

%==================================================================================================
function [s,e]=convert_signal_error(s,e,npix)
% Convert prototype (July 2007) format into standard format signal and error arrays
% Prototype format files have zeros for signal and variance arrays with no pixels
pixels = npix~=0;
s(pixels) = s(pixels)./npix(pixels);
e(pixels) = e(pixels)./(npix(pixels).^2);

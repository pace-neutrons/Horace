function [mess, data] = get_sqw_data_signal (fid, fmt_ver, S, opt, varargin)
% Read data structure
%
%   >> [mess, data] = get_sqw_data_signal (fid, fmt_ver, S, opt)
%   >> [mess, data] = get_sqw_data_signal (fid, fmt_ver, S, opt, range)
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary reading). The file position
%              indicator on entry to be at the start of the signal array.
%
%               The input file is assumed to have either dnd-type or sqw-type data.
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
%   S           sqwfile structure that contains information about the data in the sqw file
%
%   opt         Structure that defines the output (only one field can be true, the other false):
%                       'dnd','sqw','nopix','buffer'
%                       'npix','pix'
%
%   range       Optional argument in the case of opt.npix or opt.pix: specifies
%                   if opt.npix     [bin_lo, bin_hi]
%                   if opt.pix      [pix_lo, pix_hi]
%
% Output:
% -------
%   mess        Error message; ='' if all OK, non-empty if a problem
%
%   data        Contains data read from file
%               If option is one of 'dnd', 'sqw', 'nopix', 'buffer', then data
%              is a structure with the fields below:
%                   opt.dnd:    s,e,npix
%                   opt.sqw:    s,e,npix,urange,pix
%                   opt.nopix:  s,e,npix,urange
%                   opt.buffer: npix,pix
%              
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
%               If option is to read npix or pix, then data is a single array:
%                   opt.npix    npix arrayarray (or column vector if range present, length=diff(range))
%                   opt.pix     [9,npixtot] array (or [9,n] array if range present, n=diff(range))


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


mess='';

% Prepare some parameters for reading the data
% --------------------------------------------
% Unpack fields of S to reduce access time later on
info=S.info;
pos=S.position;
fmt=S.fmt;

% Get size of signal, error, npix arrays
ndims=info.dims;
if ndims>1
    sz=info.sz_npix(1:ndims);
elseif ndims==1
    sz=[info.sz_npix(1),1];
else
    sz=[1,1];
end

% Determine which fields to read and if output is a data structure
read_se     = opt.dnd || opt.sqw || opt.nopix;
read_npix   = read_se || opt.buffer || opt.npix;
read_urange = opt.sqw || opt.nopix;
read_pix    = opt.sqw || opt.buffer || opt.pix;

datastruct  = opt.dnd || opt.sqw || opt.nopix || opt.buffer;


% Read the fields
% ---------------
% Read signal and error
if read_se
    fseek(fid,pos.s,'bof');
    tmp = fread(fid, prod(sz), ['*',fmt.s]);
    data.s = reshape(double(tmp),sz);
    clear tmp

    fseek(fid,pos.e,'bof');
    tmp = fread(fid, prod(sz), ['*',fmt.e]);
    data.e = reshape(double(tmp),sz);
    clear tmp
end

% Read npix
if read_npix
    if numel(varargin)==0   % read whole array
        fseek(fid,pos.npix,'bof');
        tmp = fread(fid, prod(sz), ['*',fmt.npix]);
        if datastruct
            data.npix = reshape(double(tmp),sz);
        else
            data = reshape(double(tmp),sz);
        end
    else
        pos_start = pos.npix + fmt_nbytes(fmt.npix)*(varargin{1}(1)-1);
        fseek(fid,pos_start,'bof');
        tmp = fread(fid, diff(varargin{1}+1), ['*',fmt.npix]);
        if datastruct
            data.npix = double(tmp);
        else
            data = double(tmp);
        end
    end
    clear tmp
end

% Read urange
if read_urange
    fseek(fid,pos.urange,'bof');
    data.urange = fread(fid, [2,4], ['*',fmt.urange]);
end

% Read pix
if read_pix
    if numel(varargin)==0   % read whole array
        pos_start = pos.pix;
        npix_read = info.npixtot;
    else
        pos_start = pos.pix + 9*fmt_nbytes(fmt.pix)*(varargin{1}(1)-1);
        npix_read = diff(varargin{1})+1;
    end
    if npix_read>0
        fseek(fid,pos_start,'bof');
        tmp = fread(fid, [9,npix_read], ['*',fmt.pix]);
        if datastruct
            data.pix = double(tmp);
        else
            data = double(tmp);
        end
        clear tmp
    else
        if datastruct
            data.pix = zeros(9,0);
        else
            data = zeros(9,0);
        end
    end
end

% Special case of version 0 format: need to normalise signal and error by npix
if read_se && fmt_ver==appversion(0)     % read_se only can happen if read_npix too
    [data.s,data.e]=convert_signal_error(data.s,data.e,data.npix);
end

%==================================================================================================
function [s,e]=convert_signal_error(s,e,npix)
% Convert prototype (July 2007) format into standard format signal and error arrays
% Prototype format files have zeros for signal and variance arrays with no pixels
pixels = npix~=0;
s(pixels) = s(pixels)./npix(pixels);
e(pixels) = e(pixels)./(npix(pixels).^2);

function [mess,position,npixtot] = put_sqw_data_signal (fid, fmt_ver, data, varargin)
% Write data structure, with pixel data optionally coming from other source(s)
%
%   >> [mess,position,npixtot] = put_sqw_data_signal (fid, fmt_ver, data)
%   >> [mess,position,npixtot] = put_sqw_data_signal (fid, fmt_ver, data, p1, p2,...)
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary writing)
%   fmt_ver     Version of file format e.g. appversion('-v3')
%   data        Structure with fields to be written. Any of the fields below will be written
%              if they are present
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
%   p1,p2,...   [Optional] parameters that define pixels to be written from source(s)
%              other than the input argument 'data'. If data contains the field 'pix'
%              this will be ignored.
%
%
% Output:
% -------
%   mess        Error message; ='' if all OK, non-empty if a problem
%   position    Structure with positions of fields written; an entry is set to [] if
%              corresponding field was not written.
%       position.s      Start of signal array
%       position.e      Start of error array
%       position.npix   Start of npix array
%       position.urange Start of urange array
%       position.pix    Start of pix array
%
% It is already assumed that the data and the fields of data that reach this routine are
% consistent with the needs of the calling function. This routine merely writes whichever fields
% appear in the list {s,e,npix,urange,pix} with the appropriate format.

mess='';
position = struct('s',[],'e',[],'npix',[],'urange',[],'pix',[]);
npixtot=[];

names=fieldnames(data);

[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);
is_ver_lt_3p1=(fmt_ver<appversion(3,1));

% Write s and e
if any(strcmp(names,'s'))
    position.s=ftell(fid);
    fwrite(fid, single(data.s), 'float32');
end

if any(strcmp(names,'e'))
    position.e=ftell(fid);
    fwrite(fid, single(data.e), 'float32');
end

% Write npix
if any(strcmp(names,'npix'))
    position.npix=ftell(fid);
    fwrite(fid, int64(data.npix), 'int64');  % make int64 so that can deal with huge numbers of pixels
end

% Write urange
if any(strcmp(names,'urange'))
    position.urange=ftell(fid);
    fwrite(fid, data.urange, fmt_dble);
end

% Write pix
if any(strcmp(names,'pix')) || numel(varargin)>0
    % *** Redundant field prior to '-v3.1':
    if is_ver_lt_3p1
        fwrite(fid,1,'int32');
    end
    
    % Pixel information
    if numel(varargin)==0
        % Pixels to be written from structure
        npixtot=size(data.pix,2);
        fwrite(fid,npixtot,'int64');        % make int64 so that can deal with huge numbers of pixels

        position.pix=ftell(fid);
        npixchunk=get(hor_config,'mem_chunk_size');     % size of buffer to hold pixel information
        put_sqw_data_pix_array(fid, data.pix, npixchunk)
        
    else
        % Pixels to be written from other source(s), assumed consistent with data written so far
        % Overrides any pix information in the data structure
        % This function must write npixtot and pix arrays
        [mess,position.pix,npixtot] = put_sqw_data_pix_from_sources (fid, fmt_ver, varargin{:});
        
    end
end

%==================================================================================================
function put_sqw_data_pix_array(fid,pix,npixchunk)
% Write pix array - a subroutine to ensure standardised functinality for all writes
%
%   >> put_sqw_data_pix_array(fid, pix)

npixtot=size(pix,2);
if npixtot>0
    % Try writing large array of pixel information a block at a time - seems to speed up the write slightly
    % Need a flag to indicate if pixels are written or not, as cannot rely just on npixtot - we really
    % could have no pixels because none contributed to the given data range.
    if npixtot<=npixchunk
        fwrite(fid,single(pix),'float32');
    else
        for ipix=1:npixchunk:npixtot
            istart = ipix;
            iend   = min(ipix+npixchunk-1,npixtot);
            fwrite(fid,single(pix(:,istart:iend)),'float32');
        end
    end
end

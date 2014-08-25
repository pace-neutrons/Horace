function [mess,position,fieldfmt,npixtot] = put_sqw_data_signal (fid, fmt_ver, data, varargin)
% Write data structure, with pixel data optionally coming from other source(s)
%
%   >> [mess,position,fieldfmt,npixtot] = put_sqw_data_signal (fid, fmt_ver, data)
%   >> [mess,position,fieldfmt,npixtot] = put_sqw_data_signal (fid, fmt_ver, data, opt)
%   >> [mess,position,fieldfmt,npixtot] = put_sqw_data_signal (fid, fmt_ver, data, opt, p1, p2,...)
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary writing)
%
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
%   data        Structure with fields to be written. The type is assumed to be one of:
%                   'dnd'       dnd object or dnd structure:     s,e,npix
%                   'sqw_'      sqw structure without pix array: s,e,npix,urange & pix arguments (see below)
%                   'sqw'       sqw object or sqw structure:     s,e,npix,urange,pix
%                          *or* the same, but ignore pix array:  s,e,npix,urange & pix arguments (see below)
%                   'buffer'    buffer structure:                npix,pix
%                          *or* the same, but ignore pix array:  npix & pix arguments (see below)
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
%   opt         [Optional] Determine how to write data:
%                  '-pix'    Write pixel information, either from the data structure, or from the
%                            information in the additional optional arguments infiles...run_label (see below).
%                  '-buffer' Write npix and pix arrays only
%
%   p1,p2,...   [Optional] parameters that define pixels to be written from source(s)
%              other than the input argument 'data'. If data contains the field 'pix'
%              this will be ignored.
%
%
% Output:
% -------
%   mess        Error message; ='' if all OK, non-empty if a problem
%
%   position    Structure with positions of fields written; an entry is set to NaN if
%              corresponding field was not written.
%                   position.s      Start of signal array
%                   position.e      Start of error array
%                   position.npix   Start of npix array
%                   position.urange Start of urange array
%                   position.pix    Start of pix array
%
%   fieldfmt    Structure with format of fields written; an entry is set to '' if
%              corresponding field was not written.
%                   fieldfmt.s         
%                   fieldfmt.e          
%                   fieldfmt.npix       
%                   fieldfmt.urange    
%                   fieldfmt.npix_nz   
%
%   npixtot     Total number of pixels actually written by the call to this function
%              (=NaN if pix not written)
%
% It is already assumed that the data and the fields of data that reach this routine are
% consistent with the needs of the calling function.

mess='';
position = struct('s',NaN,'e',NaN,'npix',NaN,'urange',NaN,'pix',NaN);
fieldfmt = struct('s','','e','','npix','','urange','','pix','');
npixtot=NaN;

if numel(varargin)>0
    if strcmpi(varargin{1},'-buffer')
        buffer=true;
    elseif strcmpi(varargin{1},'-pix')
        buffer=false;
    else
        mess='Logic error in put_sqw functions. See T.G.Perring';
        return
    end
end

[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);

% Write signal, variance
if ~buffer
    position.s=ftell(fid);
    fieldfmt.s='float32';
    fwrite(fid, single(data.s), 'float32');

    position.e=ftell(fid);
    fieldfmt.e='float32';
    fwrite(fid, single(data.e), 'float32');
end

% Write npix
position.npix=ftell(fid);
fieldfmt.npix='int64';
fwrite(fid, int64(data.npix), 'int64');  % make int64 so that can deal with huge numbers of pixels

% Write urange
if ~buffer && isfield(data,'urange')
    position.urange=ftell(fid);
    fieldfmt.urange=fmt_dble;
    fwrite(fid, data.urange, fmt_dble);
end

% Write pixel information
if isfield(data,'pix') || numel(varargin)>1
    % *** Redundant field prior to '-v3.1':
    if fmt_ver<appversion(3,1)
        fwrite(fid,1,'int32');
    end
    
    % Pixel information
    if numel(varargin)<=1
        % Pixels to be written from structure
        npixtot=size(data.pix,2);
        fwrite(fid,npixtot,'int64');        % make int64 so that can deal with huge numbers of pixels

        position.pix=ftell(fid);
        npixchunk=get(hor_config,'mem_chunk_size');     % size of buffer to hold pixel information
        fieldfmt.pix=put_sqw_data_pix_array(fid, data.pix, npixchunk);
        
    else
        % Pixels to be written from other source(s), assumed consistent with data written so far
        % Overrides any pix information in the data structure
        % This function must write npixtot and pix array
        [mess,position.pix,fieldfmt.pix,npixtot] = put_sqw_data_pix_from_sources (fid, fmt_ver, varargin{2:end});
        
    end
end

%==================================================================================================
function fieldfmt=put_sqw_data_pix_array(fid,pix,npixchunk)
% Write pix array - a subroutine to ensure standardised functionality for all writes
%
%   >> put_sqw_data_pix_array(fid, pix)

fieldfmt=[];
npixtot=size(pix,2);
if npixtot>0
    % Try writing large array of pixel information a block at a time - seems to speed up the write slightly
    % Need a flag to indicate if pixels are written or not, as cannot rely just on npixtot - we really
    % could have no pixels because none contributed to the given data range.
    fieldfmt='float32';
    if npixtot<=npixchunk
        fwrite(fid,single(pix),fieldfmt);
    else
        for ipix=1:npixchunk:npixtot
            istart = ipix;
            iend   = min(ipix+npixchunk-1,npixtot);
            fwrite(fid,single(pix(:,istart:iend)),fieldfmt);
        end
    end
end

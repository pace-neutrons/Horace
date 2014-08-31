function [mess,data] = get_sqw_data_signal_sparse (fid, fmt_ver, varargin)
% Read data structure from sparse format file
%
%   >> [mess, data] = get_sqw_data_signal_sparse (fid, fmt_ver)
%   >> [mess, data] = get_sqw_data_signal_sparse (fid, fmt_ver, '-skip')
%   >> [mess, data] = get_sqw_data_signal_sparse (fid, fmt_ver, '-dnd')
%   >> [mess, data] = get_sqw_data_signal_sparse (fid, fmt_ver, '-nopix')
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary reading). The file position
%              indicator on entry to be at the start of the signal array.
%   fmt_ver     Version of file format e.g. appversion('-v3')
%   opt         [Optional] control which fields to read
%                   '-skip'     Do not read any information into data
%                   '-dnd'      Only read fields s,e,n
%                   '-nopix'    Do not read pix array
%
% Output:
% -------
%   mess        Error message; ='' if all OK, non-empty if a problem
%
%   data        Contains data read from file )if '-skip'
%                   dnd-type data read from file: s,e,npix
%                   sqw-type data read from file: s,e,npix,urange,npix_nz,pix_nz,pix
%                   '-skip' : empty strucure, struct()
%                   '-nopix':   'a-' format data: s,e,npix,urange
%               where the fields are:
%       data.s          Average signal in the bins (sparse column vector)
%       data.e          Corresponding variance in the bins (sparse column vector)
%       data.npix       Number of contributing pixels to each bin as a sparse column vector
%       data.urange     True range of the data along each axis [urange(2,4)]. This is in the
%                      coordinates of the plot/integration projection axes, NOT the projection
%                      axes of the individual pixel info.
%       data.npix_nz    Number of non-zero pixels in each bin (sparse column vector)
%       data.pix_nz     Array with idet,ien,s,e for the pixels with non-zero signal sorted so that
%                      all the pixels in the first bin appear first, then all the pixels in the
%                      second bin etc.
%       data.pix        Index of pixels, sorted so that all the pixels in the first
%                      bin appear first, then all the pixels in the second bin etc. (column vector)
%                           ipix = ie + ne*(id-1)
%                       where
%                           ie  energy bin index
%                           id  detector index into list of all detectors (i.e. masked and unmasked)
%                           ne  number of energy bins


mess='';
position = struct('s',[],'e',[],'npix',[],'urange',[],'npix_nz',[],'pix_nz',[],'pix',[]);
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


% Read s, e, npix
% ---------------
position.s=ftell(fid);
if ~skip
    [data.s,ok,mess] = read_sparse(fid);
else
    [tmp,ok,mess] = read_sparse(fid,skip);
end
if ~all(ok); return; end;

position.e=ftell(fid);
if ~skip
    [data.e,ok,mess] = read_sparse(fid);
else
    [tmp,ok,mess] = read_sparse(fid,skip);
end
if ~all(ok); return; end;

position.npix=ftell(fid);
if ~skip
    [data.npix,ok,mess] = read_sparse2(fid);
else
    [tmp,ok,mess] = read_sparse2(fid,skip);
end
if ~all(ok); return; end;


% Read urange
% -----------
position.urange=ftell(fid);
if ~skip && ~skip_urange
    data.urange = fread(fid, [2,4], fmt_dble);
else
    fseek(fid,8*nbyte_dble,'cof');
end


% Read pixel information
% ----------------------
% npixtot_nz, npixtot
***
npixtot=fread(fid, 1, 'int64');

% npix_nz
position.npix_nz=ftell(fid);
if ~skip
    [data.npix,ok,mess] = read_sparse2(fid);
else
    [tmp,ok,mess] = read_sparse2(fid,skip);
end
if ~all(ok); return; end;

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

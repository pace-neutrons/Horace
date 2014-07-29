function [mess,position,npixtot] = put_sqw_data_signal_sparse (fid, fmt_ver, data, varargin)
% Write sparse data structure, with pixel data optionally coming from other source(s)
%
%   >> [mess,position,npixtot] = put_sqw_data_signal_sparse (fid, fmt_ver, data)
%   >> [mess,position,npixtot] = put_sqw_data_signal_sparse (fid, fmt_ver, data, p1, p2,...)
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary writing)
%   fmt_ver     Version of file format e.g. appversion('-v3')
%   data        Structure with fields to be written. Any of the fields below will be written
%              if they are present (all three of npix_nz,pix_nz and pix must be present for
%              the pixel information to be written)
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
%       position.s          Start of signal array
%       position.e          Start of error array
%       position.npix       Start of npix array
%       position.urange     Start of urange array
%       position.npix_nz    Start of npix_nz array
%       position.pix_nz     Start of pix_nz array
%       position.pix        Start of pix array
%
% It is already assumed that the data and the fields of data that reach this routine are
% consistent with the needs of the calling function. This routine merely writes whichever fields
% appear in the list {s,e,npix,urange,npix_nz,pix_nz,pix} with the appropriate format. Note that
% all three of npix_nz,pix_nz,pix must appear for the pixel information to be written.

mess='';
position = struct('s',[],'e',[],'npix',[],'urange',[],'npix_nz',[],'pix_nz',[],'pix',[]);
npixtot=[];

names=fieldnames(data);

% Determine if definitely only one spe file contributing
if any(strcmp(names,'pix_nz')) && (size(data.pix_nz,1)==4)
    ***
    single_file=true;       % columns are id, ie, s, e; we therefore know that there is only one contributing file
else
    single_file=false;
end

% Write signal, variance and npix arrays
if any(strcmp(names,'s'))
    position.s=ftell(fid);
    write_sparse(fid,data.s,'float32');
end

if any(strcmp(names,'e'))
    position.e=ftell(fid);
    write_sparse(fid,data.e,'float32');
end

if any(strcmp(names,'npix'))
    if single_file
        position.npix=ftell(fid);
        write_sparse2(fid,data.npix,'int32');    % can assume there are less than 2e9 pixels
    else
        position.npix=ftell(fid);
        write_sparse2(fid,data.npix,'int64');    % allow for more than 2e9 pixels
    end
end

% Write urange
if any(strcmp(names,'urange'))
    position.urange=ftell(fid);
    fwrite(fid,data.urange,'float64');
end

% Write pixel information
if any(strcmp(names,'pix')) || numel(varargin)>0
    if numel(varargin)==0
        % Pixels to be written from from structure, if present
        if any(strcmp(names,'npix_nz')) && any(strcmp(names,'pix_nz')) && any(strcmp(names,'pix'))
            fwrite(fid,size(data.pix_nz),'float64')
            fwrite(fid,numel(data.pix),'float64');

            position.npix_nz=ftell(fid);
            if single_file
                write_sparse2(fid,data.npix_nz,'int32');     % can assume there are less than 2e9 pixels
            else
                write_sparse2(fid,data.npix_nz,'int64');     % allow for more than 2e9 pixels
            end
            
            position.pix_nz=ftell(fid);
            fwrite(fid,single(data.pix_nz),'float32');
            
            position.pix=ftell(fid);
            if single_file
                fwrite(fid,int32(data.pix),'int32');    % can assume there are less than 2e9 pixels
            else
                fwrite(fid,int32(data.pix),'int64');    % allow for more than 2e9 pixels
            end
            npixtot=numel(data.pix);
        end
    else
        % Pixels to be written from other source(s), assumed consistent with data written so far
        % Overrides any pix information in the data structure
        % This function must write npixtot and pix arrays
        mess='Cannot write sparse pixel information from source other that data structure';
        return
    end
end

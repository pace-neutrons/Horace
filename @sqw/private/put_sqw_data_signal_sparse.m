function [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data_signal_sparse (fid, fmt_ver, data, varargin)
% Write sparse data structure, with pixel data optionally coming from other source(s)
%
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data_signal_sparse (fid, fmt_ver, data)
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data_signal_sparse (fid, fmt_ver, data, opt_name)
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data_signal_sparse (fid, fmt_ver, data, opt_name, p1, p2,...)
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary writing)
%
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
%   data        Structure with fields to be written. The type is assumed to be one of:
%                   'dnd_sp'    dnd object or dnd structure:     s,e,npix
%                   'sqw_sp_'   sqw structure without pix array: s,e,npix,urange & pix arguments (see below)
%                   'sqw_sp'    sqw object or sqw structure:     s,e,npix,urange,npix_nz,pix_nz,pix
%                          *or* the same, but ignore pix array:  s,e,npix,urange & pix arguments (see below)
%                   'buffer_sp' buffer structure:                npix,npix_nz,pix_nz,pix
%                          *or* the same, but ignore pix array:  npix & pix arguments (see below)
%       data.s          Average signal in the bins (sparse column vector)
%       data.e          Corresponding variance in the bins (sparse column vector)
%       data.npix       Number of contributing pixels to each bin as a sparse column vector
%       data.urange     True range of the data along each axis [urange(2,4)]. This is in the
%                      coordinates of the plot/integration projection axes, NOT the projection
%                      axes of the individual pixel info.
%       data.pix_nz Array with columns containing [id,ie,s,e]' for the pixels with non-zero
%                  signal sorted so that all the pixels in the first bin appear first, then
%                  all the pixels in the second bin etc. Here
%                           ie      In the range 1 to ne (the number of energy bins
%                           id      In the range 1 to ndet (the number of detectors)
%                  but these are NOT the energy bin and detector indicies of a pixel; instead
%                  they are the pair of indicies into the location in the pix array below.
%                           ind = ie + ne*(id-1)
%
%                   If more than one run contributed, array contains ir,id,ie,s,e, where
%                           ir      In the range 1 to nrun (the number of runs)
%                  In this case, ir adds a third index into the pix array, and 
%                           ind = ie + max(ne)*(id-1) + ndet*max(ne)*(ir-1)
%
%       data.pix    Pixel index array, sorted so that all the pixels in the first
%                  bin appear first, then all the pixels in the second bin etc. (column vector)
%                   The pixel index is defined by the energy bin number and detector number:
%                           ipix = ien + ne*(idet-1)
%                       where
%                           ien     energy bin index
%                           idet    detector index into list of all detectors (i.e. masked and unmasked)
%                           ne      number of energy bins
%
%                   If more than one run contributed, then
%                           ipix = ien + max(ne)*(idet-1) + ndet*max(ne)*(irun-1)
%                       where in addition
%                           irun    run index
%                           ne      array with number of energy bins for each run
%
%   opt_name    [Optional] Determine how to write data:
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
%                   position.s          Start of signal array
%                   position.e          Start of error array
%                   position.npix       Start of npix array
%                   position.urange     Start of urange array
%                   position.npix_nz    Start of npix_nz array
%                   position.pix_nz     Start of pix_nz array
%                   position.pix        Start of pix array
%
%   fieldfmt    Structure with format of fields written; an entry is set to '' if
%              corresponding field was not written.
%                   fieldfmt.s
%                   fieldfmt.e
%                   fieldfmt.npix
%                   fieldfmt.urange
%                   fieldfmt.npix_nz
%                   fieldfmt.pix_nz
%                   fieldfmt.pix
%
%   npixtot     Total number of pixels actually written by the call to this function
%              (=NaN if pix not written)
%
%   npixtot_nz  Total number of pixels with non-zero signal actually written by the call to this function
%              (=NaN if pix not written, =0 if pix written but not sparse format)
%
% It is already assumed that the data and the fields of data that reach this routine are
% consistent with the needs of the calling function.


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


mess='';
position = struct('s',NaN,'e',NaN,'npix',NaN,'urange',NaN,'npix_nz',NaN,'pix_nz',NaN,'pix',NaN);
fieldfmt = struct('s','','e','','npix','','urange','','npix_nz','','pix_nz','','pix','');
npixtot=NaN;
npixtot_nz=NaN;

if numel(varargin)>0
    if strcmp(varargin{1},'-buffer')
        buffer=true;
    elseif strcmp(varargin{1},'-pix')
        buffer=false;
    else
        mess='Logic error in put_sqw functions. See T.G.Perring';
        return
    end
else
    buffer=false;
end

% Determine if definitely only one spe file contributing
if isfield(data,'pix_nz') && (size(data.pix_nz,1)==4)
    single_file=true;       % columns are id, ie, s, e; we therefore know that there is only one contributing file
else
    single_file=false;
end

% Write signal, variance
if ~buffer
    position.s=ftell(fid);
    fieldfmt.s='float32';
    write_sparse(fid,data.s,'float32');
    
    position.e=ftell(fid);
    fieldfmt.e='float32';
    write_sparse(fid,data.e,'float32');
end

% Write npix
if single_file
    position.npix=ftell(fid);
    fieldfmt.npix='int32';
    write_sparse2(fid,data.npix,'int32');    % can assume there are less than 2e9 pixels
else
    position.npix=ftell(fid);
    fieldfmt.npix='float64';
    write_sparse2(fid,data.npix,'float64');  % allow for more than 2e9 pixels
end

% Write urange
if ~buffer && isfield(data,'urange')
    position.urange=ftell(fid);
    fieldfmt.urange='float64';
    fwrite(fid,data.urange,'float64');
end

% Write pixel information
if isfield(data,'pix') || numel(varargin)>1
    if numel(varargin)<=1
        % Pixels to be written from from structure
        npixtot_nz=size(data.pix_nz,2);
        npixtot=numel(data.pix);
        fwrite(fid,size(data.pix_nz),'float64');
        fwrite(fid,npixtot,'float64');
        
        if single_file
            position.npix_nz=ftell(fid);
            fieldfmt.npix_nz='int32';
            write_sparse2(fid,data.npix_nz,'int32');    % can assume there are less than 2e9 pixels
            
            position.pix_nz=ftell(fid);
            fieldfmt.pix_nz='float32';
            fwrite(fid,single(data.pix_nz),'float32');
            
            position.pix=ftell(fid);
            fieldfmt.pix='int32';
            fwrite(fid,int32(data.pix),'int32');        % can assume there are less than 2e9 pixels
        else
            position.npix_nz=ftell(fid);
            fieldfmt.npix_nz='float64';
            write_sparse2(fid,data.npix_nz,'float64');  % allow for more than 2e9 pixels
            
            position.pix_nz=ftell(fid);
            fieldfmt.pix_nz='float32';
            fwrite(fid,single(data.pix_nz),'float32');
            
            position.pix=ftell(fid);
            fieldfmt.pix='float64';
            fwrite(fid,data.pix,'float64');             % allow for more than 2e9 pixels
        end
        
    else
        % Pixels to be written from other source(s), assumed consistent with data written so far
        % Overrides any pix information in the data structure
        % This function must write:
        %   - size(pix_nz)
        %   - npixtot
        %   - npix_nz, pix_nz, pix arrays in sparse format
        % Return 
        %   - positions of the starts of npix_nz, pix_nz, pix arrays as a structure with those names
        %   - formats of those three arrays as a structure with those names
        %
        % [mess,position_sp,fieldfmt_sp,npixtot,npixtot_nz] = put_sqw_data_pix_from_sources_sparse (fid, fmt_ver, varargin{2:end});
        mess='Cannot write sparse pixel information from sources other than the input data structure';
        return
    end
end

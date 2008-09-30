function [mess,position,npixtot,type] = put_sqw_data (fid, data, opt, infiles, npixstart, pixstart, run_label)
% Write data to binary file
%
%   >> [mess, position, npixtot, type] = write (fid, data)
%   >> [mess, position, npixtot, type] = write (fid, data, '-nopix')
%   >> [mess, position, npixtot, type] = write (fid, data, '-pix')
%   >> [mess, position, npixtot, type] = write (fid, data, '-pix', infiles, npixstart, pixstart, run_label)
%
% Input:
% -------
%   fid         File identifier of output file (opened for binary writing)
%   data        Valid sqw data structure which must contain the fields listed below 
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%               In addition, will take the data structure of type 'a' without the individual pixel information ('a-')
%                       type 'a-'   uoffset,...,s,e,npix,urange
%
%   opt         [optional argument for type 'a' or type 'a-'] Determines whether or not to write pixel info, and
%               from which source:
%                 -'-nopix'  do not write the info for individual pixels
%                 -'-pix'    write pixel information
%               The default source of pixel information is the data structure, but if the optional arguments below
%               are given, then use the corresponding source of pixel information
%                 - structure with fields:
%
%   infiles     Cell array of file names, or array of file identifiers of open file, from
%                                   which to accumulate the pixel information
%   npixstart   Position (in bytes) from start of file of the start of the field npix
%   pixstart    Position (in bytes) from start of file of the start of the field pix
%   run_label   Indicates how to re-label the run index (pix(5,...) 
%                       'fileno'    relabel run index as the index of the file in the list infiles
%                       'nochange'  use the run index as in the input file
%                   This option exists to deal with the two limiting cases 
%                    (1) There is one file per run, and the run index in the header block is the file
%                       index e.g. as in the creating of the master sqw file
%                    (2) The run index is already written to the files correctly indexed into the header
%                       e.g. as when temporary files have been written during cut_sqw
%
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%   position    Position (in bytes from start of file) of large fields:
%                   position.s      position of array s
%                   position.e      position of array e
%                   position.npix   position of array npix (=[] if npix not written)
%                   position.pix    position of array pix (=[] if pix not written)
%   npixtot     Total number of pixels written to file (=[] if pix not written)
%   type        Type of sqw data written to file: 'a', 'a-', 'b+' or 'b'
%
%
% Fields written to the file are:
%   data.filename   Name of sqw file that is being read, excluding path
%   data.filepath   Path to sqw file that is being read, including terminating file separator
%   data.title      Title of sqw data structure
%   data.alatt      Lattice parameters for data field (Ang^-1)
%   data.angdeg     Lattice angles for data field (degrees)
%   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
%                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
%   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
%   data.iax        Index of integration axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
%   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
%                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
%   data.pax        Index of plot axes into the projection axes  [row vector]
%                  Always in increasing numerical order
%                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
%                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.p          Call array containing bin boundaries along the plot axes [column vectors]
%                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
%   data.dax        Index into data.pax of the axes for display purposes. For example we may have 
%                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
%                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
%                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
%                  be reordered [row vector]
%   data.s          Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.e          Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.npix       No. contributing pixels to each bin of the plot axes.
%                  [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.urange     True range of the data along each axis [urange(2,4)]. This is in the coordinates of the
%                  plot/integration projection axes, NOT the projection axes of the individual pixel info.
%   data.pix        Array containing data for each pixel:
%                  If npixtot=sum(npix), then pix(9,npixtot) contains:
%                   u1      -|
%                   u2       |  Coordinates of pixel in the projection axes of the original sqw file(s)
%                   u3       |
%                   u4      -|
%                   irun        Run index in the header block from which pixel came
%                   idet        Detector group number in the detector listing for the pixel
%                   ien         Energy bin number for the pixel in the array in the (irun)th header
%                   signal      Signal array
%                   err         Error array (variance i.e. error bar squared)
%
% Notes:
% ------
%   There are some other items written to the file to help when reading the file using get_sqw_data. 
% These are indicated by comments in the code.
%
%   The data for the individual pixels is expressed in the projection axes of the original
% contributing sqw files, as is recorded in the corresponding header block (see put_sqw_header).
% The arguments u_to_rlu, ulen, ulabel refer to the projection axes used for the plot and integration
% axes, and give the units in which the bin boundaries p are expressed.
%   The reason why we keep the coordinate frames separate is that in succesive cuts from sqw data
% structures we are constantly recomputing the coordinates of pixels in the plot/integration projection
% axes. We therefore do not want to allow rouding errors to accumulate, and so retain the original
% data points in their original coordinate frame.
%
%   It is assumed that the data corresponds to a valid type (i.e. that any use with implementation of sqw as
%   a proper object has already checked the consistency of the fields)
%
%
%
% Comparison with Horace v1
% -------------------------
% - uoffset is identical to p0 in Horace v.1; renamed to avoid confusion
% - iint is identical to uint in Horace v.1; renamed to avoid confusion
% - plot axes bin boundaries now a cell array

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

mess = '';
position=[];
npixtot=[];
type='';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Determine type of structure and write options
type_in = sqw_data_type(data);
type = type_in;
if strcmpi(type_in,'b')||strcmpi(type_in,'b+')
    if exist('opt','var')
        disp('WARNING: options specified in put_sqw_data ignored for this sqw type')
    end
elseif strcmpi(type_in,'a')    % pixel info will be written from data, nless
    if ~exist('opt','var')
        pix_from_struct = true;
        pix_from_file = false;
    elseif ischar(opt) && strcmpi(opt,'-nopix')
        pix_from_struct = false;
        pix_from_file = false;
    elseif ischar(opt) && strcmpi(opt,'-pix')
        if nargin==3        % no pixel file info
            pix_from_struct = true;
            pix_from_file = false;
        elseif nargin==7    % pixel file information
            pix_from_struct = false;
            pix_from_file = true;
        else
            mess = 'Check number of input arguments (type of input data is ''a'')';
            return
        end
    else
        mess = 'Unrecognised option';
        return
    end
elseif strcmpi(type_in,'a-')
    if ~exist('opt','var')
        pix_from_struct = false;
        pix_from_file = false;
    elseif ischar(opt) && strcmpi(opt,'-nopix')
        pix_from_struct = false;
        pix_from_file = false;
    elseif ischar(opt) && strcmpi(opt,'-pix')
        if nargin==7    % pixel file information
            pix_from_struct = false;
            pix_from_file = true;
        else
            mess = 'Check number of input arguments (type of input data is ''a-'')';
            return
        end
    else
        mess = 'Unrecognised option';
        return
    end
else
    error('logic error in put_sqw_data')
end


% Write to file
n=length(data.filename);
fwrite(fid,n,'int32');              % write length of filename
fwrite(fid,data.filename,'char');

n=length(data.filepath);
fwrite(fid,n,'int32');              % write length of filepath
fwrite(fid,data.filepath,'char');

n=length(data.title);
fwrite(fid,n,'int32');              % write length of title
fwrite(fid,data.title,'char');

fwrite(fid,data.alatt,'float32');
fwrite(fid,data.angdeg,'float32');
fwrite(fid,data.uoffset,'float32');
fwrite(fid,data.u_to_rlu,'float32');
fwrite(fid,data.ulen,'float32');

ulabel=char(data.ulabel);
n=size(ulabel);
fwrite(fid,n,'int32');      % write size of character array of the axes labels
fwrite(fid,ulabel,'char'); 

npax = length(data.pax);    % write number plot axes - gives the dimensionality of the plot
niax = 4 - npax;
fwrite(fid,npax,'int32');

if niax>0
    fwrite(fid,data.iax,'int32');
    fwrite(fid,data.iint,'float32');
end

if npax>0
    fwrite(fid,data.pax,'int32');
    for i=1:npax
        np=length(data.p{i});   % write length of vector data.p{i}
        fwrite(fid,np,'int32');
        fwrite(fid,data.p{i},'float32');
    end
    fwrite(fid,data.dax,'int32');
end

position.s=ftell(fid);
fwrite(fid,data.s,'float32');

position.e=ftell(fid);
fwrite(fid,data.e,'float32');


% Optional fields depending on input data structure and options
position.npix=[];
position.pix=[];
npixtot=[];

if strcmpi(type_in,'a')||strcmpi(type_in,'a-')||strcmpi(type_in,'b+')
    position.npix=ftell(fid);
    fwrite(fid,data.npix,'int64');  % make int64 so that can deal with huge numbers of pixels
end

if strcmpi(type_in,'a')||strcmpi(type_in,'a-')
    % Write urange
    fwrite(fid,data.urange,'float32');
    % Write pix if requested
    if pix_from_struct
        fwrite(fid,1,'int32');          % redundant field - only present for backwards compatibility
        npixtot=size(data.pix,2);
        fwrite(fid,npixtot,'int64');    % make int64 so that can deal with huge numbers of pixels
        position.pix=ftell(fid);
        type='a';
        % Try writing large array of pixel information a block at a time - seems to speed up the write slightly
        % Need a flag to indicate if pixels are written or not, as cannot rely just on npixtot - we really
        % could have no pixels because none contributed to the given data range.
        block_size=1000000;
        for ipix=1:block_size:npixtot
            istart = ipix;
            iend   = min(ipix+block_size-1,npixtot);
            fwrite(fid,data.pix(:,istart:iend),'float32');
        end
    elseif pix_from_file
        fwrite(fid,1,'int32');              % redundant field - only present for backwards compatibility
        npix_cumsum = cumsum(data.npix(:)); % accumulated number of pixels per bin as a column vector
        npixtot=npix_cumsum(end);
        fwrite(fid,npixtot,'int64');        % make int64 so that can deal with huge numbers of pixels
        position.pix=ftell(fid);
        type='a';
        mess = put_sqw_data_pix_from_file (fid, infiles, npixstart, pixstart, npix_cumsum, run_label);
    else
        type='a-';
    end
end

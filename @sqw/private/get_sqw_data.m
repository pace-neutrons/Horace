function [mess, data] = get_sqw_data (fid, fmt_ver, sparse_fmt, datastruct, make_full_fmt, opt, opt_name, varargin)
% Read the data block or field from the data block in an sqw file.
%
%   >> [mess, data] = get_sqw_data (fid, fmt_ver, datastruct, make_full_fmt, opt, opt_name, varargin);
%
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%
%   fmt_ver         Version of file format e.g. appversion('-v3')
%
%   sparse_fmt      Data format: =true if sparse format, =false if non-sparse format
%
%   datastruct      Signifies data to be read:
%                     - true  if a data structure ('-dnd','-sqw','-h*','-nopix','-buffer')
%                     - false if a field from the data
%
%   make_full_fmt   Data is sparse format but conversion to non-sparse is requested
%
%   opt             Structure with fields set to true or false according to the option:
%                       'dnd','sqw','h','his','hverbatim','hisverbatim','nopix','buffer'
%                       'npix','npix_nz','pix_nz','pix'
%
%   opt_name        Option as character string
%                       '-dnd','-sqw','-h','-his','-hverbatim','-hisverbatim','-nopix','-buffer'
%                       'npix','npix_nz','pix_nz','pix'
%                   If no option, opt_name=''
%
%   optvals         Optional arguments (={} if none)
%
%   p1,p2,...   [optional Parameters as required/optional with the different values of opt
%
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%
%   data            Structure containing fields read from file. If a single field was
%                  requested, then this is returned as the relevant type.
%
%
% It is assumed that the options are consistent with the data in the file - this
% should have already been checked by the call to get_sqw.
%
%
% Fields read from file are:
% --------------------------
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
%
% If standard sqw format:
%   data.s          Average signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.e          Average variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
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
% If sparse format:
%   data.s          Average signal in the bins as a sparse column vector
%   data.e          Corresponding variance in the bins (sparse column vector)
%   data.npix       Number of contributing pixels to each bin as a sparse column vector
%   data.urange     <as above>
%   data.npix_nz    Number of non-zero pixels in each bin (sparse column vector)
%   data.pix_nz     Array with idet,ien,s,e for the pixels with non-zero signal sorted so that
%                  all the pixels in the first bin appear first, then all the pixels in the second bin etc.
%                  If more than one run contributed, array contains irun,idet,ien,s,e.
%   data.pix        Index of pixels, sorted so that all the pixels in the first
%                  bin appear first, then all the pixels in the second bin etc. (column vector)
%                           ipix = ie + ne*(id-1)
%                       where
%                           ie  energy bin index
%                           id  detector index into list of all detectors (i.e. masked and unmasked)
%                           ne  number of energy bins
%                       If more than one run contributed, then
%                           ipix = ie + ne*(id-1) + cumsum(ne(1:irun-1))*ndet


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Initialise output arguments

[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);

read_header = (datastruct && ~opt.buffer);


% Read header information from file
% ---------------------------------
if read_header
    if fmt_ver>appversion(0)
        filename = read_sqw_var_char (fid,fmt_ver);
        filepath = read_sqw_var_char (fid,fmt_ver);
        if hverbatim
            % Read filename and path from file
            data.filename=filename;
            data.filepath=filepath;
        else
            % Get file name and path (incl. final separator)
            [path,name,ext]=fileparts(fopen(fid));
            data.filename=[name,ext];
            data.filepath=[path,filesep];
        end
        data.title  = read_sqw_var_char (fid,fmt_ver);
        data.alatt  = fread(fid, [1,3], fmt_dble);
        data.angdeg = fread(fid, [1,3], fmt_dble);
        
    else
        % Get file name and path (incl. final separator)
        [path,name,ext]=fileparts(fopen(fid));
        data.filename=[name,ext];
        data.filepath=[path,filesep];
        % Put empty information in fields not in the file, to be filled outside this routine
        data.title = '';
        data.alatt = zeros(1,3);
        data.angdeg = zeros(1,3);
    end
    
    data.uoffset  = fread(fid, [4,1], fmt_dble);
    data.u_to_rlu = fread(fid, [4,4], fmt_dble);
    data.ulen     = fread(fid, [1,4], fmt_dble);
    
    data.ulabel=read_sqw_var_char (fid,fmt_ver,true)';
    
    npax = fread(fid, 1, fmt_int);
    niax=4-npax;
    if niax>0
        data.uoffset = fread(fid, [1,niax], fmt_int);
        data.uoffset = fread(fid, [2,niax], fmt_dble);
    else
        data.iax=zeros(1,0);    % create empty index of integration array in standard form
        data.iint=zeros(2,0);
    end
    
    if npax>0
        data.pax = fread(fid, [1,npax], fmt_int);
        data.p=cell(1,npax);
        sz=ones(1,max(npax,2));  % will contain size array of signal, error and npix arrays
        for i=1:npax
            np = fread(fid, 1, fmt_int);
            data.p{i} = fread(fid, [np,1], fmt_int);
            sz(i)=np-1;
        end
        data.dax = fread(fid, [1,npax], fmt_int);
    else
        data.pax=zeros(1,0);    % create empty index of plot axes
        data.p=cell(1,0);
        data.dax=zeros(1,0);    % create empty index of plot axes
        sz=[1,1];    % to hold a scalar
    end
    
end


% Read signal information from file, if requested
% -----------------------------------------------
% Even if no data is read from the file, we must skip to the end of the data section

if ~sparse_fmt
    % Non-sparse data format
    [mess,data] = get_sqw_data_signal (fid, fmt_ver, is_sqw, sz, opt);
    
else
    % Sparse data format
    
end

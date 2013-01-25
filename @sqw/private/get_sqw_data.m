function [data, mess, position, npixtot, type] = get_sqw_data (fid, varargin)
% Read the data block from an sqw file.
% The file pointer is left at the end of the data block.
%
% Syntax:
%   >> [data, mess] = get_sqw_data(fid)
%   >> [data, mess] = get_sqw_data(fid, opt)
%   >> [data, mess] = get_sqw_data(fid, npix_lo, npix_hi)
%
% To any of the above: to read original prototype format file
%   >> [data, mess] = get_sqw_data(..., '-prototype')
%
%   * The fields filename, filepath, title, alatt, and angdeg are not stored in this prototype format,
%     Fields filename and filepath are constructed in this routine, but title, alatt and angdeg are
%     just given dummy values which must be filled from the main_header and header information.
%
%   * This option is not compatible with files of type 'b', because the npix information is needed to convert
%     the signal and error in each bin into the new format by normalising by number of pixels in each bin.
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     [optional] Data structure to which the data fields below will be added or overwrite.
%   opt         [optional] Determines which fields to read
%                   '-h'     header-type information only: fields read: 
%                               filename, filepath, title, alatt, angdeg,...
%                                   uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                              (If file was written from a structure of type 'b' or 'b+', then
%                               urange does not exist, and the output field will not be created)
%                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-nopix' Pixel information not read (only meaningful for sqw data type 'a')
%
%                    Default: read all fields of the corresponding sqw data type ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file 
%   npix_hi     -|
%
% Output:
% -------
%   data        Output data structure which must contain the fields listed below 
%                       type 'b'    fields: filename,...,dax,s,e
%                       type 'b+'   fields: filename,...,dax,s,e,npix
%                       type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                       type 'a-'   fields: filename,...,dax,s,e,npix,urange
%               or header information   
%   mess        Error message; blank if no errors, non-blank otherwise
%   position    Position (in bytes from start of file) of large fields:
%                   position.s      position of array s
%                   position.e      position of array e
%                   position.npix   position of array npix (=[] if npix not present)
%                   position.pix    position of array pix (=[] if pix not present)
%   npixtot     Total number of pixels written to file (=[] if pix not present)
%   type        Type of sqw data written to file: 
%               Valid sqw data structure, which will contain the fields listed below 
%                       type 'b'    fields: filename,...,dax,s,e
%                       type 'b+'   fields: filename,...,dax,s,e,npix
%                       type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%               or if the pix field is not read from type 'a', in which case 
%                       type 'a-'   fields: filename,...,dax,s,e,npix,urange
%
%
% Fields read from the file are:
%
%   data.filename   Name of sqw file that is being read, excluding path
%   data.filepath   Path to sqw file that is being read, including terminating file separator
%          [Note that the filename and filepath that are written to file are ignored; we fill with the 
%           values corresponding to the file that is being read.]
%
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
%   data.p          Cell array containing bin boundaries along the plot axes [column vectors]
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
%   data.urange     True range of the data along each axis [urange(2,4)]
%   data.pix        Array containing data for eaxh pixel:
%                  If npixtot=sum(npix), then pix(9,npixtot) contains:
%                   u1      -|
%                   u2       |  Coordinates of pixel in the projection axes
%                   u3       |
%                   u4      -|
%                   irun        Run index in the header block from which pixel came
%                   idet        Detector group number in the detector listing for the pixel
%                   ien         Energy bin number for the pixel in the array in the (irun)th header
%                   signal      Signal array
%                   err         Error array (variance i.e. error bar squared)
%
%
% Notes:
% ------
%   It is assumed that the file corresponds to a valid type (i.e. that any use with implementation of sqw as
%   a proper object has already checked the consistency of the fields).

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

data=[];
position=[];
npixtot=[];
type='';

% Determine if asked to read prototype format
if nargin>2 && ischar(varargin{end}) && strcmpi(varargin{end},'-prototype')
    prototype=true;
    nargs=numel(varargin)-1;
    args=varargin(1:end-1);
else
    prototype=false;
    nargs=numel(varargin);
    args=varargin;
end

% Parse input
if nargs==1 && ischar(args{1})
    opt = args{1};
elseif nargs==2 && isnumeric(args{1}) && isnumeric(args{2}) && isscalar(args{1}) && isscalar(args{2})
    npix_lo=args{1};
    npix_hi=args{2};
elseif nargs>0
    mess = 'Check the type of input argument(s)';
    return
end

% check opt argument
header_only=false;
hverbatim=false;
nopix=false;
if exist('opt','var')
    if strcmpi(opt,'-h')
        header_only=true;
    elseif strcmpi(opt,'-hverbatim')
        header_only=true;
        hverbatim=true;
    elseif strcmpi(opt,'-nopix')
        nopix=true;
    else
        mess = 'invalid option';
        return
    end
elseif exist('npix_lo','var')
    if npix_lo<1 || npix_hi<npix_lo
        mess = 'pixel range must have 1 <= npix_lo <= npix_hi';
        return
    end
end


% Read data
% --------------
if ~prototype
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [dummy_filename, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;
    
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [dummy_filepath, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;
    
    if hverbatim
        % Read filename and path from file
        data.filename=dummy_filename;
        data.filepath=dummy_filepath;
    else
        % Get file name and path (incl. final separator)
        [path,name,ext]=fileparts(fopen(fid));
        data.filename=[name,ext];
        data.filepath=[path,filesep];
    end
    
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [data.title, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;
    
    [data.alatt, count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
    [data.angdeg, count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
    
else
    % Get file name and path (incl. final separator)
    [path,name,ext]=fileparts(fopen(fid));
    data.filename=[name,ext];
    data.filepath=[path,filesep];
    
    data.title = '';
    data.alatt = zeros(1,3);
    data.angdeg = zeros(1,3);
end

[data.uoffset, count, ok, mess] = fread_catch(fid,[4,1],'float32'); if ~all(ok); return; end;
[data.u_to_rlu, count, ok, mess] = fread_catch(fid,[4,4],'float32'); if ~all(ok); return; end;
[data.ulen, count, ok, mess] = fread_catch(fid,[1,4],'float32'); if ~all(ok); return; end;

[n, count, ok, mess] = fread_catch(fid,2,'int32'); if ~all(ok); return; end;
[ulabel, count, ok, mess] = fread_catch(fid,[n(1),n(2)],'*char'); if ~all(ok); return; end;
data.ulabel=cellstr(ulabel)';

[npax, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
niax=4-npax;
if niax~=0
    [data.iax, count, ok, mess] = fread_catch(fid,[1,niax],'int32'); if ~all(ok); return; end;
    [data.iint, count, ok, mess] = fread_catch(fid,[2,niax],'float32'); if ~all(ok); return; end;
else
    data.iax=zeros(1,0);    % create empty index of integration array in standard form
    data.iint=zeros(2,0);
end

if npax~=0
    [data.pax, count, ok, mess] = fread_catch(fid,[1,npax],'int32'); if ~all(ok); return; end;
    psize=zeros(1,npax);    % will contain number of bins along each dimension of plot axes
    for i=1:npax
        [np,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
        [data.p{i},count,ok,mess] = fread_catch(fid,np,'float32'); if ~all(ok); return; end;
        psize(i)=np-1;
    end
    [data.dax, count, ok, mess] = fread_catch(fid,[1,npax],'int32'); if ~all(ok); return; end;
    if length(psize)==1
        psize=[psize,1];    % make size of a column vector
    end
else
    data.pax=zeros(1,0);    % create empty index of plot axes
    data.p=cell(1,0);
    data.dax=zeros(1,0);    % create empty index of plot axes
    psize=[1,1];    % to hold a scalar
end


% Read the bin data if required
position.s=ftell(fid);
if ~header_only 
    [data.s,count,ok,mess] = fread_catch(fid,prod(psize),'float32'); if ~all(ok); return; end;
    data.s = reshape(data.s,psize);
else
    status=fseek(fid,4*(prod(psize)),'cof');  % skip field s
end

position.e=ftell(fid);
if ~header_only
    [data.e,count,ok,mess] = fread_catch(fid,prod(psize),'float32'); if ~all(ok); return; end;
    data.e = reshape(data.e,psize);
else
    status=fseek(fid,4*(prod(psize)),'cof');  % skip field e
end


% All of the above fields will be present in a valid sqw file. The following need not exist, but to be a valid sqw file,
% for any one field to be present all earlier fields must have been written. 
position.npix=[];
position.pix=[];
npixtot=[];

% Determine if any more data to read

if fnothingleft(fid)    % reached end of file - can only be because has type 'b'
    type='b';
    if prototype && ~header_only
        mess = 'File does not contain number of pixels for each bin - uable to convert old format data';
        return
    end
    return
else
    position.npix=ftell(fid);
    if ~header_only
        [data.npix,count,ok,mess] = fread_catch(fid,prod(psize),'int64'); if ~all(ok); return; end;
        data.npix = reshape(data.npix,psize);
    else
        status=fseek(fid,8*(prod(psize)),'cof');  % skip field npix
    end
end

if fnothingleft(fid)    % reached end of file - can only be because has type 'b+'
    type='b+';
    if prototype && ~header_only
        [data.s,data.e]=convert_signal_error(data.s,data.e,data.npix);
    end
    return
else
    [data.urange,count,ok,mess] = fread_catch(fid,[2,4],'float32'); if ~all(ok); return; end;
end

if fnothingleft(fid)    % reached end of file - can only be because has type 'a-'
    type='a-';
    if prototype && ~header_only
        [data.s,data.e]=convert_signal_error(data.s,data.e,data.npix);
    end
    return
else
    [dummy,count,ok,mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;   % redundant field
    [npixtot,count,ok,mess] = fread_catch(fid,1,'int64'); if ~all(ok); return; end;
    position.pix=ftell(fid);
    if ~header_only && ~nopix
        if ~exist('npix_lo','var')
            if npixtot~=0
                [data.pix,count,ok,mess] = fread_catch(fid,[9,npixtot],'float32'); if ~all(ok); return; end;
            else
                data.pix=zeros(9,0);
            end
        else
            if npix_hi<=npixtot
                status=fseek(fid,4*(9*(npix_lo-1)),'cof');
                [data.pix,count,ok,mess] = fread_catch(fid,[9,npix_hi-npix_lo+1],'float32'); if ~all(ok); return; end;
            else
                mess=['Selected pixel range must lie inside 1 - ',num2str(npixtot)];
                return
            end
        end
    else
        status=fseek(fid,4*(9*npixtot),'cof');  % skip field pix
    end
    type='a';
    if prototype && ~header_only
        [data.s,data.e]=convert_signal_error(data.s,data.e,data.npix);
    end
    return
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
% Prototype format files have zeros for singal and variance arrays with no pixels
pixels = npix~=0;
s(pixels) = s(pixels)./npix(pixels);
e(pixels) = e(pixels)./(npix(pixels).^2);

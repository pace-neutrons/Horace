function [data, mess, position, npixtot, type] = get_sqw_data (fid, varargin)
% Read the data block from an sqw file. The file pointer is left at the end of the data block.
%
%   >> [data, mess] = get_sqw_data(fid)
%   >> [data, mess] = get_sqw_data(fid, opt)
%   >> [data, mess] = get_sqw_data(fid, npix_lo, npix_hi)
%
% To the above, you *must* append the file format and expected data type (can be '' to autodetect):
%   >> [data, mess] = get_sqw_data(..., format_flag, data_type)
%
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
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
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file (only applies to type 'a')
%   npix_hi     -|
%
% format_flag   Format of file (character string)
%                   Current formats:  '-v2', '-v3'
%                   Obsolete formats: '-prototype'
%
%   data_type   Content type of that file: must be one of the permitted data structures (character string):
%               This is required for format_flag '-v3'
%               	'b'    fields: filename,...,dax,s,e
%                   'b+'   fields: filename,...,dax,s,e,npix
%                   'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                   'a-'   fields: filename,...,dax,s,e,npix,urange
%
%               For formats '-v2' and '-prototype', the contents of data type is auto-detected and
%              the value of data_type is ignored. For clarity, you can set to the empty string
%                   ''     auto-detect the fields in the file.
%   
%
% Output:
% -------
%   data        Output data structure actually read. Must be one of:
%                       type 'b'    fields: filename,...,dax,s,e
%                       type 'b+'   fields: filename,...,dax,s,e,npix
%                       type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                       type 'a-'   fields: filename,...,dax,s,e,npix,urange
%               or header information   
%
%   mess        Error message; blank if no errors, non-blank otherwise
%
%   position    Position (in bytes from start of file) of large fields:
%              These field are correctly filled even if the header only has been requested, that is,
%              if input option '-h' or '-hverbatim' was given
%                   position.s      position of array s
%                   position.e      position of array e
%                   position.npix   position of array npix (=[] if npix not present)
%                   position.urange position of array urange (=[] if urange not written)
%                   position.pix    position of array pix (=[] if pix not present)
%
%   npixtot     Total number of pixels written to file (=[] if pix not present)
%
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
% NOTES:
% ======
% Supported file Formats
% ----------------------
% The current sqw file format comes in two variants:
%   - version 1 and version 2
%      (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
%       This format is the one still written if these fields are empty in the sqw object (or result of a
%       cut on an sqw file assembled only to a file - see below).
%   - version 3
%       (February 2013 onwards.) Writes optional instrument and sample fields in the header block, and
%      positions of the start of major data blocks in the sqw file. Finally, finishes with the positon
%      of the position data block and the end of the data block as the last two 8 byte entries.
%
% Additionally, this routine will read the prototype sqw file format:
%       (July 2007(?) - Autumn 2008). Almost the same format, except that data saved as type 'b' is
%       uninterpretable by Horace because the npix information that is needed to normalise the
%       signal and error in each bin is not stored.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Initialise output arguments
data=[];
position = struct('s',[],'e',[],'npix',[],'urange',[],'pix',[]);
npixtot=[];
type='';

% Check format flag and data type
valid_formats={'-v3','-v2','-prototype'};
valid_types={'b','b+','a-','a',''};

if nargin>=2 && ischar(varargin{end-1}) && ischar(varargin{end})
    format_flag=lower(strtrim(varargin{end-1}));
    data_type=lower(strtrim(varargin{end}));
    iform=find(strcmpi(format_flag,valid_formats),1);
    itype=find(strcmpi(data_type,valid_types),1);
    if ~isempty(iform) && ~isempty(itype)
        if strcmp(format_flag,'-v3') && ~isempty(data_type)
            autodetect=false;
            prototype=false;
        elseif strcmp(format_flag,'-v2')
            autodetect=true;
            prototype=false;
        elseif strcmp(format_flag,'-prototype')
            autodetect=true;
            prototype=true;
        else
            mess='Check the validity of the combination of data format flag and data type';
            return
        end
        nargs=numel(varargin)-2;
        args=varargin(1:end-2);
    else
        mess='Check the validity of the data format flag and data type';
        return
    end
else
    mess='Check the number and type of input arguments';
    return
end

% Parse optional input arguments
header_only=false;
hverbatim=false;
nopix=false;

if nargs==1 && ischar(args{1})
    opt = args{1};
    if strcmpi(opt,'-h')
        header_only=true;
    elseif strcmpi(opt,'-hverbatim')
        header_only=true;
        hverbatim=true;
    elseif strcmpi(opt,'-nopix')
        nopix=true;
    else
        mess = 'Invalid option';
        return
    end
elseif nargs==2 && isnumeric(args{1}) && isnumeric(args{2}) && isscalar(args{1}) && isscalar(args{2})
    npix_lo=args{1};
    npix_hi=args{2};
    if npix_lo<1 || npix_hi<npix_lo
        mess = 'Pixel range must have 1 <= npix_lo <= npix_hi';
        return
    end
elseif nargs>0
    mess = 'Check the type of input argument(s)';
    return
end


% --------------------------------------------------------------------------
% Read data
% --------------------------------------------------------------------------
% This first set of fields are required for all output options
% ------------------------------------------------------------
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
    % Get file name and path (incl. final separator) and put empty information in fields not in the file
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


% Read the signal and error data if required
% ------------------------------------------
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


% Read npix, urange, pix according to options and file contents
% -------------------------------------------------------------
% All of the above fields will be present in a valid sqw file. The following need not exist, but to be a valid sqw file,
% for any one field to be present all earlier fields must have been written. 


% Determine if type 'b' or there are more fields in the data block
if strcmp(data_type,'b') || (autodetect && fnothingleft(fid))    % reached end of file - can only be because has type 'b' (autodetect) or 
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


% Determine if type 'b+' or there are more fields in the data block
if strcmp(data_type,'b+') || (autodetect && fnothingleft(fid))    % reached end of file - can only be because has type 'b+'
    type='b+';
    if prototype && ~header_only
        [data.s,data.e]=convert_signal_error(data.s,data.e,data.npix);
    end
    return
else
    position.urange=ftell(fid);
    [data.urange,count,ok,mess] = fread_catch(fid,[2,4],'float32'); if ~all(ok); return; end;
end


% Determine if type 'a-' or there are more fields in the data block
if strcmp(data_type,'a-') || (autodetect && fnothingleft(fid))    % reached end of file - can only be because has type 'a-'
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
                mess=['Selected pixel range must lie inside or on the boundaries of 1 - ',num2str(npixtot)];
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

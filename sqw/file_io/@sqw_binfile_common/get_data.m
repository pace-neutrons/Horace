function [data,obj] = get_data (obj,varargin)
% Read the data block from an sqw or dnd file and return the result as the
% data structure with fields, described below.
%
% The result is packed into data_dnd_sqw class unless -noclass option is
% provided
%
% The file pointer is left at the end of the data block.
%
%   >> data = obj.get_data()
%   >> data = obj.get_data(opt)
%   >> data = obj.get_data(npix_lo, npix_hi)
%
% Input:
% ------
%   opt         [optional] Determines which fields to read
%               '-header'     header-type information only: fields read:
%                             filename, filepath, title, alatt, angdeg,...
%                             uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                            (If file was written from a structure of type 'b' or 'b+', then
%                            urange does not exist, and the output field will not be created)
%              '-hverbatim'  Same as '-h' except that the file name as stored in the main_header and
%                            data sections are returned as stored, not constructed from the
%                            value of fopen(fid). This is needed in some applications where
%                            data is written back to the file with a few altered fields.
%              '-nopix'      Pixel information not read (only meaningful for sqw data type 'a')
%              '-noclass'    do not pack data into sqw_dnd_data class --
%                            may be useful for current object model, when dnd is
%                            going to be created. May be removed in a future.
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file (only applies to type 'a')
%   npix_hi     -|
%

%
% Output:
% -------

%   data        Output data structure actually read from the file. Will be one of:
%                   type 'h'    fields: fields: uoffset,...,dax[,urange]
%                   type 'b'    fields: filename,...,dax,s,e
%                   type 'b+'   fields: filename,...,dax,s,e,npix
%                   type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                   type 'a-'   fields: filename,...,dax,s,e,npix,urange
%               The final field urange is present for type 'h' if the header information was read from an sqw-type file.
%
%
%
% Fields read from the file are:
% ------------------------------
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
%   - Horace version 1 and version 2: file format '-v2'
%     (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
%     This format is the one still written if these fields all have the 'empty' value in the sqw object.
%
%
% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)

% Initialise output arguments

% remove options unrelated to get_data@dnd_binfile_common
[ok,mess,~,noclass,argi]=...
    parse_char_options(varargin,{'-nopix','-noclass'});
if ~ok
    error('SQW_FILE_INTERFACE:invalid_argument',['get_data: ',mess]);
end

[data_str,obj] = obj.get_data@dnd_binfile_common(obj,argi{:});
%
fseek(obj.file_id_,obj.urange_pos_,'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_BINILE_COMMON:io_error',...
        'Can not move to the urange start position, Reason: %s',mess);
end

data_str.urange =fread(obj.file_id_,[2,4],'float32');


% process all possible options
[ok,mess,header_only,~,hverbatim,nopix,argi]=...
    parse_char_options(varargin,{'-header','-verbatim','-hverbatim','-nopix'});
if ~ok
    error('SQW_FILE_INTERFACE:invalid_argument',['get_data: ',mess]);
end

header_only = header_only||hverbatim;

if header_only || noclass
    data  = data_str;
    return;
end
data = data_sqw_dnd(data_str);

if numel(argi)>0
    if ~isnumeric(argi{1})
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'get_data: invalid argument %s',argi{1})
    end
    npix_lo = argi{1};
    if numel(argi)>1
        if ~isnumeric(argi{2})
            error('SQW_BINFILE_COMMON:invalid_argument',...
                'get_data: invalid argument %s',argi{1})
        end
        npix_hi = argi{2};
    end
end



if ~nopix
    if ~exist('npix_lo','var')
        npix_lo = 1;
    end
    if ~exist('npix_hi','var')
        npix_hi = obj.npixels;
    end
    data.pix = obj.get_pix(npix_lo,npix_hi);
end

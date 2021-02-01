function [data,obj] = get_data(obj,varargin)
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
% Keyword Arguments:
% ------------------
%   pixel_page_size    The maximum amount of memory to allocate to holding
%                      pixel data. This argument is passed to the PixelData
%                      constructor's 'mem_alloc' argument.
%                      The value should have units of bytes.
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
%   data.pix_range     True range of the data along each axis [pix_range(2,4)]
%   data.pix        A PixelData objects
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

% Initialise output arguments

% remove options unrelated to get_data@dnd_binfile_common
[ok,mess,~,noclass,argi]=...
    parse_char_options(varargin,{'-nopix','-noclass'});
if ~ok
    error('SQW_FILE_INTERFACE:invalid_argument',['get_data: ',mess]);
end

[data_str,obj] = obj.get_data@dnd_binfile_common(obj,argi{:});

%
data_str.img_range = obj.get_img_range();
%
%
% parse all arguments, including those that weren't passed to the parent method
opts = parse_args(varargin{:});

if opts.header || opts.hverbatim || noclass
    data  = data_str;
    return;
end
data = data_sqw_dnd(data_str);

if ~opts.nopix
    data.pix = PixelData(obj, opts.pixel_page_size);
    %
end

end  % function


% -----------------------------------------------------------------------------
function opts = parse_args(varargin)
flags = {'header','verbatim','hverbatim','nopix', 'noclass'};
kwargs = struct('pixel_page_size', PixelData.DEFAULT_PAGE_SIZE);
for flag_idx = 1:numel(flags)
    kwargs.(flags{flag_idx}) = false;
end
parser_opts = struct('prefix', '-', 'prefix_req', false);
[~, opts, ~, ~, ok, mess] = parse_arguments(varargin, kwargs, flags, ...
    parser_opts);
if ~ok
    error('SQW_FILE_INTERFACE:invalid_argument', ['get_data: ', mess]);
end
end

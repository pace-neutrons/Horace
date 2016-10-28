function data_form = process_format_fields_(varargin)
% Return the structure of the data file header in the form
% it is written on hdd.
%
% Usage:
%>>df = obj.get_data_form();
%>>df = obj.get_data_form('-head');
%>>df = obj.get_data_form('-const');
%>>df = obj.get_data_form('-no_npix');
%>>df = obj.get_data_form('-data');

% where the options '-head' and 'const' return
% partial structures, namely methadata only and the methadata
% fields, which do not change on hdd
%
% Fields in the full structure are:
%
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
persistent var_fields;
persistent const_fields;
persistent data_fields;


[ok,mess,head_only,constant_len_fields,no_npix,data_only,~] =...
    parse_char_options(varargin,{'-header','-const','-no_npix','-data'});
if ~ok
    error('DND_BINFILE_COMMON:invalid_argument',...
        'get_head_form: invalid argument: %s',mess)
end
if (head_only || constant_len_fields) && data_only
    error('DND_BINFILE_COMMON:invalid_argument',...
        'get_head_form: -data and -head or -const fields can not be provided together')
end
% by default, return all record
if isempty(var_fields)
    var_fields = {'filename','','filepath','',...
        'title',''};
end
if isempty(const_fields)
    const_fields={...
        'alatt',single([1,3]),'angdeg',single([1,3]),...
        'uoffset',single([4,1]),'u_to_rlu',single([4,4]),...
        'ulen',single([1,4]),'ulabel',field_cellarray_of_strings(),...
        'npax',field_not_in_structure('pax'),...
        'iax',field_iax(),...
        'iint',field_iint(),...
        'pax',field_const_array_dependent('npax',1,'int32'),...
        'p_size',field_p_size(),...
        'p',field_cellarray_of_axis('npax'),...
        'dax',field_const_array_dependent('npax',1,'int32')};
end
if isempty(data_fields)
    data_fields = {'s',field_img(),'e',field_img(),...
        'npix',field_img('uint64')};
end

if head_only
    if constant_len_fields
        ca  = const_fields;
    else
        ca = [var_fields(:);const_fields(:)];
    end
elseif data_only
    ca = data_fields;
else
    if constant_len_fields
        ca = [const_fields(:);data_fields(:)];
    else
        ca = [var_fields(:);const_fields(:);data_fields(:)];
    end
end
data_form = struct(ca{:});
%
if no_npix
    if isfield(data_form,'npix')
        data_form = rmfield(data_form,{'npix'});
    end
end



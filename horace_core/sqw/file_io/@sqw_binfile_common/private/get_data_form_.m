function data_form = get_data_form_(obj,varargin)
% Return the structure of the data file header in the form
% it is written on hdd.
%
% The structure depends on data type stored in the file
% (see dnd_file_interface data_type method)
%
% Usage:
%>>df = obj.get_data_form()'-head');
% or
%>>df = obj.get_data_form(),options);
% where options can be any or all of
% '-head','-const','-data','-pix_only','-nopix','-header'
% where
% -head is equivalend to -head on dnd object will return dnd object
%  methadata
% -const will return only part of data,
%
%  Which returns some parts of the full data structure below.
%
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

[ok,mess,pix_only,nopix,head,argi] = parse_char_options(varargin,{'-pix_only','-nopix','-header'});
if ~ok
    error('SQW_BINFILE_COMMON:invalid_argument',mess);
end

if pix_only
    data_form = struct('urange',single([2,4]),...
        'dummy',field_not_in_structure('urange'),...
        'pix',field_pix());
else
    if head
        argi{end+1} = '-head';        
    end
    data_form = obj.get_dnd_form(argi{:});
    if nopix || head
        return
    end
    data_form.urange = single([2,4]);
    data_form.dummy = field_not_in_structure('pax');
    data_form.pix = field_pix();
end

% full header necessary to identify datatype in the file
if strncmp(obj.data_type,'un',2)
    return;
end
%
if strncmp(obj.data_type,'a-',2) || nopix % data do not contain pixels
    data_form = rmfield(data_form,{'dummy','pix'});
    return;
end


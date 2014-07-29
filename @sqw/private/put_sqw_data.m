function [mess,position,npixtot,data_type] = put_sqw_data (fid, fmt_ver, data, varargin)
% Write data block to binary file
%
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, fmt_ver, data)
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, fmt_ver, data, '-h')
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, fmt_ver, data, '-pix', v1, v2,...)
%
% Input:
% -------
%   fid         File identifier of output file (opened for binary writing)
%
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
%   data        Data structure abstracted from a valid sqw data type, which must contain the fields:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,urange]
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%                   type 'sp-'  fields: filename,...,dax,s,e,npix,urange (sparse format)
%                   type 'sp'   fields: filename,...,dax,s,e,npix,urange,npix_nz,pix_nz,pix_nz (sparse format)
%
%               - Type 'b+ has the same fields as a dnd-type sqw object
%
%               - Type 'a' and 'sp' correspond to an sqw-type sqw object
%
%               - Type 'a-' and 'sp-' correspond to what is read using get_sqw with '-nopix'. This data
%                type needs to be accompanied with the '-pix' option followed by additional
%                arguments that give the source of the pixel information (see below).
%
%               - Type 'h' is obtained from a valid sqw file by reading with get_sqw with the '-h' or '-his'
%                options (or their '-hverbatim' and '-hisverbatim' variants). The final field urange is
%                present if the header information was read from an sqw-type file, but is not written here.
%                 Input data of type 'h' is only valid when overwriting data fields in a pre-existing sqw file.
%                It is assumed that all entries of the fields filename,...,uoffset,...dax will have the same lengths in
%                bytes as the existing entries in the file.
%
%   opt         Determines which parts of the input data structure to write to a file. By default, the
%              entire contents of the input data structure are written, apart from the case of 'h' when
%              urange will not be written even if present. The default behaviour can be altered with one of
%              the following options:
%                  '-h'      Write only the header fields of the input data: filename,...,uoffset,...,dax
%                           (Note that urange is not written, even if present in the input data)
%                  '-pix'    Write pixel information, either from the data structure, or from the
%                            information in the additional optional arguments infiles...run_label (see below).
%               An option that is consistent with the input data are accepted, even if redundant
%
%   v1, v2,...  [Valid only with the '-pix' option] Arguments defining how pixels are to be collected
%               from various sources other than input argument 'data' and written to this file.
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%
%   position    Position (in bytes from start of file) of data block and large fields actually written by the call to this function:
%                   position.data   position of start of data block
%                   position.s      position of array s (=[] if s not written i.e. input data is 'h')
%                   position.e      position of array e (=[] if e not written i.e. input data is 'h')
%                   position.npix   position of array npix (=[] if npix not written)
%                   position.urange position of array urange (=[] if urange not written)
%                   position.npix_nz position of array npix_nz (=[] if npix_nz not written)
%                   position.pix_nz  position of array pix_nz (=[] if pix_nz not written)
%                   position.pix    position of array pix (=[] if pix not written)
%
%   npixtot     Total number of pixels actually written by the call to this function (=[] if pix not written)
%
%   data_type   Type of data actually written to the file by the call to this function: 'a', 'b+', 'h' or 'sp'
%
%
% Fields written to the file are:
% -------------------------------
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
%   data.pix        Index of pixels, sorted so that all the pixels in the first
%                  bin appear first, then all the pixels in the second bin etc. (column vector)
%                           ipix = ie + ne*(id-1)
%                       where
%                           ie  energy bin index
%                           id  detector index into list of all detectors (i.e. masked and unmasked)
%                           ne  number of energy bins
%
%
%
% Notes:
% ------
%   There are some other items written to the file to help when reading the file using get_sqw_data.
% These are indicated by comments in the code.
%
%   The data for the individual pixels is expressed in the projection axes of the original
% contributing sqw files, as is recorded in the corresponding header block (see put_sqw_header).
% The arguments u_to_rlu, ulen, ulabel written in this function refer to the projection axes used
% for the plot and integration axes, and give the units in which the bin boundaries p are expressed.
%
%   The reason why we keep the coordinate frames separate is that in succesive cuts from sqw data
% structures we are constantly recomputing the coordinates of pixels in the plot/integration projection
% axes. We therefore do not want to allow rouding errors to accumulate, and so retain the original
% data points in their original coordinate frame. It also makes operations such as reorienting the crystal
% very fast, as it only requires header information to be overwritten.
%
%   It is assumed that the data corresponds to a valid type, or has been abstracted from a valid type


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Initialise output arguments
position = struct('data',ftell(fid),'s',[],'e',[],'npix',[],'urange',[],'npix_nz',[],'pix_nz',[],'pix',[]);
npixtot=[];

% Determine type of input data structure
data_type_in = data_structure_type(data);

% Determine if valid write options and number of further optional arguments
[mess,write_header_only,data_type,optvals] = check_options(data_type_in,varargin{:});
if ~isempty(mess), return, end


% Write header information to file
% --------------------------------
[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);

write_sqw_var_char (fid, fmt_ver, data.filename);
write_sqw_var_char (fid, fmt_ver, data.filepath);
write_sqw_var_char (fid, fmt_ver, data.title);

fwrite(fid, data.alatt,    fmt_dble);
fwrite(fid, data.angdeg,   fmt_dble);
fwrite(fid, data.uoffset,  fmt_dble);
fwrite(fid, data.u_to_rlu, fmt_dble);
fwrite(fid, data.ulen,     fmt_dble);

write_sqw_var_char (fid, fmt_ver, char(data.ulabel))

npax = length(data.pax);    % write number plot axes - gives the dimensionality of the plot
niax = 4 - npax;
fwrite(fid, npax, fmt_int);

if niax>0
    fwrite(fid, data.iax,  fmt_int);
    fwrite(fid, data.iint, fmt_dble);
end

if npax>0
    fwrite(fid, data.pax, fmt_int);
    for i=1:npax
        np=length(data.p{i});   % write length of vector data.p{i}
        fwrite(fid, np, fmt_int);
        fwrite(fid, data.p{i}, fmt_dble);
    end
    fwrite(fid, data.dax, fmt_int);
end


% Write signal information to file, if requested
% ----------------------------------------------
if ~write_header_only
    if strcmpi(data_type_in,'sp-')||strcmpi(data_type_in,'sp')
        % Sparse data
        [mess,pos_update,npixtot] = put_sqw_data_signal_sparse (fid, fmt_ver, data, optvals{:});
        if ~isempty(mess), return, end
        position=update(position,pos_update);
    else
        % Non-sparse data
        [mess,pos_update,npixtot] = put_sqw_data_signal (fid, fmt_ver, data, optvals{:});
        if ~isempty(mess), return, end
        position=update(position,pos_update);
    end
    
end

%==================================================================================================
function [mess,write_header_only,data_type_out,optvals] = check_options(data_type,varargin)
% Check the data type and optional arguments to put_sqw_data for validity
%
%   >> [mess,write_header_only,optvals] = check_options(data_type,)
%   >> [mess,write_header_only,optvals] = check_options(data_type,opt,)
%   >> [mess,write_header_only,optvals] = check_options(data_type,opt,p1,p2,...)
%
% Input:
% ------
%   data_type   Data structure type; one of: 'h','b+','a-','a','sp-','sp'
%   opt         [optional] option character string: one of '-h','-pix'
%   p1,p2,...   Optional arguments as may be required by the option string:
%               Only '-pix' currently can take optional arguments.
%               No checks are performed on these arguments, only that the presence
%              or otherwise is consistent with the option string.
%
% Output:
% -------
%   mess                Error message if a problem; ='' if all OK
%   write_header_only   =true if only the data block header is to be written
%   data_type_out       Type of data that will be written to file
%   optvals             Optional arguments

mess='';
write_header_only=false;
data_type_out='';
optvals={};

% Check optionarl arguments are valid
opt.pix=false;
opt.h=false;
if numel(varargin)>0
    option=varargin{1};
    if ischar(option) && strcmpi(option,'-pix')
        opt.pix=true;
        optvals=varargin(2:end);
    elseif ischar(option) && strcmpi(option,'-h')
        if numel(varargin)>1
            mess='Number of arguments for option ''-h'' is invalid';
            return
        end
        opt.h=true;
        optvals={};
    else
        mess='Unrecognised option specified in put_sqw_data';
        return
    end
end
noopt=~(opt.pix||opt.h);

% Determine if valid write option for input data structure
if strcmpi(data_type,'h')
    if opt.h || noopt
        write_header_only=true;
        data_type_out='h';
    else
        mess = 'Invalid write option specified in put_sqw_data for ''h'' type data';
        return
    end
    
elseif strcmpi(data_type,'b+')
    if opt.h
        write_header_only=true;
        data_type_out='h';
    elseif noopt
        write_header_only=false;
        data_type_out='b+';
    else
        mess = 'Invalid write option specified in put_sqw_data for ''b+'' type data';
        return
    end
    
elseif strcmpi(data_type,'a-') || strcmpi(data_type,'sp-')
    if opt.h
        write_header_only=true;
        data_type_out='h';
    elseif opt.pix
        write_header_only=false;
        data_type_out=data_type(1:end-1);   % remove the trailing '-'
        if isempty(optvals)
            mess=['Must supply an additional source of pixel information for ''',data_type,''' type data'];
            return
        end
    else
        if noopt
            mess=['Must supply an additional source of pixel information for ''',data_type,''' type data'];
            return
        else
            mess = 'Invalid write option specified in put_sqw_data for ''a'' type data';
            return
        end
    end
    
elseif strcmpi(data_type,'a') || strcmpi(data_type,'sp')
    if opt.h
        write_header_only=true;
        data_type_out='h';
    elseif opt.pix || noopt
        write_header_only=false;
        data_type_out=data_type;
    else
        mess = ['Invalid write option specified in put_sqw_data for ',data_type,' type data'];
        return
    end
    
else
    error('Unrecognised data type in put_sqw_data')
end

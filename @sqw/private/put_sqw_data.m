function [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data (fid, fmt_ver, data, varargin)
% Write data block to binary file
%
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data (fid, fmt_ver, data)
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data (fid, fmt_ver, data, '-h')
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data (fid, fmt_ver, data, '-pix', v1, v2,...)
%   >> [mess,position,fieldfmt,npixtot,npixtot_nz] = put_sqw_data (fid, fmt_ver, data, '-buffer')
%
% Input:
% -------
%   fid         File identifier of output file (opened for binary writing)
%
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
%   data        Data structure abstracted from a valid sqw data type, which must contain the fields:
%                       ='h'         header part of data structure only
%                                   i.e. fields filename,...,uoffset,...,dax
%
%                       ='dnd'       dnd object or dnd structure
%                       ='dnd_sp'    dnd structure, sparse format
%
%                       ='sqw'       sqw object or sqw structure
%                       ='sqw_'      sqw structure withut pix array
%
%                       ='sqw_sp'    sqw structure, sparse format
%                       ='sqw_sp_'   sqw structure, sparse format without
%                                   npix_nz,pix_nz,pix arrays
%
%                       ='buffer'    npix, pix
%                       ='buffer_sp' npix,npix_nz,pix_nz,pix
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
%                  '-buffer' Write npix and pix arrays only
%
%   v1, v2,...  [Valid only with the '-pix' option] Arguments defining how pixels are to be collected
%               from various sources other than input argument 'data' and written to this file.
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%
%   position    Position (in bytes from start of file) of data block and large fields actually written by the call to this function:
%                   position.data           start of data block
%                   position.s              position of array s
%                   position.e              position of array e
%                   position.npix           position of array npix (=NaN if npix not written)
%                   position.urange         position of array urange (=NaN if urange not written)
%                   position.npix_nz        position of array npix_nz (=NaN if npix_nz not written)
%                   position.pix_nz         position of array pix_nz (=NaN if pix_nz not written)
%                   position.pix            position of array pix  (=NaN if pix not written)
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
%
%
%
% Notes:
% ------
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
position = struct('data',ftell(fid),'s',NaN,'e',NaN,'npix',NaN,'urange',NaN,'npix_nz',NaN,'pix_nz',NaN,'pix',NaN);
fieldfmt = struct('s','','e','','npix','','urange','','npix_nz','','pix_nz','','pix','');
npixtot=NaN;
npixtot_nz=NaN;

% Determine type of input data structure
[data_type_name_in,sparse_fmt] = data_structure_type_name(data);

% Determine if valid write options and number of further optional arguments
[mess,data_type_name_write,opt] = check_options(data_type_name_in,varargin{:});
if ~isempty(mess), return, end


% Write header information to file
% --------------------------------
[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);
len_name_max=1024;  % fixed length of name string
len_title_max=8192; % fixed length of title string

write_sqw_var_char (fid, fmt_ver, data.filename, len_name_max);
write_sqw_var_char (fid, fmt_ver, data.filepath, len_name_max);
write_sqw_var_char (fid, fmt_ver, data.title,    len_title_max);

fwrite(fid, data.alatt,    fmt_dble);
fwrite(fid, data.angdeg,   fmt_dble);
fwrite(fid, data.uoffset,  fmt_dble);
fwrite(fid, data.u_to_rlu, fmt_dble);
fwrite(fid, data.ulen,     fmt_dble);

write_sqw_var_char (fid, fmt_ver, data.ulabel, len_name_max);

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
if ~opt.h
    if sparse_fmt
        % Sparse data
        [mess,pos_update,fmt_update,npixtot,npixtot_nz] = put_sqw_data_signal_sparse (fid, fmt_ver, data, varargin{:});
        if ~isempty(mess), return, end
    else
        % Non-sparse data
        [mess,pos_update,fmt_update,npixtot,npixtot_nz] = put_sqw_data_signal (fid, fmt_ver, data, varargin{:});
        if ~isempty(mess), return, end
    end
    position=update(position,pos_update);
    fieldfmt=update(fieldfmt,fmt_update);
    
end


%==================================================================================================
function [mess,data_type_write,opt,opt_name,optvals] = check_options(data_type_in,varargin)
% Check the data type and optional arguments for validity
%
%   >> [mess,data_type_write,opt,opt_name,optvals] = check_options(data_type_in)
%   >> [mess,data_type_write,opt,opt_name,optvals] = check_options(data_type_in,opt)
%   >> [mess,data_type_write,opt,opt_name,optvals] = check_options(data_type_in,opt,p1,p2,...)
%
% Input:
% ------
%   data_type_in    Data structure type. Assumesd to be one of:
%                       'dnd', 'dnd_sp', 'sqw_', 'sqw_sp_', 'sqw', 'sqw_sp'
%                       'buffer', 'buffer_sp'
%                       'h'
%
%   opt             [optional] option character string: one of '-h', '-buffer', '-pix'
%
%   p1,p2,...       Optional arguments as may be required by the option string:
%                   Only '-pix' currently can take optional arguments.
%                   No checks are performed on these arguments, only that the presence
%                  or otherwise is consistent with the option string.
%
% Output:
% -------
%   mess            Error message if a problem; ='' if all OK
%
%   data_type_write Type of data that will be written to file. Will be one of:
%                       'dnd', 'dnd_sp', 'sqw', 'sqw_sp'
%                       'buffer', 'buffer_sp'
%                       'h'
%                   Note that the input cases 'sqw_' and 'sqw_sp_' are not possible
%                  because they will have required the '-pix' option to be provided.
%
%   opt             Structure with fields 'h', 'pix', 'buffer' with values true
%                  or false for the different values
%
%   opt_name        Option as character string: '-h', '-buffer', '-pix'
%                   If no option, opt_name=''
%
%   optvals         Optional arguments (={} if none)

mess='';
data_type_write='';
opt=struct('h',false,'buffer',false,'pix',false);
opt_name='';
optvals={};

narg=numel(varargin);


% Check optional arguments have valid syntax of form (...,opt, v1, v2,...)
% ------------------------------------------------------------------------
if narg>0
    opt_name=varargin{1};
    if isstring(opt_name) && ~isempty(opt_name)
        if strcmpi(opt_name,'-h')
            if narg>1
                mess='Number of arguments for option ''-h'' is invalid';
                return
            end
            opt.h=true;
            optvals={};
            
        elseif strcmpi(opt_name,'-buffer')
            if narg>1
                mess='Number of arguments for option ''-buffer'' is invalid';
                return
            end
            opt.buffer=true;
            optvals={};
            
        elseif strcmpi(opt_name,'-pix')
            opt.pix=true;
            optvals=varargin(2:narg);
            
        else
            mess='Unrecognised option';
            return
        end
    else
        mess='Unrecognised option';
        return
    end
end
noopt=~(opt.h||opt.buffer||opt.pix);

% Determine if valid write option for input data structure type
% -------------------------------------------------------------
if strcmpi(data_type_in,'h')
    if opt.h || noopt
        data_type_write='h';
    else
        mess = 'Invalid write option specified for ''h'' type data';
        return
    end
    
elseif strcmpi(data_type_in,'dnd') || strcmpi(data_type_in,'dnd_sp')
    if opt.h
        data_type_write='h';
    elseif noopt
        data_type_write=data_type_in;
    else
        mess = ['Invalid write option specified for ''',data_type_in,''' type data'];
        return
    end
    
elseif strcmpi(data_type_in,'sqw_') || strcmpi(data_type_in,'sqw_sp_')
    if opt.h
        data_type_write='h';
    elseif opt.pix
        data_type_write=data_type_in(1:end-1);   % remove the trailing '-'
        if isempty(optvals)
            mess=['Must supply an additional source of pixel information for ''',data_type_in,''' type data'];
            return
        end
    elseif noopt
        mess=['Must supply an additional source of pixel information for ''',data_type_in,''' type data'];
        return
    else
        mess = ['Invalid write option specified for ',data_type_in,' type data'];
        return
    end
    
elseif strcmpi(data_type_in,'sqw') || strcmpi(data_type_in,'sqw_sp')
    if opt.h
        data_type_write='h';
    elseif opt.buffer
        data_type_write='buffer';
    elseif opt.pix || noopt
        data_type_write=data_type_in;
    else
        mess = ['Invalid write option specified for ',data_type_in,' type data'];
        return
    end
    
elseif strcmpi(data_type_in,'buffer') || strcmpi(data_type_in,'buffer_sp')
    if opt.buffer || noopt
        data_type_write=data_type_in;
    else
        mess = ['Invalid write option specified for ',data_type_in,' type data'];
        return
    end
    
else
    error('Unrecognised data type')
end

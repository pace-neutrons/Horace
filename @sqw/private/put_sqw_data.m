function [mess,position,npixtot,data_type] = put_sqw_data (fid, data, opt, infiles, npixstart, pixstart, run_label)
% Write data block to binary file
%
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, data)
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, data, '-h')
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, data, '-nopix')
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, data, '-pix')
%   >> [mess, position, npixtot, data_type] = put_sqw_data (fid, data, '-pix', infiles, npixstart, pixstart, run_label)
%
% Input:
% -------
%   fid         File identifier of output file (opened for binary writing)
%
%   data        Data structure abstracted from a valid sqw data type, which must contain the fields:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,urange]
%                   type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%               If type 'a-', then the individual pixel information will normally be given with the '-pix'
%              option followed by the arguments infiles,...run_label (see below).
%               Type 'h' is obtained from a valid sqw file by reading with get_sqw with the '-h' or '-his'
%              options (or their '-hverbatim' and '-hisverbatim' variants). The final field urange is
%              present if the header information was read from an sqw-type file.
%               Input data of type 'h' is only valid when overwriting data fields in a pre-existing sqw file.
%              It is assumed that all entries of the fields filename,...,uoffset,...dax will have the same lengths in
%              bytes as the existing entries in the file.
%
%   opt         Determines which parts of the input data structure to write to a file. By default, the
%              entire contents of the input data structure are written, apart from the case of 'h' when
%              urange will not be written if present. The default behaviour can be altered with one of
%              the following options:
%                  '-h'      Write only the header fields of the input data: filename,...,uoffset,...,dax
%                           (Note that urange is not written, even if present in the input data)
%                  '-nopix'  Do not write the information for individual pixels
%                  '-pix'    Write pixel information, either from the data structure, or from the
%                            information in the additional optional arguments infiles...run_label (see below).
%               An option that is consistent with the input data are accepted, even if redundant
%               e.g.'-nopix' with data type 'h'.
%
% [The following are valid only with the '-pix' option. Either all or none of them must be present]
%   infiles     Cell array of file names, or array of file identifiers of open file, from
%              which to accumulate the pixel information
%
%   npixstart   Position (in bytes) from start of file of the start of the field npix
%
%   pixstart    Position (in bytes) from start of file of the start of the field pix
%
%   run_label   Indicates how to re-label the run index (pix(5,...)
%                       'fileno'        relabel run index as the index of the file in the list infiles
%                       'nochange'      use the run index as in the input file
%                        numeric array  offset run numbers for ith file by ith element of the array
%               This option exists to deal with three limiting cases:
%                (1) The run index is already written to the files correctly indexed into the header
%                   e.g. as when temporary files have been written during cut_sqw
%                (2) There is one file per run, and the run index in the header block is the file
%                   index e.g. as in the creating of the master sqw file
%                (3) The files correspond to several runs in general, which need to
%                   be offset to give the run indices into the collective list of run parameters
%
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%
%   position    Position (in bytes from start of file) of data block and large fields actually written by the call to this function:
%                   position.data   position of start of data block
%                   position.s      position of array s (=[] if s not written i.e. input data is 'h')
%                   position.e      position of array e (=[] if e not written i.e. input data is 'h')
%                   position.npix   position of array npix (=[] if npix not written i.e. input data is 'b' or 'h')
%                   position.urange position of array urange (=[] if urange not written i.e. input data is 'b+','b' or 'h')
%                   position.pix    position of array pix (=[] if pix not written i.e. input data is 'a-','b+','b' or 'h')
%
%   npixtot     Total number of pixels actually written by the call to this function (=[] if pix not written)
%
%   data_type   Type of data actually written to the file by the call to this function: 'a', 'a-', 'b+', 'b' or 'h'
%              Note that this is not necessarily the same as the data type that the file
%              will eventually contain. For example, if 'a-' then we will usually (if not
%              always!) have eventually written the pixel information from files using
%              the infiles...run_label options; if 'h' then header information will have been
%              overwritten data in a file containing one of 'a','a-','b+','b'.
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
%
%   The reason why we keep the coordinate frames separate is that in succesive cuts from sqw data
% structures we are constantly recomputing the coordinates of pixels in the plot/integration projection
% axes. We therefore do not want to allow rouding errors to accumulate, and so retain the original
% data points in their original coordinate frame.
%
%   It is assumed that the data corresponds to a valid type, or has been abstracted from a valid type


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = struct('data',ftell(fid),'s',[],'e',[],'npix',[],'urange',[],'pix',[]);
npixtot=[];

% Determine type of input data structure
data_type_in = data_structure_type(data);

% Determine if valid write options and number of further optional arguments
opt_pix=false;
opt_nopix=false;
opt_h=false;
if exist('opt','var');   % true if write option argument is present
    opt_none=false;
    opt_narg=nargin-3;  % number of arguments following write option argument
    if ischar(opt) && strcmpi(opt,'-pix')
        opt_pix=true;
        if ~(opt_narg==0 || opt_narg==4)
            mess='Number of arguments for option ''-pix'' is invalid';
            return
        end
    elseif ischar(opt) && strcmpi(opt,'-nopix')
        opt_nopix=true;
        if opt_narg~=0
            mess='Number of arguments for option ''-nopix'' is invalid';
            return
        end
    elseif ischar(opt) && strcmpi(opt,'-h')
        opt_h=true;
        if opt_narg~=0
            mess='Number of arguments for option ''-h'' is invalid';
            return
        end
    else
        mess='Unrecognised write option specified in put_sqw_data';
        return
    end
else
    opt_none=true;
end

% Determine if valid write option for inpur data structure
if strcmpi(data_type_in,'h')
    if opt_h || opt_nopix || opt_none
        write_header_only=true;
    else
        mess = 'Invalid write option specified in put_sqw_data for ''h'' type data';
        return
    end
elseif strcmpi(data_type_in,'b')||strcmpi(data_type_in,'b+')
    if opt_h
        write_header_only=true;
    elseif opt_nopix || opt_none
        write_header_only=false;
    else
        mess = 'Invalid write option specified in put_sqw_data for ''b'' or ''b+'' type data';
        return
    end
elseif strcmpi(data_type_in,'a-')
    write_header_only=false;
    if opt_h
        write_header_only=true;
    elseif opt_nopix || opt_none
        pix_from_struct = false;
        pix_from_file = false;
    elseif opt_pix
        if opt_narg==4    % pixel file information
            pix_from_struct = false;
            pix_from_file = true;
        else
            mess = 'Invalid number of option arguments for ''-pix'' option with ''a-'' type data in put_sqw_data';
            return
        end
    else
        mess = 'Invalid write option specified in put_sqw_data for ''a'' type data';
        return
    end
elseif strcmpi(data_type_in,'a')
    write_header_only=false;
    if opt_h
        write_header_only=true;
    elseif opt_nopix
        pix_from_struct = false;
        pix_from_file = false;
    elseif opt_pix
        if opt_narg==0        % no pixel file info
            pix_from_struct = true;
            pix_from_file = false;
        elseif opt_narg==4    % pixel file information
            pix_from_struct = false;
            pix_from_file = true;
        else
            mess = 'Invalid number of option arguments for ''-pix'' option with ''a'' type data in put_sqw_data';
            return
        end
    elseif opt_none
        pix_from_struct = true;
        pix_from_file = false;
    else
        mess = 'Invalid write option specified in put_sqw_data for ''a'' type data';
        return
    end
else
    error('logic error in put_sqw_data')
end


% Write header information to file
% --------------------------------
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

position.s=[];
position.e=[];
position.npix=[];
position.urange=[];
position.pix=[];
npixtot=[];


% Write further information to file, if requested
% -----------------------------------------------
if ~write_header_only
    data_type = data_type_in;
    
    position.s=ftell(fid);
    fwrite(fid,data.s,'float32');
    
    position.e=ftell(fid);
    fwrite(fid,data.e,'float32');
    
    % Optional fields depending on input data structure and options
    
    if strcmpi(data_type_in,'a')||strcmpi(data_type_in,'a-')||strcmpi(data_type_in,'b+')
        position.npix=ftell(fid);
        fwrite(fid,data.npix,'int64');  % make int64 so that can deal with huge numbers of pixels
    end
    
    if strcmpi(data_type_in,'a')||strcmpi(data_type_in,'a-')
        % Write urange
        position.urange=ftell(fid);
        fwrite(fid,data.urange,'float32');
        % Write pix if requested
        if pix_from_struct
            fwrite(fid,1,'int32');          % redundant field - only present for backwards compatibility
            npixtot=size(data.pix,2);
            fwrite(fid,npixtot,'int64');    % make int64 so that can deal with huge numbers of pixels
            position.pix=ftell(fid);
            data_type='a';
            if npixtot>0
                % Try writing large array of pixel information a block at a time - seems to speed up the write slightly
                % Need a flag to indicate if pixels are written or not, as cannot rely just on npixtot - we really
                % could have no pixels because none contributed to the given data range.
                block_size=1000000;
                for ipix=1:block_size:npixtot
                    istart = ipix;
                    iend   = min(ipix+block_size-1,npixtot);
                    fwrite(fid,data.pix(:,istart:iend),'float32');
                end
            end
        elseif pix_from_file
            fwrite(fid,1,'int32');              % redundant field - only present for backwards compatibility
            npix_cumsum = cumsum(data.npix(:)); % accumulated number of pixels per bin as a column vector
            npixtot=npix_cumsum(end);
            fwrite(fid,npixtot,'int64');        % make int64 so that can deal with huge numbers of pixels
            position.pix=ftell(fid);
            data_type='a';
            if npixtot>0
                mess = put_sqw_data_pix_from_file (fid, infiles, npixstart, pixstart, npix_cumsum, run_label);
            end
        else
            data_type='a-';
        end
    end

else
    % Only wrote the header information
    data_type='h';
end

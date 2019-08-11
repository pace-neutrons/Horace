function [mess,main_header,header,detpar,data,position,npixtot,data_type,file_format,current_format] = get_sqw (dummy,infile,varargin)
% Load an sqw file from disk
%
%   >> [mess,main_header,header,detpar,data,position,npixtot,data_type,file_format,current_format]...
%            = get_sqw (sqw,infile)
%   >> [...] = get_sqw (sqw,infile, '-h')
%   >> [...] = get_sqw (sqw,infile, '-his')
%   >> [...] = get_sqw (sqw,infile, '-hverbatim')
%   >> [...] = get_sqw (sqw,infile, '-hisverbatim')
%   >> [...] = get_sqw (sqw,infile, '-nopix')
%   >> [...] = get_sqw (sqw,infile, npix_lo, npix_hi)
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%
%   opt         [optional] Determines which fields to read:
%                   '-h'            - header block without instrument and sample information, and
%                                   - data block fields: filename, filepath, title, alatt, angdeg,...
%                                                          uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                                    (If the file was written from a structure of type 'b' or 'b+', then
%                                    urange does not exist, and the output field will not be created)
%                   '-his'          - header block in full i.e. with without instrument and sample information, and
%                                   - data block fields as for '-h'
%                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-hisverbatim'  Similarly as for '-his'
%                   '-nopix'        Pixel information not read (only meaningful for sqw data type 'a')
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file
%   npix_hi     -|
%
%
% Output:
% --------
%   mess        Error message; blank if no errors, non-blank otherwise
%
%   main_header Main header block (for details of data structure, type >> help get_sqw_main_header)
%
%   header      Header block (for details of data structure, type >> help get_sqw_header)
%              Cell array if more than one contributing spe file.
%
%   detpar      Detector parameters (for details of data structure, type >> help get_sqw_detpar)
%
%   data        Output data structure actually read from the file. Will be one of:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,urange]
%                   type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%               The final field urange is present for type 'h' if the header information was read from an sqw-type file.
%
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%              These field are correctly filled even if the header only has been requested, that is,
%              if input option '-h' or '-hverbatim' was given
%                   position.main_header    start of main_header block (=[] if not written in the file)
%                   position.header         start of each header block (column vector, length main_header.nfiles)
%                                          (=[] if not written in the file)
%                   position.detpar         start of detector parameter block (=[] if not written in the file)
%                   position.data           start of data block
%                   position.s              position of array s
%                   position.e              position of array e
%                   position.npix           position of array npix (=[] if npix not written in the file)
%                   position.urange         position of array urange (=[] if urange not written in the file)
%                   position.pix            position of array pix  (=[] if pix not written in the file)
%                   position.instrument     start of header instrument blocks (=[] if not written in the file)
%                   position.sample         start of header sample blocks (=[] if not written in the file)
%                   position.position_info  position of start of the position block (=[] if not written in the file)
%
%   npixtot     Total number of pixels written to file (=[] if pix not present in the file)
%
%   data_type   Type of sqw data written in the file 
%                   type 'b'    fields: filename,...,dax,s,e
%                   type 'b+'   fields: filename,...,dax,s,e,npix
%                   type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
%                   type 'a-'   fields: filename,...,dax,s,e,npix,urange
%
%   current_format  =true if the file format has one of the current formats, =false if not
%
%   file_format     Format of file
%                       Current formats:  '-v2', '-v3'
%                       Obsolete formats: '-prototype'
% 
%
% NOTES:
% ======
% Supported file Formats
% ----------------------
% The current sqw file format comes in two variants:
%   - Horace version 1 and version 2: file format '-v2'
%      (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
%       This format is the one still written if these fields all have the 'empty' value in the sqw object.
%   - Horace version 3: file format '-v3'.
%       (November 2013 onwards.) Writes the instrument and sample fields from the header block, and
%      positions of the start of major data blocks in the sqw file. This format is written if the
%      instrument and sample fields are not 'empty'.
%
% Adding sample or instrument data to an existing '-v2' file will convert the format to '-v3'.
% Subsequently setting the sample and instrument to 'empty' will *NOT* convert the file back
% to '-v2' due to limitations of Matlab file writing. (Matlab does not permit the length of an
% existing file to be shortened).
%
% Additionally, this routine will read the prototype sqw file format (July 2007(?) - Autumn 2008).
% This differs from the Horace '-v2' and '-v3' file formats in a few regards:
%   - The application name and version are not saved in the file, nor are the sqw-type and
%     number of dimensions. These have to be determined from the other contents.
%   - title,alatt,angdeg are not stored in the data section (these will be filled from the
%     main header when converting to the current data format).
%   - The signal and error for the bins in stored without normalisation by the number of pixels.
%     Any data stored as type 'b' is therefore uninterpretable by Horace version 1 onwards because
%     the npix information that is needed to normalise the signal and error in each bin is not available.
%
% We will only attempt to read an unrecognised file as the sqw-type prototype file, and ignore the
% possibility of it being a dnd file.


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


[mess,main_header,header,detpar,data,position,npixtot,data_type,file_format,current_format] = get_sqw (infile,varargin{:});

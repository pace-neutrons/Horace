function [mess,position,npixtot,type] = put_sqw_gui (outfile,main_header,header,detpar,data,hObject,handles,varargin)
% Write an sqw data structure to file
%
%   >> [mess, position, npixtot, type] = put_sqw (outfile, main_header, header, detpar, data)
%   >> [mess, position, npixtot, type] = put_sqw (outfile, main_header, header, detpar, data, '-nopix')
%   >> [mess, position, npixtot, type] = put_sqw (outfile, main_header, header, detpar, data, '-pix')
%   >> [mess, position, npixtot, type] = put_sqw (outfile, main_header, header, detpar, data, '-pix',...
%                                                              infiles, npixstart, pixstart, run_label)
%
% Input:
% -------
%   outfile     File name, or file identifier of open file, to which to write data
%   main_header Main header block (for details of data structure, type >> help get_sqw_main_header)
%   header      Header block (for details of data structure, type >> help get_sqw_header)
%   detpar      Detector parameters (for details of data structure, type >> help get_sqw_detpar)
%   data        Valid sqw data structure which must contain the fields listed below  (for details, type >> help get_sqw_data)
%                       type 'b'    fields: uoffset,...,s,e
%                       type 'b+'   fields: uoffset,...,s,e,npix
%                       type 'a'    uoffset,...,s,e,npix,urange,pix
%               In addition, will take the data structure of type 'a' without the individual pixel information ('a-')
%                       type 'a-'   uoffset,...,s,e,npix,urange
%
%   opt         [optional argument for type 'a' or type 'a-'] Determines whether or not to write pixel info, and
%               from which source:
%                 -'-nopix'  do not write the info for individual pixels
%                 -'-pix'    write pixel information
%               The default source of pixel information is the data structure, but if the optional arguments below
%               are given, then use the corresponding source of pixel information
%
%               Can also choose to write just the headaer information in data:
%                 -'-h'      the information as read with '-h' option in get_sqw is written
%                           namely the fields: uoffset,...,dax
%                           (Note: urange will not be written, even if present - types 'a' or 'a-')
%
%   infiles     Cell array of file names, or array of file identifiers of open file, from
%                                   which to accumulate the pixel information
%   npixstart   Position (in bytes) from start of file of the start of the field npix
%   pixstart    Position (in bytes) from start of file of the start of the field pix
%   run_label   Indicates how to re-label the run index (pix(5,...) 
%                       'fileno'    relabel run index as the index of the file in the list infiles
%                       'nochange'  use the run index as in the input file
%                   This option exists to deal with the two limiting cases 
%                    (1) There is one file per run, and the run index in the header block is the file
%                       index e.g. as in the creating of the master sqw file
%                    (2) The run index is already written to the files correctly indexed into the header
%                       e.g. as when temporary files have been written during cut_sqw
%
%
% Output:
% --------
%   mess        If no problem, then mess=''
%               If a problems contains error message and position=[], npixtot=[]; file left open if passed as a fid
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%                   position.main_header    start of main_header block (=[] if not written)
%                   position.header         start of each header block (header is column vector, length main_header.nfiles)
%                   position.detpar         start of detector parameter block (=[] if not written)
%                   position.data           start of data block
%                   position.s      position of array s
%                   position.e      position of array e
%                   position.npix   position of array npix (=[] if npix not written)
%                   position.pix    position of array pix  (=[] if pix not written)
%   npixtot     Total number of pixels written to file  (=[] if pix not written)
%   type        Type of sqw data written to file: 'a', 'a-', 'b+' or 'b'
% 

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

application=horace_version;

% Determine type of object
if ~isempty(main_header)
    nfiles = main_header.nfiles;    % expected number of headers
    sqw_type=true;
else
    nfiles = 0;
    sqw_type=false;
end

% Initialise output
position = struct('main_header',[],'header',zeros(nfiles,1),'detpar',[],'data',[],'s',[],'e',[],'npix',[],'pix',[]);
npixtot = [];
type='';

% Open output file
if isnumeric(outfile)
    fout = outfile;   % copy fid
    if isempty(fopen(fout))
        mess = 'No open file with given file identifier';
        return
    end
    close_file = false;
else
    fout=fopen(outfile,'W');    % no automatic flushing: can be faster
    if fout<0
        mess = ['Unable to open file ',outfile];
        return
    end
    close_file = true;
end

% Write application and version number
mess = put_application (fout, application);
if ~isempty(mess); if close_file; fclose(fout); end; return; end

% Write sqw_type and dimensions
ndims = data_dims(data);
mess = put_sqw_object_type (fout, sqw_type, ndims);
if ~isempty(mess); if close_file; fclose(fout); end; return; end

% Write main header
if ~isempty(main_header)
    position.main_header=ftell(fout);
    mess = put_sqw_main_header (fout, main_header);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end
end

% Write header(s) of individual spe file(s)
% (special case of dnd-style data is empty header)
if isstruct(header) && ~isempty(header)     % should be a single header, as a data structure
    if nfiles~=1;
        mess='Check consistency of field ''nfiles'' in main header and the number of header(s)';
        if close_file; fclose(fout); end;
        return
    end
    position.header(1)=ftell(fout);
    mess = put_sqw_header (fout, header);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end
else    % should be a cell array of headers
    if nfiles~=length(header);
        mess='Check consistency of field ''nfiles'' in main header and the number of header(s)';
        if close_file; fclose(fout); end;
        return;
    end
    for i=1:nfiles
        position.header(i)=ftell(fout);
        mess = put_sqw_header (fout, header{i});
        if ~isempty(mess); if close_file; fclose(fout); end; return; end
    end
end

% Write detector parameters
% (empty if dnd-style data)
if ~isempty(detpar)
    position.detpar=ftell(fout);
    mess = put_sqw_detpar (fout, detpar);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end
end

% Write data
position.data=ftell(fout);
[mess,position_data,npixtot,type] = put_sqw_data_gui (fout, data, hObject, handles, varargin{:});
if ~isempty(mess); if close_file; fclose(fout); end; return; end
position.s=position_data.s;
position.e=position_data.e;
position.npix=position_data.npix;
position.pix=position_data.pix;

% Close down, if required
if close_file
    fclose(fout);
end

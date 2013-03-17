function [mess,position,npixtot,type] = put_sqw (outfile,main_header,header,detpar,data,varargin)
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
%               Lastly, the information as read with '-h' or '-hverbatim' option in get_sqw is valid input,
%                       type 'h'    fields: uoffset,...,dax
%
%   opt         [optional argument for type 'a' or type 'a-'] Determines whether or not to write pixel info, and
%               from which source:
%                  '-nopix'  Do not write the information for individual pixels
%                  '-pix'    Write pixel information
%               The default source of pixel information is the data structure, but if the 
%              optional arguments below are given, then use them to give the corresponding source
%              of pixel information if option '-pix' has been specified.
%               In particular, note that '-pix' with data type 'a-' is permitted if the following
%              arguments are provided.
%
% [All or none of the optional arguments below must be present]
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
% Output:
% --------
%   mess        If no problem, then mess=''
%               If a problems contains error message and position=[], npixtot=[]; file left open if passed as a fid
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
%                   position.main_header    start of main_header block (=[] if not written)
%                   position.header         start of each header block (column vector, length main_header.nfiles)
%                                          (=zeros(0,1) if not written)
%                   position.detpar         start of detector parameter block (=[] if not written)
%                   position.data           start of data block
%                   position.s              position of array s
%                   position.e              position of array e
%                   position.npix           position of array npix (=[] if npix not written)
%                   position.urange         position of array urange (=[] if urange not written)
%                   position.pix            position of array pix  (=[] if pix not written)
%                   position.data_block_end position immediately after the end of the data block
%                   position.header_opt     start of each header optional block (column vector, length main_header.nfiles)
%                                          (=zeros(0,1) if not written)
%                   position.position_info  position of start of the position block
%
%   npixtot     Total number of pixels written to file  (=[] if pix not written)
%   type        Type of sqw data written to file: 'a', 'a-', 'b+' or 'b'
% 
%
% NOTES:
% ======
% File Formats
% ------------
% The current sqw file format comes in two variants:
%   - version 1 and version 2
%      (Autumn 2008 onwards.) Does not contain instrument and sample fields in the header block.
%       This format is the one still written if these fields are empty in the sqw object (or result of a
%       cut on an sqw file assembled only to a file - see below).
%   - version 3
%       (February 2013 onwards.) Writes optional instrument and sample fields in the header block, and
%      positions of the start of major data blocks in the sqw file. Finally, finishes with the positon
%      of the position data block and the end of the data block as the last two 8 byte entries.
%
% Writing header information
% --------------------------
% This function can be called with just the information that was read with the '-h' or '-hverbatim'
% option in get_sqw. However, this will not create a valid sqw file. It is only meaningful if
% this function is being called to overwrite the corresponding data of exactly the same length
% in a previously existing sqw file. Use this option only with extreme care!
%
% Writing pixel information from file
% -----------------------------------
% The optionsl argument '-pix' enables pixel information to be taken from other files. These
% temporary files must have been created using the function: put_sqw_data_npix_and_pix_to_file.
% It will be assumed that the information passed witht he '-pix' option is fully consistent
% with the rest of the data being written by this function.


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
position = struct('main_header',[],'header',zeros(nfiles,1),'detpar',[],...
    'data',[],'s',[],'e',[],'npix',[],'urange',[],'pix',[],'header_opt',zeros(nfiles,1),'position_info',[]);
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
% ------------------------------------
% Determine the output file format version to be written
% - if instrument and sample blocks are both empty, use version 2 format (same as version 1)
% - if not, then use 3 format
% The reason for doing this is that older versions of Horace will be able to read the format

application_out=application;
no_inst_and_sample=put_sqw_header_get_type (header);
if no_inst_and_sample
    file_format_version=2;
    application_out.version=file_format_version;
else
    file_format_version=application_out.version;
end
mess = put_application (fout, application_out);
if ~isempty(mess); if close_file; fclose(fout); end; return; end


% Write sqw_type and dimensions
% ------------------------------------
ndims = data_dims(data);
mess = put_sqw_object_type (fout, sqw_type, ndims);
if ~isempty(mess); if close_file; fclose(fout); end; return; end


% Write main header
% ------------------------------------
if ~isempty(main_header)
    position.main_header=ftell(fout);
    mess = put_sqw_main_header (fout, main_header);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end
end


% Write header(s) of individual spe file(s)
% -----------------------------------------
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
% ------------------------------------
% (empty if dnd-style data)
if ~isempty(detpar)
    position.detpar=ftell(fout);
    mess = put_sqw_detpar (fout, detpar);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end
end


% Write data
% ------------------------------------
position.data=ftell(fout);
[mess,position_data,npixtot,type] = put_sqw_data (fout, data, varargin{:});
if ~isempty(mess); if close_file; fclose(fout); end; return; end
position.s=position_data.s;
position.e=position_data.e;
position.npix=position_data.npix;
position.urange=position_data.urange;
position.pix=position_data.pix;


% Write format 3 fields
% ------------------------------------
if file_format_version>=3
    
    % Write optional header fields
    % ------------------------------------
    if isstruct(header) && ~isempty(header)     % should be a single header, as a data structure
        position.header_opt(1)=ftell(fout);
        mess = put_sqw_header_opt (fout, header);
        if ~isempty(mess); if close_file; fclose(fout); end; return; end
    else    % should be a cell array of headers
        for i=1:nfiles
            position.header_opt(i)=ftell(fout);
            mess = put_sqw_header_opt (fout, header{i});
            if ~isempty(mess); if close_file; fclose(fout); end; return; end
        end
    end
    
    % Write position data
    % ------------------------------------
    position.position_info=ftell(fout);
    mess = put_sqw_position_info (fout, position);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end
    
    % Final entries: position block location, data type and length of data type
    % -------------------------------------------------------------------------
    mess=put_sqw_file_footer(fout,position.position_info,type);
    if ~isempty(mess); if close_file; fclose(fout); end; return; end

end


% Close down, if required
% ------------------------------------
if close_file
    fclose(fout);
end

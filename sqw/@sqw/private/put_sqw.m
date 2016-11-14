function [mess,position,npixtot,data_type] = put_sqw (outfile,main_header,header,detpar,data,varargin)
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
%
%   main_header Main header structure (for details of data structure, type >> help get_sqw_main_header)
%
%   header      Header structure (for details of data structure, type >> help get_sqw_header)
%
%   detpar      Detector parameter structure (for details of data structure, type >> help get_sqw_detpar)
%
%   data        Data section structure abstracted from sqw data type, which must contain the fields:
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
%   opt         Determines which parts of the input data structures to write to a file. By default, the
%              entire contents of the input data structure are written, apart from the case of 'h' when
%              urange will not be written if present. The default behaviour can be altered with one of
%              the following options:
%                  '-h'      Write main_header, header excluding sample and instrument blocks,
%                           detpar and only the header fields of the input data: filename,...,uoffset,...,dax
%                           Note that urange is not written, even if present in the input data.
%                           Option '-h' can only be applied to a pre-existing sqw file.
%                  '-his'    As above, but write the instrument and sample blocks as well.
%                           Also, as above, option '-his' can only be applied to a pre-existing sqw file.
%                  '-nopix'  Do not write the information for individual pixels
%                  '-pix'    Write pixel information, either from the data structure, or from the
%                           information in the additional optional arguments infiles...run_label (see below).
%
% [The following are valid only with the '-pix' option. Either all or none of them must be present]
%   infiles     Cell array of file names, or array of file identifiers of open file, from
%              which to accumulate the pixel information
%
%   npixstart   Position (in bytes) from start of file of the start of the field npix
%
%   pixstart    Position (in bytes) from start of file of the start of the field pix
%
%   run_label   Indicates how to re-label the run index (pix(5,:))
%                       'fileno'        relabel run index as the index of the file in the list infiles
%                       'nochange'      use the run index as in the input file
%                        numeric array  offset run numbers for ith file by ith element of the array
%                   This option exists to deal with three limiting cases:
%                    (1) The run index is already written to the files correctly indexed into the header
%                       e.g. as when temporary files have been written during cut_sqw
%                    (2) There is one file per run, and the run index in the header block is the file
%                       index e.g. as in the creating of the master sqw file
%                    (3) The files correspond to several runs in general, which need to
%                       be offset to give the run indices into the collective list of run parameters
%
% Output:
% --------
%   mess        Error message if there is a problem; if no problem, then mess=''.
%               If a problem, then the output is file left open if the function was passed a fid.
%
%   position    Position (in bytes from start of file) of blocks of fields and large fields:
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
%                   position.position_info  start of the position block (=[] if not written in the file
%                                          i.e. has file format '-v2')
%               The positions of these blocks are correct for the output file, even if the options '-h'
%               or '-his' are given.
%
%   npixtot     Total number of pixels in the file  (=[] if no pix field information in the file)
%              That is, if pix is absent then npixtot==[]; whereas if size(pix)==[9,0], npixtot=0)
%
%   data_type   Type of sqw data written in the file: 'a', 'a-', 'b+' or 'b'
%              Note that only types 'a' and 'b+' correspond to valid sqw objects (sqw-type and dnd-type respectively)
%
%
% NOTES:
% ======
% File Formats
% ------------
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
% This function cannot be used to write the prototype file format, which is now obsolete
%
%
% Input
% -----
% It is assumed that the main header, header, detector and data structures are all mutually consistent,
% as would be the case from a valid sqw object. That sqw object can be sqw-type, or dnd-type (when the main header,
% beader and detector structures will all be empty structures). A subset of the fields of the data structure may be
% abstracted from the full data structure, as defined by the types 'a','a-','b+','b' and 'h' above, but those
% abstracted fields are assumed to be consistent with the main header, header and detpar.
%
% What is written to the file
% ---------------------------
% The output file is deemd to be dnd-type (and contains a character string indicating as such) if 
% the main_header is empty, and sqw-type otherwise. The latter will still be the case if the data block
% that is written to the file is 'a', 'a-', 'b+' or 'b' - even though only 'a' is truly valid for
% sqw-type data. This is only a legacy feature, and may be forbidden in a later release.
%
% Writing header information
% --------------------------
% This function can be called with just the information that was read with the '-h' or '-his' options
% (or their '-hverbatim' and '-hisverbatim' variants) in get_sqw. This is only permitted if
% this function is being called to overwrite the corresponding data in a previously existing sqw file.
% Further more, while the instrumnet and sample fields of the header may have different lengths than in the 
% sqw file being overwritten, it is assumed that the lengths of all the other fields in main_header,
% header, detpar and data are unchanged. Use this option only with extreme care!
%
% Writing pixel information from file
% -----------------------------------
% The optionsl argument '-pix' enables pixel information to be taken from other files. These
% temporary files must have been created using the function put_sqw_data_npix_and_pix_to_file.
% It will be assumed that the information passed witht he '-pix' option is fully consistent
% with the rest of the data being written by this function.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

application=horace_version;

% Initialise output
position = struct('main_header',[],'header',[],'detpar',[],...
    'data',[],'s',[],'e',[],'npix',[],'urange',[],'pix',[],'instrument',[],'sample',[],'position_info',[]);
npixtot = [];
data_type='';

% Determine type of object
if ~isempty(main_header)
    sqw_type=true;
else
    sqw_type=false;
end

% Determine if option is set to write header only: this can only be done to a previously written sqw file
if numel(varargin)>0 && ischar(varargin{1}) && (strcmpi(varargin{1},'-h')||strcmpi(varargin{1},'-his'))
    newfile=false;
    write_data_header_only=true;
    if strcmpi(varargin{1},'-h')
        write_inst_and_samp=false;
    else
        write_inst_and_samp=true;
    end
else
    newfile=true;
    write_data_header_only=false;
    write_inst_and_samp=true;
end

% Open output file with correct read/write permission, or check currently open file is OK
[mess,filename,fid,fid_input]=put_sqw_open(outfile,newfile);
if ~isempty(mess), return, end


% Write application and version number
% ------------------------------------
% Determine the output file format version to be written:
% - If one or both of the instrument or sample blocks are non-empty, use the version 3 format
% - If the instrument and sample blocks are both empty, use the version 2 format (which is the same as version 1)
% However, if overwriting an existing sqw file
% - If the format is already '-v3' then it must remain so, even if the instrument and sample information field correspond to empty information.

% being removed from a file that already has
% such information, the file will remain in the version 3 format.

filled_inst_or_sample=put_sqw_header_get_type (header);
if newfile
    if ~filled_inst_or_sample
        application.version=2;  % disguise as having been created by Horace version 2
        file_format='-v2';
    else
        file_format='-v3';
    end
else
    [mess,application_file] = get_application (fid,application.name);  % get Horace version that wrote the file
    if tidy_close(mess,fid_input,fid), return, end
    if application_file.version==2 && ~(filled_inst_or_sample && write_inst_and_samp)
        application.version=2;  % retain disguise as still having been created by Horace version 2
        file_format='-v2';
    else    % if '-v3', must remain so even if no sample or instrument information
        file_format='-v3';
        if application_file.version==2
            change_v2_to_v3=true;
        else
            change_v2_to_v3=false;
        end
    end
    frewind(fid);  % set the file position indicator back to the start of the file
end
mess = put_application (fid, application);
if tidy_close(mess,fid_input,fid), return, end


% Write sqw_type and dimensions
% ------------------------------------
ndims = data_dims(data);
mess = put_sqw_object_type (fid, sqw_type, ndims);
if tidy_close(mess,fid_input,fid), return, end


% Write main header
% ------------------------------------
% (empty if dnd-style data)
if ~isempty(main_header)
    [mess,position.main_header] = put_sqw_main_header (fid, main_header);
    if tidy_close(mess,fid_input,fid), return, end
end


% Write header(s) of individual spe file(s)
% -----------------------------------------
% (empty if dnd-style data)
if ~isempty(header)
    [mess,position.header] = put_sqw_header (fid, header);
    if tidy_close(mess,fid_input,fid), return, end
end


% Write detector parameters
% ------------------------------------
% (empty if dnd-style data)
if ~isempty(detpar)
    [mess,position.detpar] = put_sqw_detpar (fid, detpar);
    if tidy_close(mess,fid_input,fid), return, end
end


% Write data
% ------------------------------------
if ~write_data_header_only
    [mess,position_data,npixtot_written,data_type_written,fid_input] = put_sqw_data (fid, data, varargin{:});
else
    [mess,position_data,npixtot_written,data_type_written,fid_input] = put_sqw_data (fid, data, '-h', varargin{2:end});
end
if tidy_close(mess,fid_input,fid), return, end

position.data=position_data.data;
if ~newfile
    % The position values, npixtot and data_type written by put_sqw_data may not be the values that are
    % true for the actual contents of the file, as only parts of the file may have been overwritten.
    if strcmp(file_format,'-v3') && ~change_v2_to_v3    % format upon opening the file is '-v3'
        existing_file_format='-v3';
        fseek(fid,0,'eof');     % go to end of file
        [mess,dummy_position,data_type_from_file]=get_sqw_file_footer(fid);    % get data type written to file
        if tidy_close(mess,fid_input,fid), return, end
    else
        existing_file_format='-v2';
        data_type_from_file='';
    end
    % Get the position locations (looks inefficient, but only reads the header information, which is very small)
    fseek(fid,position.data,'bof');    % return to the start of the data block
    sqw_dat = data_sqw_dnd();
    [mess,dummy_data,position_data,npixtot_written,data_type_written] = sqw_dat.get_sqw_data (fid, '-h', existing_file_format, data_type_from_file);
    if tidy_close(mess,fid_input,fid), return, end
end

position.s=position_data.s;
position.e=position_data.e;
position.npix=position_data.npix;
position.urange=position_data.urange;
position.pix=position_data.pix;
npixtot=npixtot_written;
data_type=data_type_written;


% Write format 3 fields
% ------------------------------------
if strcmp(file_format,'-v3')
    error('SQW:not_implemented','put_sqw: saving v3 format using this function is not implemented');
    % If '-v3' then we are either writing to a newfile, which is straightforward, or writing to
    % a previously existing file, in which case there are two cases to consider. If it was
    % originally a '-v2' file we are simply going to append all the further fields required for
    % the '-v3' format, whether or not earlier fields in the '-v2' part of the file were
    % overwritten. If the file was originally a '-v3' file then the situation is more complex.
    % The new header_opt block may be shorter or longer than the original; if the former we
    % can squeeze it in  without lengthening the file; if the latter, we need to append.
    
    if newfile
        [mess,position.instrument] = put_sqw_header_inst (fid, header);
        if tidy_close(mess,fid_input,fid), return, end
        [mess,position.sample] = put_sqw_header_samp (fid, header);
        if tidy_close(mess,fid_input,fid), return, end
        [mess,position] = put_sqw_position_info (fid, position, true);
        if tidy_close(mess,fid_input,fid), return, end
        mess=put_sqw_file_footer(fid,position.position_info, data_type);
        if tidy_close(mess,fid_input,fid), return, end
    
    elseif write_inst_and_samp  % if existing '-v3' but not writing instrument or sample information, then do not need to change
        % Open temporary buffer file to hold instrument, sample and position information: easier to do
        % this than try to compute the length of each block
        tmpfile=tempname;
        ftmp=fopen(tmpfile,'w+');  % will be reading and writing to the buffer
        if ftmp<0
            mess='Unable to open temporary file needed to buffer data';
            tidy_close(mess,fid_input,fid);
            return
        end
        % Write optional header info and position info to buffer file
        [mess,position.instrument] = put_sqw_header_inst (ftmp, header);
        if tidy_close(mess,fid_input,fid,ftmp), return, end
        [mess,position.sample] = put_sqw_header_samp (ftmp, header);
        if tidy_close(mess,fid_input,fid,ftmp), return, end
        [mess,position] = put_sqw_position_info (ftmp, position, true);
        position_info_tmp=position.position_info;   % position of info block in buffer
        if tidy_close(mess,fid_input,fid,ftmp), return, end
        nbytes=ftell(ftmp);     % Number of bytes; we will have to update the values of the positions below, but the no. bytes is correct
        % Determine if there is space to write this in the output file before the footer section
        pos_eodata=ftell(fid);
        fseek(fid,0,'eof');
        pos_eof=ftell(fid);
        nbytes_footer=numel(data_type)+12;  % 8 bytes for position location, 1 byte per char is stored data_type, 4 bytes to hold no. chars
        append=(pos_eof-pos_eodata<nbytes+nbytes_footer);
        if append
            pos_offset=pos_eof; % offset for position information to correspond to appending to end of file
            fclose(fid);        % close output file and reopen in append mode
            fid=fopen(filename,'ab');
            if fid<0
                mess=['Unable to re-open output file to append to: ',file];
                tidy_close(mess,fid_input,fid);
                return
            end
        else
            pos_offset=pos_eodata;  % offset for position information to correspond overwriting after the data block
            fseek(fid,pos_eodata,'bof');   % go back to end of data block
        end
        % Offset the position data for the information written to the buffer
        position.instrument = position.instrument + pos_offset;
        position.sample = position.sample + pos_offset;
        position.position_info = position.position_info + pos_offset;
        % Rewrite the position information to the buffer
        fseek(ftmp,position_info_tmp,'bof');
        [mess,position] = put_sqw_position_info (ftmp, position, false);
        if tidy_close(mess,fid_input,fid,ftmp), return, end
        if append
            % Write footer to the buffer
            mess=put_sqw_file_footer(ftmp,position.position_info, data_type);
            if tidy_close(mess,fid_input,fid,ftmp), return, end
            % Copy buffer to the output file
            frewind(ftmp);
            tmpvar=fread(ftmp,Inf,'char*1');
            fwrite(fid,tmpvar,'char*1');
        else
            % Copy buffer to the output file
            frewind(ftmp);
            tmpvar=fread(ftmp,Inf,'char*1');
            fwrite(fid,tmpvar,'char*1');
            % Go to correct point in output  file and overwrite the footer
            fseek(fid,-nbytes_footer,'eof');
            mess=put_sqw_file_footer(fid,position.position_info, data_type);
            if tidy_close(mess,fid_input,fid,ftmp), return, end
        end
        % Delete the temporary file
        fclose(ftmp);
        try
            delete(tmpfile)
        catch
            disp('Unable to delete buffer file created when writing output sqw file')
        end
    end
end


% Close down, if required
% ------------------------------------
if ~fid_input
    fclose(fid);
end

%--------------------------------------------------------------------------------------------------
function status=tidy_close(mess,file_already_open,fid,ftmp)
% Tidy shut down of files if there was an error
%
%   >> status=tidy_close(mess,file_already_open,fid,ftmp)
%
% Input:
% ------
%   mess                Message; if empty, then assume there was no error; otherwise assume an error
%   file_already_open   True if the output sqw file was already open on input (so don't close it)
%   fid                 File identifier of sqw file. If not 
%   ftmp                [Optional] File identifier of temporary file; if present then close the file
%                      and delete if an error
%
% Output:
% -------
%   status              True if input argument 'mess' reported an error; false otherwise

if isempty(mess)
    status=false;
else
    status=true;
    % Close sqw file, if open
    if ~file_already_open && fid>=3 && ~isempty(fopen(fid))
        fclose(fid);
    end
    if exist('ftmp','var')
        tmpfile=fopen(ftmp);
        fclose(ftmp);
        try
            delete(tmpfile)
        catch
            disp('Unable to delete buffer file created when writing output sqw file')
        end
    end
end
        
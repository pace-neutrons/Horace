function [ok, mess, S] = put_sqw (file, w, varargin)
% Write an sqw data structure to file
%
% Save to a new file:
%   >> [ok,mess,S] = put_sqw (file, w)
%   >> [ok,mess,S] = put_sqw (file, w, '-pix', v1, v2,...)  % save pix information from other sources
%
%   >> [...] = put_sqw (..., 'file_format', fmt)    % specifiy an older file format for output
%
% Save npix and pix information to a new temporary file (no file format option available)
%   >> [ok,mess,S] = put_sqw (file, w, '-buffer')   % save npix and pix to buffer file
%
% Replace header in an existing file:
%   >> [ok,mess,S] = put_sqw (file, w, '-h')        % without replacing instrument and sample info
%   >> [ok,mess,S] = put_sqw (file, w, '-his')      % replace instrument and sample info as well
%
%
%
% Input:
% -------
%   file        File name, or sqwfile information structure for an open sqw file.
%               The contents of the files will be discarded unless writing 
%              header information only (see '-h' or '-his' options below)
%
%   w           A single sqw object or a structure with the fields of a valid sqw object.
%               w can be a sparse dnd-type or sqw-type structure.
%
%               In the case of optional arguments, then a structure with an incomplete
%               set of fields can be given:
%                   'h', 'his': w.main_header, w.header, w.detpar  must exist but can be empty.
%                               w.data only needs the header fields:
%                                       filename,...,uoffset,...,dax
%
%                   'pix':      w.data does not need the field pix , because the additional
%                               arguments v1, v2, ...  will define sources of the pixel information
%
%                   'buffer':   If non-sparse, only npix and pix are used:
%                                   w.main_header, w.header, w.detpar  must exist, but can be empty
%                                   w.data.npix, w.data.pix  must exist
%
%                               If sparse, then must have the following fields:
%                                   w.header.en (single spe file) or w.header{i}.en (multiple spe files)
%                                   w.detpar
%                                   w.data.p, w.data.npix, w.data.npix_nz, w.data.pix_nz, w.pix
%
%                               Alternatively, a flat structure can be given with the required fields:
%                                - non-sparse: npix, pix
%                                - sparse:     sz, nfiles, ndet, ne_max, npix, npix_nz, pix_nz, pix
%                                           (sz      = Size of npix array when in non-sparse format
%                                            nfiles  = 1 (single spe file) NaN (more than one)
%                                            ndet    = no. detectors
%                                            ne_max  = number en bins in the spe file with the largest
%                                                      number of energy bins)
%
%   opt_name    Determines which parts of the input data structures to write to a file. By default, the
%              entire contents of the input data structure are written, apart from the case of 'h' when
%              urange will not be written if present. The default behaviour can be altered with one of
%              the following options:
%                  '-h'      Write main_header, header excluding sample and instrument blocks,
%                           detpar and only the header fields of the input data: filename,...,uoffset,...,dax
%                           Note that urange is not written, even if present in the input data.
%                           Option '-h' can only be applied to a pre-existing sqw file.
%                  '-his'    As above, but write the instrument and sample blocks as well.
%                           Also, as above, option '-his' can only be applied to a pre-existing sqw file.
%                  '-buffer' Only write npix and pix information.
%                  '-pix'    Write pixel information from the information in the additional 
%                           optional arguments (see below).
%
%   v1, v2,...  [Valid only with the '-pix' option] Arguments defining how pixels are to be collected
%               from various sources other than input argument 'data' and written to this file.
%
%   file_format [Optional] File format to be written:
%                   '-v3.1'     Default
%                   '-v3'       Format used by Horace version 3. Sparse sqw structures will be written as
%                              full format
%                   '-v1'       Format used by Horace version 1 and 2.
%               The file format cannot be given if writing header only (which is only done to pre-existing
%               files) or buffer file (which will always use the current default format)
%   
%
% Output:
% --------
%   ok          =true if all OK, =false otherwise
%
%   mess        Error message if there is a problem; if no problem, then mess=''.
%               If a problem, then the output is file left open if the function was passed a fid.
%
%   S           sqwfile structure with the information updated to match the written sqw file.
%
%
% NOTES:
% ======
% File Formats
% ------------
% This function cannot be used to write the prototype file format, '-v0', which is now obsolete.
%
% Writing header information
% --------------------------
% This function can be called with just the information that was read with the '-h' or '-his' options
% (or their '-hverbatim' and '-hisverbatim' variants) in get_sqw. This is only permitted if
% this function is being called to overwrite the corresponding data in a previously existing sqw file.
% Further more, while the instrument and sample fields of the header may have different lengths than in the 
% sqw file being overwritten, it is assumed that the lengths of all the other fields in main_header,
% header, detpar and data are unchanged. Use this option only with extreme care!
%
% Writing pixel information from file
% -----------------------------------
% The optionsl argument '-pix' enables pixel information to be taken from other files or sources.
% It will be assumed that the information passed witht he '-pix' option is fully consistent
% with the rest of the data being written by this function.
%
% Writing npix and pix information only ('-buffer' option, or structure with only these fields)
% --------------------------------------
% Use this function to create the buffer files that are used to hold npix and pix information
% when performing cuts.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% To do list:
% -----------
% *** Catch trying to write a dnd header to an sqw file ?


% Valid file formats:
ver1=appversion(1);
ver3=appversion(3);
ver3p1=appversion(3,1);    % Current default format


% Get application and version number
% ----------------------------------
application=horace_version();

% Initialise output arguments
% ---------------------------
ok=true;

% Determine form of input
% -----------------------
% Determine type of object and data
[data_type_name_in,sparse_fmt,flat] = data_structure_type_name (w);
data_type_in=data_structure_name_to_type(data_type_name_in);

% Parse optional arguments
% ------------------------
[mess,newfile,fmt_ver,data_type_name_write,opt,optvals] = check_options(data_type_name_in,varargin{:});
if ~isempty(mess), ok=false; S=sqwfile(); return, end
data_type_write=data_structure_name_to_type(data_type_name_write);


% Open output file with correct read/write permission, or check currently open file is OK
% ---------------------------------------------------------------------------------------
if ~isstruct(file)
    % Assume is a file name
    file_open_on_entry=false;
    if newfile
        [S,mess] = sqwfile_open (file, 'new');
    else
        [S,mess] = sqwfile_open (file, 'old');
    end
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
else
    % Assume is an sqwfile structure
    file_open_on_entry=true;
    S=file;
end

fid=S.fid;
info=S.info;
position=S.position;
fmt=S.fmt;

if newfile
    % Writing an sqw file (sqw or dnd type), or a buffer file
    
    % Update application section (version and file format may be updated later)
    application.file_format=fmt_ver;        % add file format to application
    S.application=application;              % update the application block
    
    % Update info section (apart from npixtot and npixtot_nz)
    info.sparse=sparse_fmt;
    info.sqw_data=data_type_write.sqw_data;
    info.sqw_type=data_type_write.sqw_type;
    info.buffer_data=data_type_write.buffer_data;
    [info.nfiles,info.ne,info.ndet,info.ndims,info.sz]=sqwfile_get_pars(w,data_type_in,flat,data_type_write);
    S.info=info;                            % update the information block
    
    % Write information at top of file (do this now to reserve the right amount of space in the file)
    [mess, position_sqwfile] = put_sqw_information (S);  % write to file (will update with correct information later)
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
    position=updatestruct(position,position_sqwfile);
    
    % Set write flags for sections other than data section
    write_non_data_sections = data_type_write.sqw_type;
    if fmt_ver>=ver3
        write_inst_and_samp = write_non_data_sections;   % means: write if they exist
    else
        write_inst_and_samp = false;
    end
    
else
    % Can only be writing header to a pre-existing file
    [mess,write_non_data_sections] = check_header_opt_ok (info,w);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
    write_inst_and_samp = (write_non_data_sections && opt.his); % means: write if they exist, remove if don't

    % Get format
    fmt_ver=S.application.file_format;
    
    % Overcome a very weird error if writing to an existing file tha I've encountered
    % Seems that some status flag(s) is/are lost; jogging the file solves it!
    fseek(fid,ftell(fid),'bof');
end


% Write main header
% ------------------------------------
if write_non_data_sections
    [mess,position.main_header] = put_sqw_main_header (fid, fmt_ver, w.main_header);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end


% Write header(s) of individual spe file(s)
% -----------------------------------------
if write_non_data_sections
    [mess,position.header,pos_header_arr] = put_sqw_header (fid, fmt_ver, w.header);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end


% Write detector parameters
% ------------------------------------
if write_non_data_sections
    [mess,position.detpar] = put_sqw_detpar (fid, fmt_ver, w.detpar);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end


% Write data (only header part if header option)
% ----------------------------------------------
if newfile
    % Writing sqw data or buffer data to a new file
    if data_type_write.buffer || data_type_write.buffer_sp
        % buffer data, or buffer option with sqw data
        if flat % data has flat buffer structure format
            [mess,position_data,fmt_data,info.nz_npix,info.nz_npix_nz,info.npixtot,info.npixtot_nz] = ...
                put_sqw_data (fid, fmt_ver, w, sparse_fmt, '-buffer');
        else    % data has sqw structure
            [mess,position_data,fmt_data,info.nz_npix,info.nz_npix_nz,info.npixtot,info.npixtot_nz] = ...
                put_sqw_data (fid, fmt_ver, w.data, sparse_fmt, '-buffer');
        end
        
    elseif opt.pix
        % sqw output with pix data from another source
        [mess,position_data,fmt_data,info.nz_npix,info.nz_npix_nz,info.npixtot,info.npixtot_nz] = ...
            put_sqw_data (fid, fmt_ver, w.data, sparse_fmt, '-pix', optvals{:});
        
    else
        % All other cases: dnd data or sqw data
        [mess,position_data,fmt_data,info.nz_npix,info.nz_npix_nz,info.npixtot,info.npixtot_nz] = ...
            put_sqw_data (fid, fmt_ver, w.data, sparse_fmt);
    end
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
    
    % Update position and format structures
    position = updatestruct(position,position_data);
    fmt = updatestruct(fmt,fmt_data);

else
    % Can only be writing header to an existing file
    mess = put_sqw_data (fid, fmt_ver, w.data, sparse_fmt, '-h');
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end


% Write sample and instrument information
% ---------------------------------------
if write_inst_and_samp
    if header_inst_or_sample(w.header);
        % If not a new file, then must get to the end of the data section before writing instrument
        % and sample information. This is because if we are just writing the header, then the earlier
        % write to the data section will have left the file position indicator at the start of the
        % signal array, not the end of the data section.
        if ~newfile
            fseek(fid,position.data_end,'bof');     % end of data section
        end
        % Now write instrument and sample blocks
        [mess,position.instrument] = put_sqw_header_inst (fid, fmt_ver, w.header);
        if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
        
        [mess,position.sample] = put_sqw_header_samp (fid, fmt_ver, w.header);
        if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
        
        % Set flag that indicates instrument and sample information was actually written
        wrote_inst_and_samp=true;
        
    else
        % If not a new file, then could have sample and instrument blocks written to file.
        % We would like to delete them from the file, but we cannot remove by merely closing
        % However, we can remove any reference to these by setting their positions to NaN.
        if ~newfile
            position.instrument=NaN;
            position.sample=NaN;
        end
        wrote_inst_and_samp=false;
        
    end
end


% Update S, and save to file
% --------------------------
if newfile
    % Update info, position and fmt fields of S
    S.info=info;
    S.position=position;
    S.fmt=fmt;
    
else
    % Writing header only; need only to update the positions of the instrument and sample
    S.position.instrument=position.instrument;
    S.position.sample=position.sample;
    
end

% Older file formats: write footer sections and update S if required
if fmt_ver<ver3p1
    [mess,S] = put_sqw_LEGACY_position_info_footer (S, newfile, pos_header_arr, wrote_inst_and_samp);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end

% Write sqwfile
fseek(fid,0,'bof');
mess = put_sqw_information (S);
if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
    

% Closedown
% ---------
if ~file_open_on_entry  % opened file in this routine, so close again
    S = sqwfile_close(S);
end


%==================================================================================================
function [mess,newfile,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in,varargin)
% Check the data type and optional arguments for validity
%
%   >> [mess,newfile,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in)
%   >> [mess,newfile,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in,opt_name)
%   >> [mess,newfile,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in,opt_name,p1,p2,...)
%
%   >> [mess,newfile,fmt_ver,data_type_write,opt,optvals] = check_options(..., 'file_format', fmt)
%
% Input:
% ------
%   data_type_in    Data structure type. Assumed to be one of:
%                       'dnd', 'dnd_sp', 'sqw_', 'sqw_sp_', 'sqw', 'sqw_sp'
%                       'buffer', 'buffer_sp'
%                       'h'
%
%   opt_name        [optional] option character string: one of '-h', '-his', '-buffer', '-pix'
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
%   newfile         If true: need to open a new file; if false: need to open an existing file
%
%   fmt_ver         Format of file to be written to if new file (appversion object)
%                   Empty if an existing file must be used
%
%   data_type_write Type of data that will be written to file. Will be one of:
%                       'dnd', 'dnd_sp', 'sqw', 'sqw_sp'
%                       'buffer', 'buffer_sp'
%                       'h'
%                   Note that the input cases 'sqw_' and 'sqw_sp_' are not possible
%                  as output possibilities because they will have required the '-pix'
%                  option to be provided.
%                   If data_type_in is 'h' then the type of data in the output file will
%                  not be the same as data_type_write, because the function will be overwriting
%                  existing data. In all other cases data_type_write is the same as the
%                  type that will be contained by the final file, as a new file is created.
%
%   opt             Structure with fields 'h', 'his', 'pix', 'buffer' with values true
%                  or false for the different values
%
%   optvals         Optional arguments (={} if none)
%
%
% The valid options are:
% ----------------------
% Save to a new file:
%   >> [ok,mess,S] = put_sqw (file, w)
%   >> [ok,mess,S] = put_sqw (file, w, '-pix', v1, v2,...)  % save pix information from other sources
%
%   >> [...] = put_sqw (..., 'file_format', fmt)    % specifiy an older file format for output
%
% Save npix and pix information to a temporary file (no format option available)
%   >> [ok,mess,S] = put_sqw (file, w, '-buffer')           % save npix and pix to buffer
%
% Replace header in an existing file:
%   >> [ok,mess,S] = put_sqw (file, w, '-h')    % without replacing instrument and sample info
%   >> [ok,mess,S] = put_sqw (file, w, '-his')  % replace instrument and sample info as well
%
% If older file formats are specified, the function checks that the dats is consistent
% e.g. buffer files cannot be written to the version 3 format and earlier.

mess='';
newfile=false;
fmt_ver=[];
data_type_write='';
opt=struct('h',false,'his',false,'buffer',false,'pix',false);
optvals={};


% Determine if output file format was specified
% ---------------------------------------------
narg=numel(varargin);
if narg>=2 && is_string(varargin{end-1}) && strcmpi(varargin{end-1},'file_format')
    try
        fmt_ver=appversion(varargin{end});
        if ~fmt_check_file_format (fmt_ver, 'write')
            mess=['Cannot write with format ',appversion_str(fmt_ver)];
            return
        end
    catch
        mess='Unrecognised file_format description';
        return
    end
    narg=narg-2;
else
    fmt_ver=[];
end


% Check optional arguments have valid syntax of form (...,opt, v1, v2,...)
% ------------------------------------------------------------------------
if narg>0
    opt_name=varargin{1};
    if is_string(opt_name) && ~isempty(opt_name)
        if strcmpi(opt_name,'-h')
            if narg>1
                mess='Number of arguments for option ''-h'' is invalid';
                return
            end
            opt.h=true;
            optvals={};
            
        elseif strcmpi(opt_name,'-his')
            if narg>1
                mess='Number of arguments for option ''-his'' is invalid';
                return
            end
            opt.his=true;
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
noopt=~(opt.h||opt.his||opt.buffer||opt.pix);


% Determine if valid write option for input data structure type
% -------------------------------------------------------------
if strcmpi(data_type_in,'h')
    if opt.h || opt.his || noopt
        data_type_write='h';
    else
        mess = 'Invalid write option specified for ''h'' type data';
        return
    end
    
elseif strcmpi(data_type_in,'dnd') || strcmpi(data_type_in,'dnd_sp')
    if opt.h || opt.his
        data_type_write='h';
    elseif noopt
        data_type_write=data_type_in;
    else
        mess = ['Invalid write option specified for ''',data_type_in,''' type data'];
        return
    end
    
elseif strcmpi(data_type_in,'sqw_') || strcmpi(data_type_in,'sqw_sp_')
    if opt.h || opt.his
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
    if opt.h || opt.his
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


% Check file format consistency
% -----------------------------
if ~isempty(fmt_ver)
    % File format cannot be specified for writing header or buffer
    if strcmpi(data_type_write,'h')
        mess='Cannot specify output file format when writing header only';
        return
    elseif strcmpi(data_type_write,'buffer')
        mess='Cannot specify output file format when writing npix and pix buffer';
        return
    end
    % Check older file formats are consistent with data being written
    if fmt_ver<appversion(3,1)
        if ~(strcmpi(data_type_write,'sqw') || strcmpi(data_type_write,'dnd'))
            mess='Only sqw-type or dnd-type sqw data can be written in file formats earlier than 3.1';
            return
        end
    end
else
    % Use current default file format for new files
    if ~strcmpi(data_type_write,'h')
        fmt_ver=fmt_check_file_format();
    end
end


% Set newfile flag
% ----------------
if isempty(fmt_ver)
    newfile=false;
else
    newfile=true;
end


%==================================================================================================
function [mess,header_opt_write_non_data] = check_header_opt_ok (info, w)
% Check that the input data for header option and existing file contents are consistent
%
%   >> [mess,header_opt_and_write] = check_header_opt_ok (info, w)
%
% - The header in an sqw-type sqw file can only be updated if all of w.main_header, w.header,
%   w.detpar and the header fields of w.data are filled.
%
% - The header in a dnd-type sqw file can be updated so long as the header fields of w.data
%   are filled, but the contents of w.main_header, w.header adn w.detpar are immaterial
%   (i.e. the header can have been obtained from a dnd-type file, or an sqw-type file).
%
% - Buffer files cannot have headers written to them

if info.buffer_data
    mess='Cannot write header information to this file - it is a buffer file';
    header_opt_write_non_data=false;
    
else
    if info.sqw_type
        if ~isempty(w.main_header)
            mess='';
            header_opt_write_non_data=true;
        else
            mess='Cannot update an sqw-type sqw file unless all header fields are filled';
            header_opt_write_non_data=false;
        end
    else
        mess='';
        header_opt_write_non_data=false;
    end
end


%==================================================================================================
function [nfiles,ne,ndet,ndims,sz]=sqwfile_get_pars(w,data_type_in,flat,data_type_write)
% Get some parameters from the input data structure as required for an sqwfile structure
%
%   >> [nfiles,ne,ndet,ndims,sz]=sqwfile_get_pars(w,data_type_in,flat,data_type_write)

  
[ndims,szsqw,szarr]=data_structure_dims(w);

if data_type_write.sqw_type || data_type_write.buffer_sp
    % Writing sqw-type data or sparse buffer
    if data_type_in.buffer_sp && flat   % input data is sparse buffer
        if w.nfiles==1
            nfiles=1;
        else
            nfiles=NaN;
        end
        ne=w.ne_max;
        ndet=w.ndet;
    else    % input data is sqw-type (even if writing out buffer data)
        if isstruct(w.header)
            nfiles=1;
            ne=numel(w.header.en)-1;
        else
            header=w.header;
            nfiles=numel(w.header);     % don't use main_header, as buffer might not have it (unlikely, though)
            ne=zeros(nfiles,1);
            for i=1:nfiles
                ne(i)=numel(header{i}.en)-1;
            end
        end
        if data_type_write.buffer_data
            if nfiles~=1, nfiles=NaN; end
            ne=max(ne);
        end
        ndet=numel(w.detpar.x2);
    end
else
    % Writing dnd-type data or non-sparse buffer
    nfiles=NaN;
    ne=NaN;
    ndet=NaN;
end

% Return sqw dimensionality (sqw-type or dnd-type data) or size of npix array (buffer data)
if data_type_write.sqw_data
    sz=[szsqw,NaN(1,4-ndims)];
else
    sz=[szarr,NaN(1,4-numel(szarr))];
end


%==================================================================================================
function [ok,Sout]=tidy_close(S,leave_open)
% Tidy shut down if there was an error
%
%   >> [ok,Sout]=tidy_close(S,leave_fid_open)
%
% Input:
% ------
%   S               sqwfile structure of data source
%   leave_open      Leave the sqw file open, if not already closed
%
% Output:
% -------
%   ok              Status. Set to false.
%   Sout            sqwfile structure

ok=false;   % return argument to show there was an error
if ~leave_open
    Sout=sqwfile_close(S);
end

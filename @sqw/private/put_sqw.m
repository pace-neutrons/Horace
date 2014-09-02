function [ok, mess, S] = put_sqw (file, w, varargin)
% Write an sqw data structure to file
%
% Save to a new file:
%   >> [ok,mess,S] = put_sqw (file, w)
%   >> [ok,mess,S] = put_sqw (file, w, '-pix', v1, v2,...)  % save pix information from other sources
%
%   >> [...] = put_sqw (..., 'file_format', fmt)   % specifiy an older file format for output
%
% Save npix and pix information to a temporary file (no format option available)
%   >> [ok,mess,S] = put_sqw (file, w, '-buffer')           % save npix and pix to buffer
%
% Replace header in an existing file:
%   >> [ok,mess,S] = put_sqw (file, w, '-h')    % without replacing instrument and sample info
%   >> [ok,mess,S] = put_sqw (file, w, '-his')  % replace instrument and sample info as well
%
%
%
% Input:
% -------
%   file        File name, or sqwfile information structure
%
%   w           A single sqw object or structure with the fields of a valid sqw object.
%               w can be a sparse dnd-type or sqw-type structure.
%               Type >> help sqw    for a full description of all the fields
%
%               In the case of optional arguments, then a structure with an incomplete
%               set of fields can be given:
%                   'h', 'his': w.data only needs the header fields:
%                                       filename,...,uoffset,...,dax
%                   'buffer':   Only npix and pixel information are used (non-sparse format only):
%                                   w.main_header, w.header, w.detpar must exist, but can be empty
%                                   w.data.npix, w.data.pix
%                   'pix':      w.data does not need the field pix , because the additional
%                               arguments v1, v2, ...  will define sources of the pixel information
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
%               Not valid if writing header only (which is only done to pre-existing files) or
%               buffer file (which will always use the current default format)
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

% Determine form of input to be written
% -------------------------------------
% Determine type of object and data, and whether the sample or instrument fields are filled in the header
filled_inst_or_sample = header_inst_or_sample (w.header);
data_type_name_in = data_structure_type_name (w.data);

% Parse optional arguments
% ------------------------
[mess,fmt_ver,data_type_name_write,opt,optvals] = check_options(data_type_name_in,varargin);
[data_type_write,sparse_fmt]=data_structure_name_to_type(data_type_name_write);
if ~isempty(mess), ok=false; S=sqwfile(); return, end


% Open output file with correct read/write permission, or check currently open file is OK
% ---------------------------------------------------------------------------------------
newfile=~isempty(fmt_ver);
if ~isstruct(file)
    file_open_on_entry=false;
    if newfile
        [S,mess] = sqwfile_open (file, 'new');
    else
        [S,mess] = sqwfile_open (file, 'old');
    end
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,S.fid); return, end
else
    file_open_on_entry=true;
    S=file;
end
fid=S.fid;
info=S.info;
position=S.position;
fmt=S.fmt;


if newfile
    % Writing and sqw file or a buffer file
    if fmt_ver==ver3p1
        application.file_format=fmt_ver;        % add file format to application
        S.application=application;              % update the application block
        
        *** what to do about sparse buffer files: need ne to resolve!
        
        S.info.ne=NaN(w.main_header.nfiles,1);  % fill with array of correct length
        [mess, position_sqwfile] = put_sqw_information (S);  % write to file (will update with correct information later)
        if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
        position=mergestruct(position,position_sqwfile);
    else
        mess='Unsupported file format';
        [ok,S]=tidy_close(file_open_on_entry,fid); return
    end
else
    % Can only be writing header to a pre-existing file
    if fmt_ver==ver3p1
        if S.buffer_type
            mess='Cannot write header information to this file - it is a buffer file';
            [ok,S]=tidy_close(file_open_on_entry,fid); return
        end
    else
        if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
    end
end


% Write main header
% ------------------------------------
% (empty if dnd-style data)
if data_type_write.sqw_data
    [mess,position.main_header] = put_sqw_main_header (fid, fmt_ver, w.main_header);
    if tidy_close(mess,fid), ok=false; S=sqwfile(); return, end
end


% Write header(s) of individual spe file(s)
% -----------------------------------------
% (empty if dnd-style data)
if data_type_write.sqw_data
    [mess,position.header] = put_sqw_header (fid, fmt_ver, w.header);
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
end


% Write detector parameters
% ------------------------------------
% (empty if dnd-style data)
if data_type_write.sqw_data
    [mess,position.detpar] = put_sqw_detpar (fid, fmt_ver, w.detpar);
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
end


% Write data
% ------------------------------------
if newfile
    % Writing sqw data or buffer data to a new file
    if opt.buffer
        [mess,position_data,fmt_data,info.npixtot,info.npixtot_nz] = put_sqw_data (fid, fmt_ver, w.data, '-buffer');
    elseif opt.pix
        [mess,position_data,fmt_data,info.npixtot,info.npixtot_nz] = put_sqw_data (fid, fmt_ver, w.data, '-pix', optvals{:});
    else
        [mess,position_data,fmt_data,info.npixtot,info.npixtot_nz] = put_sqw_data (fid, fmt_ver, w.data);
    end
else
    % Can only be writing header to an existing file
    [mess,position_data,fmt_data,info.npixtot,info.npixtot_nz] = put_sqw_data (fid, fmt_ver, w.data, '-h');
end
if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end

position = mergestruct(position,position_data);
fmt = mergestruct(fmt,fmt_data);


% Write sample and instrument information
% ---------------------------------------
if data_type_write.sqw_data
    if filled_inst_or_sample
        % If not a new file, then must get to the end of the data section before writing instrument
        % and sample information. If we are just writing the header, then the earlier write to the
        % data section will have left the file poisiton indicator at the start of the signal array,
        % not the end of the data section.
        if ~newfile
            if ~isnan(position.instrument)
                fseek(fid,position.instrument,'bof');   % end of data section
            else
                fseek(fid,0,'eof');     % end of data section is end of file
            end
        end
        % Now write instrument and sample blocks
        [mess,position.instrument] = put_sqw_header_inst (fid, fmt_ver, header);
        if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
        
        [mess,position.sample] = put_sqw_header_samp (fid, fmt_ver, header);
        if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
        
    else
        % If not a new file, then could have sample and instrument blocks written to file.
        % Can remove reference to these by setting positions to NaN. (Cannot remove by closing file.)
        if ~newfile
            position.instrument=NaN;
            position.sample=NaN;
        end
    end
end


% Update S, and save to file
% --------------------------
if newfile
    % Create info section
    info.sparse=sparse_fmt;
    info.sqw_data=data_type_write.sqw_data;
    info.sqw_type=data_type_write.sqw_type;
    info.buffer_type=data_type_write.buffer_type;

    [ndims,sz]=data_dims(w.data);
    info.ndims=ndims;
    info.sz_npix=[sz,NaN(1,4-ndims)];

    % Update info, position and fmt sections of S (application section already updated)
    S.info=info;
    S.position=position;
    S.fmt=fmt;
    
else
    % Writing header only; need only to update the positions of the instrument and sample
    S.position.instrument=position.instrument;
    S.position.sample=position.sample;
    
end

% Write sqwfile
mess = put_sqw_information (S);
if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
    

% Closedown
% ---------
if ~file_open_on_entry  % opened file in this routine, so close again
    fclose(fid);
end


%==================================================================================================
function [mess,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in,varargin)
% Check the data type and optional arguments for validity
%
%   >> [mess,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in)
%   >> [mess,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in,opt)
%   >> [mess,fmt_ver,data_type_write,opt,optvals] = check_options(data_type_in,opt,p1,p2,...)
%
%   >> [mess,fmt_ver,data_type_write,opt,optvals] = check_options(..., 'file_format', fmt)
%
% Input:
% ------
%   data_type_in    Data structure type. Assumesd to be one of:
%                       'dnd', 'dnd_sp', 'sqw_', 'sqw_sp_', 'sqw', 'sqw_sp'
%                       'buffer', 'buffer_sp'
%                       'h'
%
%   opt             [optional] option character string: one of '-h', '-his', '-buffer', '-pix'
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
%   fmt_ver         Format of file to be written to if new file (appversion object)
%                   Empty if an existing file must be used
%
%   data_type_write Type of data that will be written to file. Will be one of:
%                       'dnd', 'dnd_sp', 'sqw', 'sqw_sp'
%                       'buffer', 'buffer_sp'
%                       'h'
%                   Note that the input cases 'sqw_' and 'sqw_sp_' are not possible
%                  because they will have required the '-pix' option to be provided.
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

mess='';
fmt_ver=[];
data_type_write='';
opt=struct('h',false,'his',false,'buffer',false,'pix',false);
optvals={};

% Determine if output file format was specified
% ---------------------------------------------
narg=numel(varargin);
if narg>=2 && isstring(varargin{end-1}) && strcmpi(varargin{end-1},'file_format')
    try
        fmt_ver=appversion(varargin{end});
        if ~fmt_check_file_format (fmt_ver, 'write')
            mess=['Cannot write with format ',verstion_str(fmt_ver)];
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
    if isstring(opt_name) && ~isempty(opt_name)
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
        mess='Cannot specify output file format when writing npic and pix buffer';
        return
    end
else
    % Use current default file format for new files
    if ~strcmpi(data_type_write,'h')
        fmt_ver=fmt_check_file_format();
    end
end


%==================================================================================================
function [ok,S]=tidy_close(leave_open,fid,ftmp)
% Tidy shut down of files if there was an error
%
%   >> [ok,S]=tidy_close(leave_fid_open,fid,ftmp)
%
% Input:
% ------
%   leave_fid_open      Leave the sqw file open, if not already closed
%   fid                 File identifier of sqw file
%   ftmp                [Optional] File identifier of temporary file; if present then close the file
%                      and delete if an error
%
% Output:
% -------
%   ok                  Status. Set to false.
%   S                   sqwfile structure with default contents

ok=false;

% Close sqw file if requested
if fid>=3 && ~isempty(fopen(fid))
    if leave_open
        S=sqwfile();
        S.fid=fid;
        S.filename=fopen(fid);
    else
        fclose(fid);
        S=sqwfile();
    end
else
    S=sqwfile();
end

% Close and delete temporary file, if open
if exist('ftmp','var') && ftmp>=3 && ~isempty(fopen(fid))
    tmpfile=fopen(ftmp);
    fclose(ftmp);
    try
        delete(tmpfile)
    catch
        disp('Unable to delete buffer file created when writing output sqw file')
    end
end


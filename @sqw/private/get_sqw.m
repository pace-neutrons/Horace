function [w, ok, mess, S] = get_sqw (file, varargin)
% Read information from an sqw file as a structure
%
% Header information only
% -----------------------
%   >> [S,ok,mess] = get_sqw (file,'-info')         % sqwfile structure only
%
%
% If dnd-type or sqw-type data (sparse or non-sparse):
% ----------------------------------------------------
%   >> [w,ok,mess] = get_sqw (file)                 % load sqw or dnd structure according to contents
%   >> [w,ok,mess] = get_sqw (file,'-dnd')          % load as dnd-type structure even if sqw contents
%   >> [w,ok,mess] = get_sqw (file,'-sqw')          % throw error if not sqw-type
% 
%   >> [w,ok,mess] = get_sqw (file,'-h')            % read all except s,e,npix,pix [npix_nz,pix_nz]
%   >> [w,ok,mess] = get_sqw (file,'-his')          % read all except s,e,npix,pix [npix_nz,pix_nz]
%   >> [w,ok,mess] = get_sqw (file,'-hverbatim')    % read all except s,e,npix,pix [npix_nz,pix_nz]
%   >> [w,ok,mess] = get_sqw (file,'-hisverbatim')  % read all except s,e,npix,pix [npix_nz,pix_nz]
%   >> [w,ok,mess] = get_sqw (file,'-nopix')        % read all except pix [npix_nz,pix_nz]
%
%   To return as non-sparse format structures if stored as sparse format:
%   >> ... = get_sqw (...,'-full')	
%
%
% If buffer file data:
% --------------------
%   >> [w,ok,mess] = get_sqw (file)                 
%   >> [w,ok,mess] = get_sqw (file,'-buffer')       % load as buffer data (i.e. npix,pix (npix_nz,pix_nz)
%                                                   % even if sqw-type data
%
%   To return as non-sparse format structures if stored as sparse format:
%   >> ... = get_sqw (...,'-full')	
%
%
% Individual fields:
% ------------------
%   Non-sparse arrays (or sparse arrays with the '-full' option) are returned with
% the requisite shape for the stored object.
%   If an array section is read, or an array is sparse, then a column vector
% is returned (pix is always a [9,n] array).
%
%   If non-sparse format:
%   ---------------------
% 	>> [npix,ok,mess] = get_sqw (file,'npix')           % load npix
%   >> [npix,ok,mess] = get_sqw (file,'npix', [blo,bhi])% load npix between given bin numbers
% 
% 	>> [pix,ok,mess] = get_sqw (file,'pix')             % load pix
%   >> [pix,ok,mess] = get_sqw (file,'pix', [plo,phi])  % load pix between given pixel numbers
% 
%   If sparse format:
%   -----------------
%   >> [npix,ok,mess] = get_sqw (file,'npix')           % load npix
%   >> [npix,ok,mess] = get_sqw (file,'npix', [blo,bhi], [ilo,ihi])
%                                                       % load between the given bin numbers
%                                                       % ilo,ihi range of entries in npix
% 					
%   >> [npix_nz,ok,mess] = get_sqw (file,'npix_nz')
%   >> [npix_nz,ok,mess] = get_sqw (file,'npix_nz', [blo,bhi], [ilo,ihi]) 	
%                                                       % load between the given bin numbers
%                                                       % ilo,ihi range of entries in npix_nz
% 					
%   >> [pix_nz,ok,mess] = get_sqw (file,'pix_nz')       % load pix_nz
%   >> [pix_nz,ok,mess] = get_sqw (file,'pix_nz', [ilo,ihi])  
%                                                       % ilo,ihi range of entries in pix_nz
%
%   >> [pix,ok,mess] = get_sqw (file,'pix')             % load pix
%   >> [pix,ok,mess] = get_sqw (file,'pix', [plo,phi])  % load between the given pixel numbers
%
%   To load as a full arrays:
%   - npix or npix_nz:
%   >> ... = get_sqw (...,'-full')	
%
%   - pix_nz: 
%       <not applicable - option is just ignored>
%
%   - pix:
%   >> [pix,ok,mess] = get_sqw (file,'pix','-full')
%   >> [pix,ok,mess] = get_sqw (file,'pix', [plo,phi], [ilo,ihi])  
%                                                       % load between the given pixel numbers
%                                                       % ilo,ihi range of entries in pix_nz
%       NOTE: - The pixel coordinates are all set to zero
%             - In the last case the '-full' option is not needed, as sparse is meaningless
%
%
% Information structure
% ---------------------
% In all cases, a structure containing basic information can be returned as the fourth output:
%
%   >> [...,S] = get_sqw (...)
%
%
% Input:
% --------
%   file        File name, or sqwfile information structure. It is assumed that the file
%              contains data that is dnd-type or sqw-type, or buffer. These can be non-sparse
%              format or sparse format.
%               If the data source is given as an sqwfile information structure, no assumption
%              is made as to the current location of the position indicator.
%
%   opt         [optional] Determines which fields to read:
%                   '-dnd'          - Read as dnd even if sqw fields
%                   '-sqw'          - Read as sqw - so will throw error if does not contain sqw data
%                   '-buffer'       - Read npix and pix only (will throw error if dnd data only)
%
%                   '-h'            - header block without instrument and sample information, and
%                                   - data block fields: filename, filepath, title, alatt, angdeg,...
%                                                          uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax
%                   '-his'          - header block in full i.e. with without instrument and sample information, and
%                                   - data block fields as for '-h'
%                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-hisverbatim'  Similarly as for '-his'
%                   '-nopix'        Pixel information not read (only meaningful for sqw-type data)
%
%               Some individual fields can be read
%                   'npix'
%                   'pix'
%                   'npix_nz'
%                   'pix_nz'
%
%               Default: read all fields of whatever is the data contained in the file
%
%   p1,p2,...   [optional Parameters as required/optional with the different values of opt
%
%   '-full'     [optional] Convert to full format arrays in output. Ignored if data is
%               already full format.
%
%
% Output:
% --------
%   w           Data structure read from file.
%               The structure has sqw format i.e. fields main_header, header, detpar, data unless
%                   - returning buffer data: flat structure
%                   - individual field: single object
%                   - info option: will be identical to S (below) if the read was succesful
%
%   ok          Status flag; =true if no errors; =false if there was error reading the data
%
%   mess        Error message; blank if no errors, non-blank otherwise
%
%   S           sqwfile structure with the information matching the sqw file contents


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


w=[];

% Open file
% ---------
if ~isstruct(file)
    file_open_on_entry=false;
    [S,mess]=sqwfile_open(file,'readonly');
    % If an error, then set w to empty argument; in principle could cause a crash if caller expects structure
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
else
    file_open_on_entry=true;
    S=file;
end
fid=S.fid;
fmt_ver=S.application.file_format;


% Parse optional arguments
% ------------------------
[mess,flag,make_full_fmt,opt,optvals] = check_options(S,varargin{:});
if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end

% Initialise output
if flag.sqw_struct
    w.main_header = struct([]);
    w.header = struct([]);
    w.detpar = struct([]);
    w.data = struct([]);
end
if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end


% Get main header, headers and detectors, if requested
% ----------------------------------------------------
if flag.read_sqw_header
    fseek(fid,S.position.main_header,'bof');
    
    % Main header
    [mess, w.main_header] = get_sqw_main_header (fid, fmt_ver, flag.verbatim);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end

    % Header
    [mess, w.header] = get_sqw_header (fid, fmt_ver, S.info.nfiles);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end

    % Detectors
    [mess, w.detpar] = get_sqw_detpar (fid, fmt_ver);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end


% Get data, if requested
% ----------------------
if ~flag.info
    fseek(fid,S.position.data,'bof');
    if flag.sqw_struct
        [mess, w.data] = get_sqw_data (fid, fmt_ver, S, flag.read_data_header, flag.verbatim, make_full_fmt, opt, optvals{:});
        if fmt_ver==appversion(0);
            % Prototype file format. Should only have been able to get here if sqw-type data in file
            w.data.title=w.main_header.title;
            header_ave=header_average(w.header);
            w.data.alatt=header_ave.alatt;
            w.data.angdeg=header_ave.angdeg;
        end
    else
        [mess, w] = get_sqw_data (fid, fmt_ver, S, flag.read_data_header, flag.verbatim, make_full_fmt, opt, optvals{:});
    end
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
end


% Get header optional information, if requested
% ---------------------------------------------
if flag.read_inst_and_sample && ~isnan(S.position.instrument)
    fseek(fid,S.position.instrument,'bof');     % might need to skip redundant bytes
    
    % Instrument information
    [mess, w.header] = get_sqw_header_inst (fid, fmt_ver, w.header);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end
    
    % Sample information
    [mess, w.header] = get_sqw_header_samp (fid, fmt_ver, w.header);
    if ~isempty(mess), [ok,S]=tidy_close(S,file_open_on_entry); return, end

end


% Closedown
% ---------
ok=true;
if ~file_open_on_entry  % opened file in this routine, so close again
    S = sqwfile_close(S);
end

% Catch case of reading basic information only
% --------------------------------------------
if flag.info
    w=S;
end


%==================================================================================================
function [mess,flag,make_full_fmt,opt,optvals] = check_options(S,varargin)
% Check the data type and optional arguments for validity
%
%   >> [mess,flag,make_full_fmt,opt,optvals] = check_options(S)
%   >> [mess,flag,make_full_fmt,opt,optvals] = check_options(S,opt)
%   >> [mess,flag,make_full_fmt,opt,optvals] = check_options(S,opt,p1,p2,...)
%
%   >> [mess,flag,make_full_fmt,opt,optvals] = check_options(..., '-full')
%
% Input:
% ------
%   S               sqwfile structure
%
%   opt             [optional] option character string one of:
%                       '-info'
%                       '-dnd','-sqw','-h','-his','-hverbatim','-hisverbatim','-nopix','-buffer'
%                       'npix','npix_nz','pix_nz','pix'
%
%   p1,p2,...       Optional arguments as may be required by the option argument
%
% Output:
% -------
%   mess            Error message if a problem; ='' if all OK
%
%   flag            Structure with various logical flags as fields:
%               datastruct      =true if output is a structure
%               info            =true if information only: empty output
%               sqw_struct      =true if output fields main_header, header, detpar, data
%               buffer          =true if output is a buffer (a flat data structure)
%               field           =true if output is a single item i.e. not a structure
%               read_data_header     =true if read data block header
%               read_sqw_header      =true if read main_header, header, detpar
%               read_inst_and_sample =true if read instrument and sample blocks
%               verbatim             =true if data file name in main_header and data sections
%                                     are to be read as stored
%
%   make_full_fmt   Data is sparse format but conversion to non-sparse is requested
%                  (If the data is not sparse format, then then this will be set to false)
%
%   opt             Structure that defines the output (one field must be true, the others false):
%                       'info'
%                       'dnd','sqw','h','his','hverbatim','hisverbatim','nopix','buffer'
%                       'npix','npix_nz','pix_nz','pix'
%
%   optvals         Optional arguments (={} if none)
%
%
% The valid combinations of options and option arguments are given in the help to get_sqw


% Initialise output arguments
% ---------------------------
mess='';
flag=struct();
make_full_fmt=false;
opt=struct('info',false,'dnd',false,'sqw',false,'nopix',false,'buffer',false,...
    'h',false,'his',false,'hverbatim',false,'hisverbatim',false,...
    'npix',false,'npix_nz',false,'pix_nz',false,'pix',false);
optvals={};


% Get information about the file
% ------------------------------
info=S.info;
is_sparse=info.sparse;
is_sqw=(info.sqw_data & info.sqw_type);
is_dnd=(info.sqw_data & ~info.sqw_type);
is_buffer=info.buffer_data;

% Determine if full format conversion is required
% -----------------------------------------------
narg=numel(varargin);
if narg>=1 && is_string(varargin{end}) && strcmpi(varargin{end},'-full')
    make_full_fmt=true;
    narg=narg-1;
end

% Check optional arguments have valid syntax of form (...,opt, v1, v2,...)
% ------------------------------------------------------------------------
% Check the field names first, to minimise time spent processing these, as
% speed of reading can be critical for those options
if narg>0
    opt_name=varargin{1};
    narg_opt=narg-1;
    if is_string(opt_name) && ~isempty(opt_name)
        if strcmpi(opt_name,'npix')
            if (~is_sparse && narg_opt==1) || (is_sparse && narg_opt==2)
                [val,mess]=range_ok(varargin{2},'Bin index range for ''npix'': ');
                if ~isempty(mess), return, end
                if narg_opt==2
                    [val2,mess]=range_ok(varargin{3},'Entry index range for ''npix'': ');
                    if ~isempty(mess), return, end
                    optvals={val,val2};
                else
                    optvals={val};
                end
            elseif narg_opt==0
                optvals={};
            else
                if is_sparse
                    mess='Number of arguments for option ''npix'' with sparse data is invalid';
                else
                    mess='Number of arguments for option ''npix'' with non-sparse data is invalid';
                end
                return
            end
            opt.npix=true;
            
        elseif strcmpi(opt_name,'npix_nz')
            if is_sparse
                if narg_opt==2
                    [val,mess]=range_ok(varargin{2},'Bin index range for ''npix_nz'': ');
                    if ~isempty(mess), return, end
                    [val2,mess]=range_ok(varargin{3},'Entry index range for ''npix_nz'': ');
                    if ~isempty(mess), return, end
                    optvals={val,val2};
                elseif narg_opt==0
                    optvals={};
                else
                    mess='Number of arguments for option ''npix_nz'' is invalid';
                    return
                end
                opt.npix_nz=true;
            else
                mess = 'Can only read field ''npix_nz'' from sparse format data';
                return
            end
            
        elseif strcmpi(opt_name,'pix_nz')
            if is_sparse
                if narg_opt==1
                    [val,mess]=range_ok(varargin{2},'Entry index range for ''pix_nz'': ');
                    if ~isempty(mess), return, end
                    optvals={val};
                elseif narg_opt==0
                    optvals={};
                else
                    mess='Number of arguments for option ''-pix_nz'' is invalid';
                    return
                end
                opt.pix_nz=true;
            else
                mess = 'Can only read field ''pix_nz'' from sparse format data';
                return
            end
            
        elseif strcmpi(opt_name,'pix')
            if narg_opt==1 || (narg_opt==2 && is_sparse)
                [val,mess]=range_ok(varargin{2},'Pixel index range for ''pix'': ');
                if ~isempty(mess), return, end
                if narg_opt==2
                    [val2,mess]=range_ok(varargin{3},'Entry index range for ''pix_nz'': ');
                    if ~isempty(mess), return, end
                    optvals={val,val2};
                    make_full_fmt=true;
                else
                    optvals={val};
                    if is_sparse && make_full_fmt
                        mess = 'Too few arguments for option ''pix'' to convert non-sparse data to full format';
                        return
                    end
                end
            elseif narg_opt==0
                optvals={};
            else
                mess='Number of arguments for option ''-pix_nz'' is invalid';
                return
            end
            opt.pix=true;
            
        elseif strcmpi(opt_name,'-info')
            if narg_opt>0
                mess='Number of arguments for option ''-info'' is invalid';
                return
            end
            opt.info=true;
            optvals={};
                
        elseif strcmpi(opt_name,'-dnd')
            if narg_opt>0
                mess='Number of arguments for option ''-dnd'' is invalid';
                return
            end
            opt.dnd=true;
            optvals={};
        
        elseif strcmpi(opt_name,'-sqw')
            if narg_opt>0
                mess='Number of arguments for option ''-sqw'' is invalid';
                return
            end
            opt.sqw=true;
            optvals={};
        
        elseif strcmpi(opt_name,'-nopix')
            if narg_opt>0
                mess='Number of arguments for option ''-nopix'' is invalid';
                return
            end
            opt.nopix=true;
            optvals={};
        
        elseif strcmpi(opt_name,'-buffer')
            if narg_opt>0
                mess='Number of arguments for option ''-buffer'' is invalid';
                return
            end
            opt.buffer=true;
            optvals={};
                    
        elseif strcmpi(opt_name,'-h')
            if narg_opt>0
                mess='Number of arguments for option ''-h'' is invalid';
                return
            end
            opt.h=true;
            optvals={};
            
        elseif strcmpi(opt_name,'-his')
            if narg_opt>0
                mess='Number of arguments for option ''-his'' is invalid';
                return
            end
            opt.his=true;
            optvals={};
            
        elseif strcmpi(opt_name,'-hverbatim')
            if narg_opt>0
                mess='Number of arguments for option ''-hverbatim'' is invalid';
                return
            end
            opt.hverbatim=true;
            optvals={};
            
        elseif strcmpi(opt_name,'-hisverbatim')
            if narg_opt>0
                mess='Number of arguments for option ''-hisverbatim'' is invalid';
                return
            end
            opt.hisverbatim=true;
            optvals={};

        else
            mess='Unrecognised option';
            return
        end
    else
        mess='Unrecognised option';
        return
    end
    
else
    % No option given. Find the equivalent explicit option that leads to the same result
    % depending on data type (sqw, dnd, buffer)
    if is_sqw
        opt.sqw=true;
        optvals={};
    elseif is_dnd
        opt.dnd=true;
        optvals={};
    elseif is_buffer
        opt.buffer=true;
        optvals={};
    end
    
end


% Check consistency of the options with the different data types
% --------------------------------------------------------------
if is_dnd
    if opt.nopix
        % 24/10/14 (TGP): '-nopix' is only a valid option with sqw data, but because it
        % is a benign error to use it on dnd data, we can just replace it with opt.dnd
        opt.dnd=true;
        opt.nopix=false;
    elseif opt.sqw || opt.buffer
        mess = ['Cannot use option ''',opt_name,''' with dnd-type data'];
        return
    elseif opt.npix_nz || opt.pix_nz || opt.pix
        mess = ['Cannot read field ''',opt_name,''' from dnd-type data'];
        return
    end
    
elseif is_buffer
    if opt.dnd || opt.sqw || opt.h || opt.his || opt.hverbatim || opt.hisverbatim || opt.nopix
        mess = ['Cannot use option ''',opt_name,''' with buffer (i.e. npix and pix) data'];
        return
    end
    
elseif ~is_sqw
    error('Unrecognised data type')
    
end

% Repackage result of opt in a more convenient way for reading data from the file,
% flagging also which fields to read with header option if given
flag = flags_from_opt (is_sqw, opt);


%==================================================================================================
function flag = flags_from_opt (is_sqw, opt)
% Translate the opt structure into various flags that direct the reading from the file
%
%   >> flag = flags_from_opt (is_sqw, opt, datastruct)
%
% Input:
% ------
%   is_sqw  The file being read is an sqw-type sqw file
%
%   opt     Structure that defines the output (one field must be true, the others false):
%                       'info'
%                       'dnd','sqw','h','his','hverbatim','hisverbatim','nopix','buffer'
%                       'npix','npix_nz','pix_nz','pix'
%
% Output:
% -------
%   flag    Structure with various logical flags as fields:
%               datastruct      =true if output is a structure
%               info            =true if information only: empty output
%               sqw_struct      =true if output fields main_header, header, detpar, data
%               buffer          =true if output is a buffer (a flat data structure)
%               field           =true if output is a single item i.e. not a structure
%               read_data_header     =true if read data block header
%               read_sqw_header      =true if read main_header, header, detpar
%               read_inst_and_sample =true if read instrument and sample blocks
%               verbatim             =true if data file name in main_header and data sections
%                                     are to be read as stored


% One of the header options:
header_opt = opt.h || opt.his || opt.hverbatim || opt.hisverbatim;

% Form of output:
info = opt.info;
sqw_struct = opt.sqw || opt.dnd || opt.nopix || header_opt;
buffer = opt.buffer;
datastruct = sqw_struct || info || buffer;
field = ~datastruct;

% An sqw_structure implies reading the data section header and vice versa:
read_data_header = sqw_struct;

% Read main_header, header, detpar if sqw structure output, unless those fields are empty or 
% we explicitly asked for dnd output. That is, if gave a header option, return main_header etc.
% if those fields are available, as well as if we asked for sqw output.
read_sqw_header = is_sqw && (opt.sqw || opt.nopix || header_opt);

% If gave the header option, read the instrument and sample information only if explicitly asked
% for it. If opt.sqw or opt.nopix, then always read instrument and sample.
read_inst_and_sample = read_sqw_header && ~(opt.h || opt.hverbatim);

% Verbatim reading is only an option for reading header
verbatim = opt.hverbatim || opt.hisverbatim;

flag = struct('datastruct',datastruct,'info',info,'sqw_struct',sqw_struct,'buffer',buffer,'field',field,...
    'read_data_header',read_data_header,'read_sqw_header',read_sqw_header,...
    'read_inst_and_sample',read_inst_and_sample,'verbatim',verbatim);


%==================================================================================================
function [val_out,mess]=range_ok(val,mess_in)
% Check an argument specifies an integer range
%
%   >> [val,mess]=range_ok(val_in,mess_in)
%
% Input:
% ------
%   val         Numeric array of form [ilo,ihi] where 0 < ilo <= ihi (ilo, ihi integers)
%              or a numeric scalar 0 < val_in (val_in an integer)
%
%   mess_in     message stub
%
% Output:
% -------
%   val_out     If all is OK, then a copy of input argument val_in, or expanded
%              to [val_in,val_in] if input was a scalar
%               If there was a problem, [NaN,NaN]
%   mess        if all OK: empty string ''; otherwise contains an error message

mess='';
if isnumeric(val)
    if numel(val)==2 && val(2)>=val(1) && all(rem(val,1)==0) && val(1)>0
        val_out=val;
    elseif isscalar(val) && rem(val,1)==0 && val>0
        val_out=[val,val];
    else
        val_out=[NaN,NaN];
        mess='Range must be an integer range [a,b] with b>a>0 or an integer scalar >0';
        if nargin>1
            mess=[mess_in,mess];
        end
    end
else
    val_out=[NaN,NaN];
    mess='Range must be an integer range [a,b] with b>a>0 or an integer scalar >0';
    if nargin>1
        mess=[mess_in,mess];
    end
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

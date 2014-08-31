function [w, ok, mess, S] = get_sqw (file, varargin)
% Read information from an sqw file as a structure
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
% Input:
% --------
%   file        File name, or sqwfile information structure. It is assumed that the file
%              contains data that is dnd-type or sqw-type, or buffer. These can be non-sparse
%              format or sparse format.
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
%   w           Data structure read from file
%
%   ok          Status flag; =true if no errors; =false if there was error reading the data
%
%   mess        Error message; blank if no errors, non-blank otherwise
%
%   S           sqwfile structure with the information updated to match the written sqw file.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Open file
% ---------
if ~isstruct(file)
    file_open_on_entry=false;
    [S,mess]=sqwfile_open(file,'readonly');
    % If an error, then set w to empty argument; in principle could cause a crash if caller expects structure
    if ~isempty(mess), w=[]; [ok,S]=tidy_close(file_open_on_entry,S.fid); return, end
else
    file_open_on_entry=true;
    S=file;
end
fid=S.fid;
fmt_ver=S.application.file_format;


% Parse optional arguments
% ------------------------
[mess,datastruct,make_full_fmt,opt,opt_name,optvals] = check_options(S,varargin{:});
read_sqw_header = (datastruct && S.sqw_type);  % read sqw header only if data structure return and sqw data in file

% Initialise output
if datastruct
    w.main_header = struct([]);
    w.header = struct([]);
    w.detpar = struct([]);
    w.data = struct([]);
else
    w=[];
end
if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end


% Get main header, headers and detectors (if requested)
% --------------------------------------
if read_sqw_header
    % Main header
    if opt.hverbatim
        [mess, w.main_header] = get_sqw_main_header (fid, fmt_ver,'-verbatim');
    else
        [mess, w.main_header] = get_sqw_main_header (fid, fmt_ver);
    end
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end

    % Header
    [mess, w.header] = get_sqw_header (fid, fmt_ver, S.info.nfiles);
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end

    % Detctors
    [mess, w.detpar] = get_sqw_detpar (fid, fmt_ver);
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
end


% Get data
% --------
if datastruct
    [mess, w.data] = get_sqw_data (fid, fmt_ver,...
        sparse_fmt, datastruct, make_full_fmt, opt, opt_name, optvals{:});
    if fmt_ver==appversion(0);
        % Prototype file format. Should only have been able to get here if sqw-type data in file
        w.data.title=w.main_header.title;
        header_ave=header_average(w.header);
        w.data.alatt=header_ave.alatt;
        w.data.angdeg=header_ave.angdeg;
    end
else
    [mess, w] = get_sqw_data (fid, fmt_ver,...
        sparse_fmt, datastruct, make_full_fmt, opt, opt_name, optvals{:});
end
if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end


% Get header optional information, if present
% -------------------------------------------
if read_sqw_header && ~isnan(S.position.instrument)
    fseek(fid,S.position.instrument,'bof');     % might need to skip redundant bytes
    
    % Instrument information
    [mess, w.header] = get_sqw_header_inst (fid, fmt_ver, w.header);
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end
    
    % Sample information
    [mess, w.header] = get_sqw_header_samp (fid, fmt_ver, w.header);
    if ~isempty(mess), [ok,S]=tidy_close(file_open_on_entry,fid); return, end

end


% Closedown
% ---------
if ~file_open_on_entry  % opened file in this routine, so close again
    fclose(fid);
end


%==================================================================================================
function [mess,datastruct,make_full_fmt,opt,opt_name,optvals] = check_options(S,varargin)
% Check the data type and optional arguments for validity
%
%   >> [mess,datastruct,make_full_fmt,opt,opt_name,optvals] = check_options(S)
%   >> [mess,datastruct,make_full_fmt,opt,opt_name,optvals] = check_options(S,opt)
%   >> [mess,datastruct,make_full_fmt,opt,opt_name,optvals] = check_options(S,opt,p1,p2,...)
%
%   >> [mess,datastruct,make_full_fmt,opt,opt_name,optvals] = check_options(..., '-full')
%
% Input:
% ------
%   S               sqwfile structure
%
%   opt             [optional] option character string one of:
%                       '-dnd','-sqw','-h','-his','-hverbatim','-hisverbatim','-nopix','-buffer'
%                       'npix','npix_nz','pix_nz','pix'
%
%   p1,p2,...       Optional arguments as may be required by the option argument
%
% Output:
% -------
%   mess            Error message if a problem; ='' if all OK
%
%   datastruct      Signifies data to be read:
%                     - true  if a data structure ('-dnd','-sqw','-h*','-nopix','-buffer')
%                     - false if a field from the data
%
%   make_full_fmt Data is sparse format but conversion to non-sparse is requested
%                  (If the data is not sparse format, then then this will be set to false)
%
%   opt             Structure with fields set to true or false according to the option:
%                       'dnd','sqw','h','his','hverbatim','hisverbatim','-nopix','buffer'
%                       'npix','npix_nz','pix_nz','pix'
%
%   opt_name        Option as character string
%                       '-dnd','-sqw','-h','-his','-hverbatim','-hisverbatim','-nopix','-buffer'
%                       'npix','npix_nz','pix_nz','pix'
%                   If no option, opt_name=''
%
%   optvals         Optional arguments (={} if none)
%
%
% The valid combinations of options and option arguments are given in the help to get_sqw

mess='';
datastruct=false;
make_full_fmt=false;
opt=struct('-dnd',false,'-sqw',false,'-nopix',false,'-buffer',false,...
    '-h',false,'-his',false,'-hverbatim',false,'-hisverbatim',false,...
    'npix',false,'npix_nz',false,'pix_nz',false,'pix',false);
opt_name='';
optvals={};

% Determine if full format conversion is required
% -----------------------------------------------
narg=numel(varargin);
if narg>=1 && isstring(varargin{end}) && strcmpi(varargin{end},'-full')
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
    if isstring(opt_name) && ~isempty(opt_name)
        if strcmpi(opt_name,'npix')
            if narg_opt<=1
                if narg_opt>0
                    [val,mess]=range_ok(varargin{2},'Bin index range for ''npix'': ');
                    if ~isempty(mess), return, end
                    optvals={val};
                else
                    optvals={};
                end
                opt.npix=true;
            else
                mess='Number of arguments for option ''npix'' is invalid';
                return
            end
            
        elseif strcmpi(opt_name,'npix_nz')
            if narg_opt<=1
                if narg_opt>0
                    [val,mess]=range_ok(varargin{2},'Bin index range for ''npix_nz'': ');
                    if ~isempty(mess), return, end
                    optvals={val};
                else
                    optvals={};
                end
                opt.npix_nz=true;
            else
                mess='Number of arguments for option ''npix_nz'' is invalid';
                return
            end
            
        elseif strcmpi(opt_name,'pix_nz')
            if narg_opt<=1
                if narg_opt>0
                    [val,mess]=range_ok(varargin{2},'Entry index range for ''pix_nz'': ');
                    if ~isempty(mess), return, end
                    optvals={val};
                else
                    optvals={};
                end
                opt.pix_nz=true;
            else
                mess='Number of arguments for option ''-pix_nz'' is invalid';
                return
            end
            
        elseif strcmpi(opt_name,'pix')
            if narg_opt<=2
                if narg_opt>0
                    [val,mess]=range_ok(varargin{2},'Pixel index range for ''pix'': ');
                    if ~isempty(mess), return, end
                    optvals={val};
                    if narg_opt==2
                        [val2,mess]=range_ok(varargin{2},'Entry index range for ''pix_nz'': ');
                        if ~isempty(mess), return, end
                        optvals=[optvals,val2];
                    end
                else
                    optvals={};
                end
                opt.npix=true;
            else
                mess='Number of arguments for option ''-pix_nz'' is invalid';
                return
            end
            
        elseif strcmpi(opt_name,'-dnd')
            if narg_opt>0
                mess='Number of arguments for option ''-dnd'' is invalid';
                return
            end
            opt.dnd=true;
            optvals={};
            datastruct=true;
            
        elseif strcmpi(opt_name,'-sqw')
            if narg_opt>0
                mess='Number of arguments for option ''-sqw'' is invalid';
                return
            end
            opt.sqw=true;
            optvals={};
            datastruct=true;
        
        elseif strcmpi(opt_name,'-nopix')
            if narg_opt>0
                mess='Number of arguments for option ''-nopix'' is invalid';
                return
            end
            opt.nopix=true;
            optvals={};
            datastruct=true;
        
        elseif strcmpi(opt_name,'-buffer')
            if narg_opt>0
                mess='Number of arguments for option ''-buffer'' is invalid';
                return
            end
            opt.buffer=true;
            optvals={};
            datastruct=true;
                    
        elseif strcmpi(opt_name,'-h')
            if narg_opt>0
                mess='Number of arguments for option ''-h'' is invalid';
                return
            end
            opt.h=true;
            optvals={};
            datastruct=true;
            
        elseif strcmpi(opt_name,'-his')
            if narg_opt>0
                mess='Number of arguments for option ''-his'' is invalid';
                return
            end
            opt.his=true;
            optvals={};
            datastruct=true;
            
        elseif strcmpi(opt_name,'-hverbatim')
            if narg_opt>0
                mess='Number of arguments for option ''-hverbatim'' is invalid';
                return
            end
            opt.hverbatim=true;
            optvals={};
            datastruct=true;
            
        elseif strcmpi(opt_name,'-hisverbatim')
            if narg_opt>0
                mess='Number of arguments for option ''-hisverbatim'' is invalid';
                return
            end
            opt.hisverbatim=true;
            optvals={};
            datastruct=true;

        else
            mess='Unrecognised option';
            return
        end
    else
        mess='Unrecognised option';
        return
    end
end


% Determine if valid write option for data type
% ---------------------------------------------
info=S.info;
is_sparse=info.sparse;
is_sqw=(info.sqw_data & info.sqw_type);
is_dnd=(info.sqw_data & ~info.sqw_type);
is_buffer=info.buffer_type;

% Check consistency of field reading with non-sparse format
if ~is_sparse && (opt.npix_nz || opt.pix_nz)
    mess = ['Can only read field ',opt_name,' from sparse format data'];
    return
end

% Check consistency of the options with the different data types
if is_dnd
    if opt.sqw || opt.nopix || opt.buffer
        mess = ['Cannot use option ''',opt_name,''' with dnd-type data'];
        return
    elseif opt.npix_nz || opt.pix_nz || opt.pix
        mess = ['Cannot read field ''',opt_name,''' from dnd-type data'];
        return
    end
        
elseif is_sqw
    if opt.pix
        if numel(optvals)==2
            if is_sparse
                make_full_fmt=true;
            else
                mess = 'Too many arguments for option ''pix'' with non-sparse format sqw-type data';
                return
            end
        elseif numel(optvals)==1 && is_sparse && make_full_fmt
            mess = 'Too few arguments for option ''pix'' to convert sparse format sqw-type data to full format';
            return
        end
    end
    
    if opt.pix && numel(optvals)==2
        if is_sparse
            make_full_fmt=true;
        else
            mess = 'Too many arguments for option ''pix'' with non-sparse format sqw-type data';
            return
        end
    end
    
elseif is_buffer
    if opt.dnd || opt.sqw || opt.h || opt.his || opt.hverbatim || opt.hisverbatim || opt.nopix
        mess = ['Cannot use option ''',opt_name,''' with buffer (i.e. npix and pix) data'];
        return
    elseif opt.pix
        if numel(optvals)==2
            if is_sparse
                make_full_fmt=true;
            else
                mess = 'Too many arguments for option ''pix'' with non-sparse format buffer (i.e. npix and pix) data';
                return
            end
        elseif numel(optvals)==1 && is_sparse && make_full_fmt
            mess = 'Too few arguments for option ''pix'' to convert non-sparse format buffer (i.e. npix and pix) data to full format';
            return
        end
    end
    
else
    error('Unrecognised data type')
    
end


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

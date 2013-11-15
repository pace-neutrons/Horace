function [ok, mess, spe_file_out, par_file_out, sqw_file_out, spe_exist, spe_unique, sqw_exist] =...
    gen_sqw_check_files (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist)
% Check that the input data files and output sqw file are OK. Throws error if fails check criteria
%
%   >> [ok, mess, spe_file_out, par_file_out, sqw_file_out, spe_exist, spe_unique, sqw_exist] =...
%          gen_sqw_check_files (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist)
%
% Input:
% ------
%   spe_file            Character array or cellstr of spe file name(s)
%                      Note that the extension '.tmp' is not permitted
%   par_file            Name of detector parameter file Only one par file is permitted.
%                         - if non-empty, this must exist or an error is thrown
%                         - if empty, then ignore
%   sqw_file            Name of output sqw file
%   require_spe_exist   True if want to check the existence of all the spe files
%   require_spe_unique  True if want to check all spe files are unique
%   require_sqw_exist   True if want to check the sqw file already exists
%
% Output:
% -------
%   ok                  Logical: true if all fine, false otherwise
%   mess                Error message if not ok; ='' if ok
%   spe_file_out        Cell array of spe file name(s) - even if only one spe file [column vector]
%   par_file_out        Name of detector parameter file. Empty if none was given.
%   sqw_file_out        Name of output sqw file
%   spe_exist           Logical array, true where spe file exists, false where not
%   spe_unique          True if all spe files are unique
%   sqw_exist           True if sqw file already exists
%
% The output files have all leading and trailing whitespace removed.


ext_horace={'.tmp','.sqw','.d0d','.d1d','.d2d','.d3d','.d4d'};

% Default return arguments in case an error is encountered
spe_file_out=[]; par_file_out=[]; sqw_file_out=[]; spe_exist=[]; spe_unique=[]; sqw_exist=[];


% Check spe file input
% --------------------
if isstring(spe_file)
    spe_file_out=cellstr(strtrim(spe_file));
elseif iscellstr(spe_file)
    [ok,spe_file_out]=str_make_cellstr(spe_file);
    if ok
        spe_file_out=strtrim(spe_file_out);
    else
        mess='spe file input must be a single file name or cell array of file names'; return
    end
else
    ok=false; mess='spe file input must be a single file name or cell array of file names'; return
end

% Check all spe files exist and do not have a reserved extension name
spe_exist=true(size(spe_file_out));
spe_filled=false(size(spe_file_out));
for i=1:numel(spe_file_out)
    if ~isempty(spe_file_out{i})
        spe_filled(i)=true;
        [path,name,ext]=fileparts(spe_file_out{i});
        if any(strcmpi(ext,[ext_horace,'.par']))
            ok=false;
            mess=['spe files must not have the reserved extension ''',ext,...
                '''. Check the file is spe type and rename.'];
            return
        end
    end
    if ~spe_filled(i) || ~exist(spe_file_out{i},'file')
        spe_exist(i)=false;
        if require_spe_exist
            if isempty(spe_file_out{i})
                ok=false; mess='spe file names must be non-empty strings'; return
            else
                ok=false; mess=['spe file: ',spe_file_out{i},' does not exist']; return
            end
        end
    end
end

% Check that the (filled) spe file names are all unique
spe_unique=true;
if any(spe_filled) && ~(numel(unique(spe_file_out(spe_filled)))==numel(spe_file_out(spe_filled)))
    spe_unique=false;
    if require_spe_unique
        ok=false; mess='One or more spe file names are repeated. All spe files must be unique'; return
    end
end


% Check parameter file
% --------------------
if ~isempty(par_file)
    if isstring(par_file) && ~isempty(strtrim(par_file))
        par_file_out=strtrim(par_file);
    else
        ok=false; mess='If given, par filename  must be a non-empty string'; return
    end
    % Check par file exists
    [path,name,ext]=fileparts(par_file_out);
    if any(strcmpi(ext,[ext_horace,'.spe']))
        ok=false; 
        mess=['Detector parameter files must not have the reserved extension ''',ext,...
            '''. Check the file is .par type and rename.'];
        return
    end
    if ~exist(par_file_out,'file')
        ok=false; mess=['Detector parameter file ',par_file_out,' not found']; return
    end
else
    par_file_out='';
end


% Check sqw file
% ---------------
if isstring(sqw_file) && ~isempty(strtrim(sqw_file))
    sqw_file_out=strtrim(sqw_file);
else
    ok=false; mess='sqw file name must be a non-empty string'; return
end

% Check sqw file exist
if ~exist(sqw_file_out,'file')
    sqw_exist=false;
    if require_sqw_exist
        ok=false; mess=['sqw file: ',sqw_file_out,' does not exist']; return
    end
    pathsqw=fileparts(sqw_file_out);
    if ~isempty(pathsqw) && ~exist(pathsqw,'dir')
        ok=false; mess='Cannot find folder into which to output the sqw file'; return
    end
else
    sqw_exist=true;
end


% Check that spe, par and sqw file names do not match
% ---------------------------------------------------
if any(strcmpi(sqw_file_out,spe_file_out))
    ok=false; mess='Output sqw file name matches one of the input spe file names'; return
end

if ~isempty(par_file_out)
    if any(strcmpi(par_file_out,spe_file_out))
        ok=false; mess='Detector parameter file name matches one of the input spe file names'; return
    elseif strcmpi(par_file_out,sqw_file_out)
        ok=false; mess='Detector parameter file name and output sqw file name match'; return
    end
end


% Fill error flags
% ----------------
ok=true;
mess='';

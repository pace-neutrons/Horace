function [spe_file_out, par_file_out, sqw_file_out, spe_exist, spe_unique, sqw_exist] =...
    gen_sqw_check_files (spe_file, par_file, sqw_file, check_spe_exist, check_spe_unique, check_sqw_exist)
% Check that the input data files and output sqw file are OK. Throws error if fails check criteria
%
%   >> [spe_file_out, par_file_out, sqw_file_out, spe_exist, spe_unique, sqw_exist] =...
%          gen_sqw_check_files (spe_file, par_file, sqw_file, check_spe_exist, check_spe_unique, check_sqw_exist)
%
% Input:
% ------
%   spe_file            Character array or cellstr of spe file name(s)
%   par_file            Name of detector parameter file.
%                         - if non-empty, this must exist or an error is thrown
%                         - if empty, then ignore
%   sqw_file            Name of output sqw file
%   check_spe_exist     True if want to check the existence of all the spe files
%   check_spe_unique    True if want to check all spe files are unique
%   check_sqw_exist     True if want to check the sqw file already exists
%
% Output:
% -------
%   spe_file_out        Cell array of spe file name(s) - even if only one spe file
%   par_file_out        Name of detector parameter file. Empty if none was given.
%   sqw_file_out        Name of output sqw file
%   spe_exist           True if all spe files exist
%   spe_unique          True if all spe files are unique
%   sqw_exist           True if sqw file already exists


% Check spe file input
% --------------------
if isstring(spe_file) && ~isempty(strtrim(spe_file))
    spe_file_out=cellstr(strtrim(spe_file));
elseif iscellstr(spe_file)
    [ok,spe_file_out,all_non_empty]=str_make_cellstr_trim(spe_file);
    if ~ok || ~all_non_empty
        error('spe file input must be a single file name or cell array of file names')
    end
else
    error('spe file input must be a single file name or cell array of file names')
end

% Check all spe files exist
spe_exist=true;
for i=1:numel(spe_file_out)
    if ~exist(spe_file_out{i},'file')
        spe_exist=false;
        if check_spe_exist
            error(['spe file: ',spe_file_out{i},' does not exist'])
        end
        break
    end
end

% Check that the spe file names are all unique
spe_unique=true;
if ~(numel(unique(spe_file_out))==numel(spe_file_out))
    spe_unique=false;
    if check_spe_unique
        error('One or more spe file names are repeated. All spe files must be unique')
    end
end


% Check parameter file
% --------------------
if ~isempty(par_file)
    if isstring(par_file) && ~isempty(strtrim(par_file))
        par_file_out=strtrim(par_file);
    else
        error('If given, par filename  must be a non-empty string')
    end
    % Check par file exists
    if ~exist(par_file_out,'file')
        error(['Detector parameter file ',par_file_out,' not found'])
    end
else
    par_file_out='';
end


% Check sqw file
% ---------------
if isstring(sqw_file) && ~isempty(strtrim(sqw_file))
    sqw_file_out=strtrim(sqw_file);
else
    error('sqw file name must be a non-empty string')
end

% Check sqw file exist
sqw_exist=true;
if ~exist(sqw_file_out,'file')
    sqw_exist=false;
    if check_sqw_exist
        error(['sqw file: ',sqw_file_out,' does not exist'])
    end
end


% Check that spe, par and sqw file names do not match
% ---------------------------------------------------
if any(strcmpi(sqw_file_out,spe_file_out))
    error('Output sqw file name matches one of the input spe file names')
end

if ~isempty(par_file_out)
    if any(strcmpi(par_file_out,spe_file_out))
        error('Detector parameter file name matches one of the input spe file names')
    elseif strcmpi(par_file_out,sqw_file_out)
        error('Detector parameter file name and output sqw file name match')
    end
end

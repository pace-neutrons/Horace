function [spe_file_out, par_file_out, sqw_file_out, spe_exist, spe_unique, sqw_exist] =...
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


ext_horace={'.tmp','.sqw','.nxsqw','.d0d','.d1d','.d2d','.d3d','.d4d'};


% Check spe file input
% --------------------

%RAE - is_string fails in Matlab versions earlier than 2015b
%this is a nasty fix for this one example - are there others???
%try
tf=is_string(spe_file);
%catch
%    tf=isstring(spe_file);
%end

if tf
    spe_file_out=cellstr(strtrim(spe_file));
elseif iscellstr(spe_file)
    [ok,spe_file_out]=str_make_cellstr(spe_file);
    if ok
        spe_file_out=strtrim(spe_file_out);
    else
        error('HORACE:algorithms:invalid_argument',...
            'spe file input must be a single file name or cell array of file names');
    end
else
    error('HORACE:algorithms:invalid_argument',...
        'spe file input must be a single file name or cell array of file names');
end

% Check all spe files exist and do not have a reserved extension name
spe_exist=true(size(spe_file_out));
spe_filled=false(size(spe_file_out));
for i=1:numel(spe_file_out)
    if ~isempty(spe_file_out{i})
        spe_filled(i)=true;
        [path,name,ext]=fileparts(spe_file_out{i});
        if any(strcmpi(ext,[ext_horace,'.par']))
            error('HORACE:algorithms:invalid_argument',...
                ['spe files must not have the reserved extension "%s". ',...
                'Check the file is spe type and rename.'],ext);
        end
    end
    if ~spe_filled(i) || ~exist(spe_file_out{i},'file')
        spe_exist(i)=false;
        if require_spe_exist
            if isempty(spe_file_out{i})
                error('HORACE:algorithms:invalid_argument',...
                    'spe file names must be non-empty strings. Name of spe file N%d is empty',...
                    i);
            else
                error('HORACE:algorithms:invalid_argument',...
                    'spe file: %s does not exist',spe_file_out{i});
            end
        end
    end
end

% Check that the (filled) spe file names are all unique
spe_unique=true;
if any(spe_filled) && ~(numel(unique(spe_file_out(spe_filled)))==numel(spe_file_out(spe_filled)))
    spe_unique=false;
    if require_spe_unique
        error('HORACE:algorithms:invalid_argument',...
            'One or more spe file names are repeated. All spe files must be unique');
    end
end


% Check parameter files
% --------------------

% Ensure par_file is a cell array with the same number of elements as the
% number of spe files. A single input .par file name is expanded to as many
% duplicates as required; an empty file name is expanded to duplicates of
% the empty string
n_par_files = numel(spe_file_out); % get nr par files from nr spe files
if isempty(par_file) || (isstring(par_file)&&par_file.strlength()==0)
    % det_par_file indicates if the relevant element represents a filename
    % here it is false as the contents are empty
    % the single value is converted to a cell of empty chars, one per spe
    det_par_file = false(n_par_files,1);
    par_file_out = repmat({''},n_par_files,1);
elseif istext(par_file) 
    % a single text string has been provided
    % det_par_file indicates that all the pare_file_outs will be filenames
    % the single string is converted to a cell of repeated values
    det_par_file = true(n_par_files,1);
    par_file_out = repmat({strtrim(par_file)},n_par_files,1);
elseif isstruct(par_file) && isscalar(par_file)
    % a single struct has been provided
    % det_par_file is false for all spes as a filename has not been
    % provided. The struct is repeated one for each spe
    det_par_file = false(n_par_files,1);
    % the efficiency of this presumes that copy on write will mean that
    % only one copy of the struct will actually be in memory
    par_file_out = repmat({ par_file },n_par_files,1);
elseif iscell(par_file) 
    if numel(par_file) == 1 
        if istext(par_file{1})
            % cell array with single text element has been provided
            % par file out is filled with this single element
            par_file_out = repmat({par_file{1}},n_par_files,1);
            det_par_file = true(n_par_files,1);
        elseif isstruct(par_file{1})
            % cell array with single struct element has been provided
            % par file out is filled with this single element
            det_par_file = true(n_par_files,1);
            % the efficiency of this presumes that copy on write will mean that
            % only one copy of the struct will actually be in memory
            par_file_out = repmat({strtrim(par_file{1})},n_par_files,1);
        else
            error('HORACE:gen_sqw_check_files:invalid_argument', ...
                  'wrong type of contents of cell of one par file');
        end
    elseif numel(par_file) == n_par_files
        if cellfun(@istext,par_file)
            % cell array with text element == nr spe files has been provided
            % use it as is trimmed
            par_file_out = cellfun(@strtrim,par_file,'UniformOutput',false);            
            det_par_file = true(n_par_files,1);
        elseif cellfun(@isstruct,par_file)
            % cell array with N struct elements has been provided
            % par file out is filled with these elements
            det_par_file = true(n_par_files,1);
            % all elements copied
            % this may not be memory efficient 
            par_file_out = par_file; 
        else
            error('HORACE:gen_sqw_check_files:invalid_argument', ...
                  'wrong type of contents of cell of N par files');
        end
    else
        error('HORACE:gen_sqw_check_files:invalid_argument', ...
                  'cell array of par files must be all filenames or all structs');
    end
else
    % other possible inputs are errors
    error('HORACE:algorithms:invalid_argument', ...
          'not acceptable input format for par files');
end

% define the fields for a .par struct
pf = {'filename','filepath','group','x2','phi','azim','width','height'};

% Check the par file names and take copies (copy or struct filename) for
% the name clash check following
par_file_names = cell(n_par_files,1);
for ii=1:n_par_files
    pfile = par_file_out{ii};
    if ~isempty(pfile)
    % parameter file item has been given        
        % if the .par file name has been input, check for existence
        if det_par_file(ii)
            % Check par file has legal extension and exists
            [~,~,ext]=fileparts(par_file_out{ii});
            if any(strcmpi(ext,[ext_horace,'.spe']))
                error('HORACE:algorithms:invalid_argument',...
                    ['Detector parameter files must not have the reserved extension: "%s". ',...
                    '''. Check the file is .par type and rename.'],ext);
            end
            if ~exist(par_file_out{ii},'file')
                error('HORACE:algorithms:invalid_argument',...
                    'Detector parameter file "%s" not found',par_file_out{ii});
            end
            par_file_names{ii} = par_file_out{ii};
            
        % if a struct has been input, extract the filename after checking
        % the correct fields are present
        else
            if ~all(isfield(par_file_out{ii},pf))
                error('HORACE:algorithms:invalid_argument',...
                    'Detector parameter information provided as input structure must be in Horace par_file format');
            end
            par_file_names{ii} = par_file_out{ii}.filename;
            % NB existence of this filename is not checked; the struct
            % filenames do not have credence. But for consistency they are
            % checked below for name clashes
        end
    % no parameter file name has been given
    else
        par_file_out{ii} = '';
        par_file_names{ii} = '';
    end
end

% Check sqw file
% ---------------
if ~isempty(sqw_file) % we may not want to write a file and return an object instead
    [ok,sqw_exist,sqw_file_out,mess] = check_file_writable(sqw_file,require_sqw_exist);
    if ~ok
        % replace possible issues with \ in filepath
        mess = replace(mess,'\','/');
        error('HORACE:algorithms:runtime_error',...
            mess);
    end
else
    if require_sqw_exist
       error('HORACE:algorithms:runtime_error',...        
           'sqw file existense requested but the actual sqw file name is empty');
    end
    sqw_file_out = '';
end
%See above (RAE)


% Check that spe, par and sqw file names do not clash
% ---------------------------------------------------
if any(strcmpi(sqw_file_out,spe_file_out)) && ~isempty(sqw_file_out)
    error('HORACE:algorithms:invalid_argument',...
        'Output sqw file name %s matches one of the input spe file names',sqw_file_out);
end


for ii=1:numel(par_file_out)
    if ~isempty(par_file_names{ii})
        for jj=1:numel(spe_file_out)
            if any(strcmpi(par_file_names{ii},spe_file_out{jj}))
                error('HORACE:algorithms:invalid_argument',...
                    'Detector parameter file name %s matches one of the input spe file names',par_file_names{ii});
            end
        end
        if strcmpi(par_file_names{ii},sqw_file_out)
            error('HORACE:algorithms:invalid_argument',...
                'Detector parameter file name %s and output sqw file name match',par_file_names{ii});
        end
    end
end


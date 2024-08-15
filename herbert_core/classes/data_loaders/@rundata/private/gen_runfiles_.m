function [runfiles,file_exist,replicated_files] = gen_runfiles_(name_of_class,spe_files,...
    varargin)
% Returns array of rundata objects created by the input arguments.
%
%   >> [runfiles_list,file_exist] = gen_runfiles(spe_file,[par_file],arg1,arg2,...)
%
% Input:
% ------
%   name_of_class   string with the name of the classes to generate.
%                   Classes should support rundata interface
%
%   spe_file       Full file name of any kind of supported "spe" file
%                  e.g. original ASCII spe file, nxspe file etc.
%                  Character string or cell array of character strings for
%                  more than one file
%^1 par_file       [Optional] full file name of detector parameter file
%                  i.e. Tobyfit format detector parameter file. Will override
%                  any detector information in the "spe" files
%
% Additional information can be included in the rundata objects, or override
% if the fields are in the rundata object as follows:
%
%^1 efix            Fixed energy (meV)   [scalar or vector length nfile] ^1
%   emode           Direct geometry=1, indirect geometry=2
%^1 lattice         The instance of oriented lattice object or
%                   array of such objects
%  instrument       the instance or array of instruments
%  sample           the instance or array of samples
%
% additional control keywords could modify the behaviour of the routine, namely:
%  -allow_missing   - if such keyword is present, routine allows
%                     some or all spe files to be missing. resulting
%                     rundata class would contain runfile with undefined
%                     loader. Par file(s) if provided, still have always be
%                     defined
% -check_validity   - if present, check if the generated runfiles are
%                     valid, i.e. can be used for transformation
% -replicate        - if present, some input spe files may be replicated
%                     Together with 'parallel' option, modifies the list
%                     of the input files to ensure each parallel worker
%                     have its own version of replicated file.
%
%
% Output:
% -------
% runfiles      -- Array of rundata objects
% file_exist    -- boolean array  containing true for files which were found
%                  and false for which have been not. runfiles list
%                  would then contain members, which do not have loader
%                  defined. Missing files are allowed only if -allow_missing
%                  option is present as input
% replicated_files
%               -- list of file names containing the names of files which
%                  have been replicated to provide each parallel worker
%                   with its own version of spe file.
%
%
% Notes:
% ^1    This parameter is optional for some formats of spe files. If
%       provided, overrides the information contained in the the "spe" file.

%
%
%
replicated_files = {};
control_keys = {'-allow_missing','-check_validity','-replicate'};
[ok,mess,allow_missing,check_validity,replicate,params]=parse_char_options(varargin,control_keys);
if ~ok
    error('HERBERT:rundata:invalid_argument',mess);
end

% Input files
% -----------
% Check spe files
if ischar(spe_files) &&  size(spe_files,1)==1
    spe_files=cellstr(spe_files);
elseif isempty(spe_files) && allow_missing
    spe_files = cell(1,1);
elseif ~(iscellstr(spe_files)||isstring(spe_files))
    if ~allow_missing && iscell(spe_files)
        error('HERBERT:rundata:invalid_argument',...
            'spe file input must be a single file name or cell array of file names')
    end
end
n_spe_files = numel(spe_files);
%
if replicate
    parallel = config_store.instance().get_value('hpc_config','build_sqw_in_parallel');
    if parallel
        n_workers = config_store.instance().get_value('parallel_config','parallel_workers_number');
        % if files get replicated and this happens in parallel, check
        % if each worker have its own version of source file. Do this in
        % gen_sqw_files_job as algorithm for replication should coincide
        % with algorithm for splitting sqw files between workers.
        [spe_files,replicated_files] = gen_sqw_files_job.generate_sources_for_replication(spe_files,n_workers);
    end
end

ll = config_store.instance().get_value('hor_config','log_level');
if ll>0 && n_spe_files > 5
    print_progress_dots = true;
else
    print_progress_dots = false;
end
if print_progress_dots
    fprintf('*** Constructing %d rundata objects\n',n_spe_files);
end

% Check if second parameter is a par file or list of par files and
% remove par_files variable from the list of input parameters;
if nargin>1
    parfile_is_det = false(n_spe_files,1); % not a detpar structure
    if ischar(params{1}) && size(params{1},1)==1    % single par file provided as input
        par_files = repmat({params{1}},n_spe_files,1);    % cell array with one character array
    elseif iscellstr(params{1})   % list of par files provided
        if numel(params{1})==1
            par_files = repmat({params{1}{1}},n_spe_files,1);
        elseif numel(params{1})==n_spe_files
            par_files = params{1};
        else
            error('HERBERT:gen_runfiles:invalid_argument', ...
                'number of par_files is not 1 or the number of spe_files');
        end
    elseif isempty(params{1})     % empty par file definition provided
        par_files = {};
    else
        par_files = params{1};
        if ~iscell(par_files)
            if numel(par_files)==1
                a = repmat({par_files},n_spe_files,1);
                par_files = a;
            elseif numel(par_files)==n_spe_files
                par_files = num2cell(par_files);
            elseif isa(par_files,'double')
                par_files = repmat({par_files},n_spe_files,1); % array form of detpar - further checks will be done in the isdetpar call below
            else
                error('HERBERT:rundata:gen_runfiles', ...
                    'number of input par_files not 1 or number of spe files');
            end
        else
            if numel(par_files)==1
                par_files = repmat({par_files{1}},n_spe_files,1);
            elseif numel(par_files)~=n_spe_files
                error('HERBERT:rundata:gen_runfiles', ...
                    'number of input par_files not 1 or number of spe files');
            end
        end
        for ii=1:numel(par_files)
            [is,pfiles] = isdetpar(par_files{ii}); % will throw if array in wrong format
            if is % detector's structure or det array is provided
                parfile_is_det(ii) = true;
                par_files{ii} = pfiles;
            end
        end
    end
    params = params(2:end);
else
    par_files = {};
end

% Check number of par files is one, no, or matches the number of spe files
if ~(numel(par_files)==1 || numel(par_files)==numel(spe_files) || numel(par_files) == 0)
    error('HERBERT:rundata:invalid_argument',...
        'par files list should be empty, have one par file or number of par files should be equal to the number of spe files');
end

% Check if all requested par files exist:
for ii=1:numel(par_files)
    if ~parfile_is_det(ii)
        file=check_file_exist(par_files{ii},{'.par','.nxspe'});
        if isempty(file)
            error('HERBERT:rundata:invalid_argument',...
                ' par file %s specified but can not be found',file);
        end
    end
end

% Remaining parameters names list:
parameter_nams={'efix','emode','lattice','instrument','sample'};
if numel(params)>2 && isnumeric(params{3}) && rem(numel(params{3}),3)==0 % old format call
    % instead of lattice, one have long row of the lattice and goniometer
    % parameters.
    is_present = cellfun(@(x)isa(x,'IX_inst')||isa(x,'IX_samp'),params);
    if any(is_present)
        inst_samp = params(is_present);
    else
        inst_samp = {};
    end
    params = params(~is_present);
    lat = convert_old_input_to_lat(params{3:end});
    params = [params(1:2),{lat},inst_samp];
end


% Check other parameters
% ----------------------
if numel(spe_files)==1 && isempty(spe_files{1})
    if numel(params)>0
        n_files = numel(params{1});
        spe_files = cell(1,n_files);
        spe_files = cellfun(@(x)'',spe_files,'UniformOutput',false);
    else
        n_files = 1;
    end
else
    n_files       = numel(spe_files);
end

n_dfnd_params = numel(params);
if n_dfnd_params>4 % sample provided
    default_sample = arrayfun(@(x)(isa(x,'IX_null_sample')),params{5});
    if all(default_sample) % ignore it. Default sample is already on rundata,
        % and was set from lattice. Setting it again will break rundata
        % TODO: merge IX_samp and oriented_lattice
        n_dfnd_params = 4;
        params = params(1:4);
        parameter_nams = parameter_nams(1:4);
    end
end
if n_dfnd_params>3 && isa(params{4},'IX_inst') % instrument provided
    default_inst = arrayfun(@(x)(isa(x,'IX_null_inst')),params{4});
    if all(default_inst) % some instrument may have already been set on rundata
        % so better to ignore them here. (not happens currently but let's do it for consistence)
        n_dfnd_params = n_dfnd_params - 1;
        params = [params(1:3),params(5:end)];
        parameter_nams = [parameter_nams(1:3),parameter_nams(5:end)];
    end
end

args=cell(1,n_dfnd_params);
emode = params{2};
emode = emode(1);
% let's try to establish if efix range is provided for indirect instrument
if emode == 2
    n_det_efix_guess = 1;
    e_fix = params{1};
    if numel(e_fix) > 1
        if size(e_fix,2) == n_files && size(e_fix,1) ~= n_files
            e_fix = e_fix';
            params{1} = e_fix;
        end
        n_det_efix_guess = size(e_fix,2);
    end
end

% Transform all arrays with one dimension of n_files into cell arrays
for i=1:n_dfnd_params
    val = params{i};
    name= parameter_nams{i};
    if emode == 2 && strcmpi(name,'efix')
        if n_det_efix_guess >1
            args{i} = spread_vector(val,n_files,n_det_efix_guess,parameter_nams{i});
        else
            args{i} = spread_scalar(val,n_files,parameter_nams{i});
        end
    else
        args{i} = spread_scalar(val,n_files,parameter_nams{i});
    end
end
if numel(args) < numel(parameter_nams)
    parameter_nams = parameter_nams(1:numel(args));
end
% Make structure array with parameter names as fields and args as values
struct_names_and_vals=[parameter_nams;args];
dfnd_params = struct(struct_names_and_vals{:});



% Create rundata objects
% ----------------------
runfiles  = cell(1,n_files);
for i=1:n_files
    runfiles{i} = feval(name_of_class);
end
%runfiles = cellfun(@()(feval(name_of_class)),runfiles,'UniformOutput',false);

file_exist = true(n_files,1);

% define parameters for the progress bar displaying the progress of objects construction.
dot_string_length = 0;
max_dot_string_length = 50;
% Do we build runfiles from one, multiple or no par files?
if isempty(par_files)
    for i=1:n_files
        [runfiles{i},file_exist(i)] = init_runfile_no_par(runfiles{i},...
            spe_files{i},dfnd_params(i),allow_missing);
        dot_string_length = print_progress(print_progress_dots,dot_string_length,max_dot_string_length);
    end
elseif numel(par_files)==1
    [runfiles{1},file_exist(1)]= init_runfile_with_par(runfiles{1},spe_files{1},...
        par_files{1},'',dfnd_params(1),allow_missing,parfile_is_det);
    if file_exist(1) &&  ~runfiles{1}.isvalid
        runfiles{1} = runfiles{1}.check_combo_arg();
        if ~runfiles{1}.isvalid
            error('HERBERT:gen_runfiles:invalid_argument',runfiles{1}.reason_for_invalid)
        end
    end
    dot_string_length = print_progress(print_progress_dots,dot_string_length,max_dot_string_length);
    % Save time on multiple load of the same par into memory by reading it just once
    %CM:will probably have to get rid of this
    if n_files>1
        [par,runfiles{1}] = get_par(runfiles{1}); %CM:get_par()
    end
    for i=2:n_files
        [runfiles{i},file_exist(i)]= init_runfile_with_par(runfiles{i},...
            spe_files{i},par_files{1},par,dfnd_params(i),allow_missing,parfile_is_det);
        if file_exist(i) &&  ~runfiles{i}.isvalid
            runfiles{i} = runfiles{i}.check_combo_arg();
            if ~runfiles{i}.isvalid
                error('HERBERT:gen_runfiles:invalid_argument',runfiles{i}.reason_for_invalid)
            end
        end
        dot_string_length = print_progress(print_progress_dots,dot_string_length,max_dot_string_length);
    end
else   % multiple par and spe files;
    for i=1:n_files
        [runfiles{i},file_exist(i)]= init_runfile_with_par(runfiles{i},...
            spe_files{i},par_files{i},'',dfnd_params(i),allow_missing,parfile_is_det(i));
        [~,runfiles{i}] = get_par(runfiles{i});
        if file_exist(i) && ~runfiles{i}.isvalid
            runfiles{i} = runfiles{i}.check_combo_arg();
            if ~runfiles{i}.isvalid
                error('HERBERT:gen_runfiles:invalid_argument',runfiles{i}.reason_for_invalid)
            end
        end
        dot_string_length = print_progress(print_progress_dots,dot_string_length,max_dot_string_length);
    end
end

% Check if all information necessary to define the run is present
if check_validity
    for i=1:n_files
        if file_exist(i)
            if ~runfiles{i}.isvalid
                runfiles{i} = runfiles{i}.check_combo_arg();
                if ~runfiles{i}.isvalid
                    error('HERBERT:gen_runfiles:invalid_argument', ...
                        ' The run data for data file %s are not fully defined: %s', ...
                        runfiles{i}.data_file_name,runfiles{i}.reason_for_invalid);
                end
            end
        end
    end
end
if print_progress_dots
    if dot_string_length ~= 0
        fprintf('\n');
    end
    fprintf('*** Finished constructuion of %d %s objects\n',n_files,name_of_class);
end

function log_length = print_progress(do_print,log_length,max_length)
% print progress log.
% Inputs:
% do_print   --  bulean. If true, progress log is printed and if false it
%                does not.
% log_length --  The lengh of already printed dot string.
% max_length --  Maximal length of dot string requested. If log_length
%                reaches this value, CR is send to stdout.
%
% Returns:
% log_length  --  the number of dots printed in current row after routine
%                 has been called. Either log_length or log_length+1
%
if ~do_print
    return;
end
fprintf('.');
log_length= log_length + 1;
if log_length >= max_length
    fprintf('\n');
    log_length  = 0;
end

function [runfile,file_found] = init_runfile_no_par(runfile,spe_file_name,param,allow_missing)
% init runfile in the case of no par file is present
file_found = true;
if allow_missing
    if check_file_exist(spe_file_name)
        runfile = runfile.init(spe_file_name,param);
    else
        file_found = false;
        par_fields = fieldnames(param);
        for i=1:numel(par_fields)
            field = par_fields{i};
            runfile.(field) = param.(field);
        end
    end
else
    runfile = runfile.init(spe_file_name,param);
end
%
function [runfile,file_found] = init_runfile_with_par(runfile,spe_file_name,...
    par_file,par_data,param,allow_missing,par_is_det)
% init runfile in the case of par file being present
file_found = true;
if allow_missing
    if check_file_exist(spe_file_name)
        if par_is_det
            runfile = runfile.init(spe_file_name,param);
            runfile.det_par = par_file;
        else
            runfile = runfile.init(spe_file_name,par_file,param);
        end
    else
        file_found = false;
        if par_is_det
            runfile.det_par = par_file;
        else
            runfile.par_file_name = par_file;
        end
        par_fields = fieldnames(param);
        for i=1:numel(par_fields)
            field = par_fields{i};
            runfile.(field) = param.(field);
        end
    end
else
    file_found = check_file_exist(spe_file_name);
    if par_is_det
        runfile = runfile.init(spe_file_name,param);
        runfile.det_par = par_file;
    else
        runfile = runfile.init(spe_file_name,par_file,param);
    end
end
%
if ~isempty(par_data)
    runfile.det_par = par_data;
end

function [is,input]=isdetpar(input)
%ISDETPAR for a scalar argument input
% check if it is a struct. If so and the struct is a detpar,
% return true for output argument is, else false.
% If it is not a struct,do the same for a numeric vector which may
% represent a detpar.
%
% Input
% -----
% input - scalar which may or may not
%         be a detpar or a numeric detpar vector
%
% Output
% ------
% is    - logical scalar which is true or false according as its
%         corresponding input represents a detpar
% input - the input argument "input"; if it was a numeric vector version of a detpar, it
%         is converted to a detpar struct
%------------------------------------------------------------------------

% case : input is not a struct
if ~isstruct(input)
    % check if it is a numeric vector convertible to a struct
    if isnumeric(input) && isvector(input(:,1)) && isvector(input(:,2))
        % will throw if conversion is impossible
        % otherwise convert to detpar struct
        input = get_hor_format(input,'mem_par_file');
        is = true;
        return
    else
        is = false;
        % input is unaltered; should not be processed if "is" is false
    end
    return
end
% case : input is a struct, check if fieldnames correspond to a detpar
detpar_fields = {'group','x2','phi','azim','width','height'};
fields = fieldnames(input);
if all(ismember(detpar_fields,fields))
    is = true;
else
    is = false;
end
%{
% this was going to process an array  of input but now prefer to process a
% scalar input
if ~iscell(input)
    input = {input};
end
is = false(numel(input),1);
for ii=1:numel(input)
    inp = input{ii};
    if ~isstruct(inp)
        if isnumeric(inp) && isvector(inp(:,1)) && isvector(inp(:,2))
            % will throw if conversion is impossible
            inp = get_hor_format(inp,'mem_par_file');
            input{ii} = inp;
            is{ii} = true;
            continue;
        end
        return
    end
    detpar_fields = {'group','x2','phi','azim','width','height'};
    fields = fieldnames(inp);
    if all(ismember(detpar_fields,fields))
        is{ii} = true;
    end
end
%}

function res = spread_scalar(val,n_files,name)
if numel(val)==n_files
    res=num2cell(val(:)');  % 1 x nfiles cell array
elseif numel(val)==1
    if isobject(val)
        res = num2cell(repmat(val,1,n_files));
    else
        res=num2cell(val*ones(1,n_files));  % 1 x nfiles cell array
    end
else
    error('HERBERT:gen_runfiles:invalid_argument',...
        'parameter %s must be a single value or a vector of %d values',name,n_files);
end

function res = spread_vector(val,n_files,n_components,name)
if numel(size(val))==2 && all(size(val)==[n_files,n_components])
    res=num2cell(val,2)';   % 1 x nfiles cell array
elseif numel(val)==n_components
    res=num2cell(repmat(val(:)',[n_files,1]),2)';   % 1 x nfiles cell array containing n_components vectors
else
    error('HERBERT:gen_runfiles:invalid_argument',...
        'parameter %s must be a %d-element vector or a [%d x %d] array of doubles',...
        name,n_components,n_files,n_components);
end


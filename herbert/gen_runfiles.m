function runfiles = gen_runfiles(spe_files,varargin)
% Returns array of rundata objects created by the input arguments.
%
%   >> runfiles_list = gen_runfiles(spe_file,[par_file],arg1,arg2,...)
%
% Input:
% ------
%   spe_file        Full file name of any kind of supported "spe" file
%                  e.g. original ASCII spe file, nxspe file etc.
%                   Character string or cell array of character strings for
%                  more than one file
%^1 par_file        [Optional] full file name of detector parameter file
%                  i.e. Tobyfit format detector parameter file. Will override
%                  any detector inofmration in the "spe" files 
%
% Addtional information can be included in the rundata objects, or override
% if the fields are in the rundata object as follows:
%
%^1 efix            Fixed energy (meV)   [scalar or vector length nfile] ^1
%   emode           Direct geometry=1, indirect geometry=2
%^1 alatt           Lattice parameters (Ang^-1)  [vector length 3, or array size [nfile,3]]
%^1 angldeg         Lattice angles (deg)         [vector length 3, or array size [nfile,3]]
%   u               First vector defining scattering plane (r.l.u.)  [vector length 3, or array size [nfile,3]]
%   v               Second vector defining scattering plane (r.l.u.) [vector length 3, or array size [nfile,3]]
%^1 psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%^2 omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%^2 dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%^2 gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%^2 gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% Output:
% -------
%   runfiles        Array of rundata objects
%
% Notes:
% ^1    This parameter is optional for some formats of spe files. If
%       provided, overides the information contained in the the "spe" file.
% ^2    Optional parameter. If absent, the default value defined by
%       is used instead;


% Optional parameters names list
parameter_nams={'efix','emode','alatt','angldeg','u','v','psi','omega','dpsi','gl','gs'};

% Input files
% -----------
% Check spe files
if ischar(spe_files) && ~isempty(spe_files) && size(spe_files,1)==1
    spe_files=cellstr(spe_files);
elseif ~iscellstr(spe_files)
    error('spe file input must be a single file name or cell array of file names')
end

% Check if second parameter is a par file or list of par files;
if nargin>1
    if ischar(varargin{1}) && size(varargin{1},1)==1    % single par file provided as input
        par_files = varargin(1);    % cell array with one character array
        variables_start = 2;
    elseif iscellstr(varargin{1})   % list of par files provided
        par_files = varargin{1};
        variables_start = 2;
    elseif isempty(varargin{1})     % empty par file definition provided
        par_files = {};
        variables_start = 2;
    end
else
    par_files = {};
    variables_start = 1;
end

% Check number of par files is one, or matches the number of spe files
if ~(numel(par_files)==1 || numel(par_files)==numel(spe_files))
    error('GEN_RUNFILES:invalid_argument',' number of par files must be one or equal to the number of spe files');
end

% Check if all requested par files exist:
for i=1:numel(par_files)
    file=check_file_exist(par_files{i},'.par');
    if isempty(file)
        error('GEN_RUNFILES:invalid_argument',' par file %s specified but can not be found',file);
    end
end


% Check other parameters 
% ----------------------
n_files       = numel(spe_files);
n_dfnd_params = nargin-variables_start;
args=cell(1,n_dfnd_params);

% Transform all arrays with one dimension of n_files into cell arrays
for i=1:n_dfnd_params
    val = varargin{variables_start+i-1};
    if ismember(parameter_nams{i},{'alatt','angldeg','u','v'})
        if numel(size(val))==2 && all(size(val)==[n_files,3])
            args{i}=num2cell(val,2)';   % 1 x nfiles cell array
        elseif numel(val)==3
            args{i}=num2cell(repmat(val(:)',[n_files,1]),2)';   % 1 x nfiles cell array
        else
            error('GEN_RUNFILES:invalid_argument','parameter %s must be a 3-element vector or a [%d x 3] array of doubles',parameter_nams{i},n_files);
        end
    else
        if numel(val)==n_files
            args{i}=num2cell(val(:)');  % 1 x nfiles cell array
        elseif numel(val)==1
            args{i}=num2cell(val*ones(1,n_files));  % 1 x nfiles cell array
        else
            error('GEN_RUNFILES:invalid_argument','parameter %s must be a single value or a vector of %d values',parameter_nams{i},n_files);
        end
    end
end

% Make structure array with parameter names as fields and args as values
% Put crystal type on the end as well
struct_names_and_vals=[[parameter_nams,'is_crystal'];[args,{num2cell(true(1,n_files))}]];
dfnd_params = struct(struct_names_and_vals{:});


% Create rundata objects
% ----------------------
runfiles = cell(1,n_files);

% Do we build runfiles from one, multiple or no par files?
if isempty(par_files)
    for i=1:n_files
        runfiles{i}=rundata(spe_files{i},dfnd_params(i));
    end
elseif numel(par_files)==1
    runfiles{1}=rundata(spe_files{1},par_files{1},dfnd_params(1));
    % Save time on multiple load of the same par into memory by reading it just once
    [par,runfiles{1}] = get_par(runfiles{1});
    for i=2:n_files
        runfiles{i}=runfiles{1};
        runfiles{i}.data_file_name=spe_files{i};
        runfiles{i}.par_file_name =par_files{1};
        runfiles{i}=rundata(runfiles{i},dfnd_params(i));
    end
else   % multiple par and spe files;
    for i=1:n_files
        runfiles{i}=rundata(spe_files{i},par_files{i},dfnd_params(i));
    end
end

% Check if all information necessary to define the run is present
for i=1:n_files
    undefined = check_run_defined(runfiles{i});
    if undefined==2
        error('GEN_RUNFILES:invalid_argument',' the run data for data file %s are not fully defined',runfiles{i}.file_name);
    end
end

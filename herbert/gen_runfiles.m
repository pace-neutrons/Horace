function runfiles_list = gen_runfiles(spe_files,varargin)
% function returns array of runfiles, from the list of the files,
% describing the results of inelastic experiment (spe files in particular) 
% and the list of additional parameters, which describe each experiment and
% modify/complement the information, in the files 
%
%Usage:
%>>runfiles_list = gen_runfiles(spe_file,[par_file],... varargin)
%
% 
%   spe_file        Full file name of any kind of "spe" file e.g. the file 
%                   containing signal and error as function of detector 
%                   number and energy transfer 
%                   -- character string or cell array of
%                    character strings for more than one file
%   [par_file]       Full file name of detector parameter file (Tobyfit
%                    format)^1
% where varargin can contain the followind
%   alatt           Lattice parameters (Ang^-1)  [row or column  vector]^1
%   angdeg          Lattice angles (deg)         [row or column vector]^1
%   efix            Fixed energy (meV)   [scalar or vector length nfile]^1
%   psi             Angle of u w.r.t. ki (deg) [scalar or vector length
%                                                                  nfile]^1
%   omega          Angle of axis of small goniometer arc
%                  w.r.t. notional u (deg) [scalar or vector length
%                  nfile]^2
%   dpsi           Correction to psi (deg)            [scalar or vector
%                  length nfile]^2
%   gl             Large goniometer arc angle (deg)   [scalar or vector
%                  length nfile]^2
%   gs             Small goniometer arc angle (deg)   [scalar or vector
%                  length nfile]^2
% NOTES:
% ^1               this parameter is optional for some formats of spe files
%                  if provided, owerides the information, containing in
%                  the 'spe' file, if any present
% ^2               optional, if absent, the value defined by rundata_config
%                  is used instead;
%
% optional parameters names list
parameter_nams={'alatt','angldeg','efix','psi','omega','dpsi','gl','gs'};
% Input files
if ischar(spe_files) && numel(spe_files)==1
    spe_files=cellstr(spe_files);
elseif ~iscellstr(spe_files)
    error('spe file input must be a single file name or cell array of file names')
end
n_files       = numel(spe_files);
runfiles_list = cell(1,n_files);
%
% check if second parameter is par file or list of par files;
par_files='';
variables_start = 1;
if nargin>1 && ischar(varargin{1}) && size(varargin{1},1)==1
    par_files = {varargin{1}};
    variables_start = 2;
elseif iscellstr(varargin{1})
    par_files = varargin{1};
    variables_start = 2;
end
% chek if all requested par files exist:
for i=1:numel(par_files)
    file=check_file_exist(par_files{i},'.par');
    if isempty(file)
        error('GEN_RUNFILES:invalid_argument',' par file %s specified but can not be found',file);
    end
end
% check other parameters and transform all arrays with one dimension of
% n_files into the cell array
n_def_params = nargin-variables_start;
args=cell(1,n_def_params);
for i=1:n_def_params
    args{i} = varargin{variables_start+i-1};
    if ismember(parameter_nams{i},{'alatt','angldeg'})
        if iscell(varargin{i})
           error('GEN_RUNFILES:not_implemebter','lattice parameters has to be a 3-element vectors but got cellarray');
        else
            if numel(args{i})==3*n_files
                lat_par_c = cell(1,n_files);
                lat_par   = args{i};
                if size(lat_par,2)==3
                    lat_par = lat_par';
                end
                for j=1:n_files
                    lat_par_c{i} = lat_par(:,i);
                end
            elseif numel(args{i})~=3
               error('GEN_RUNFILES:invalid_argument','lattice parameters have 3-element vectors or 3*n_files array of doubles');    
            end
        end
    else
        if numel(args{i})==n_files
            par_c = cell(1,n_files);
            par   = args{i};
            for j=1:n_files
                    par_c{j} = par(j);
            end
            args{i}=par_c; 
        else
            if numel(args{i})~=1
                error('GEN_RUNFILES:invalid_argument','a parameter has to be either sinle value or vector of %d values',n_files);    
            end
        end

    end
end
% Process other variables:

def_params   =  cell(1,n_files);
for i=1:n_files;
    def_params{i}=struct();
end
% set arrays of run parameters:
for i=1:n_def_params
    arg_i = args{i};
    if iscell(arg_i)
       if numel(arg_i)~=n_files
          error('GEN_RUNFILES:invalid_argument', ...
          ' argument %s is a cellarray, but the numer of its elements %d not equal to number of files %d',...
            parameter_nams{i},numel(arg_i),n_files);
       end
        for j=1:n_files
            def_params{j}.(parameter_nams{i})=arg_i{j};
        end   
    else        
      for j=1:n_files
            def_params{j}.(parameter_nams{i})=arg_i;
      end              
    end
end

% do we build runfiles from 1, no or multiple par files?
if isempty(par_files)
    for i=1:n_files
        runfiles_list{i}=rundata(spe_files{i},def_params{i});
    end
elseif numel(par_files)==1
    runfiles_list{1}=rundata(spe_files{1},par_files{1},def_params{1});
    % save time on multiple load the same par into memory by reading it
    % once
    [par,runfiles_list{1}] = get_par(runfiles_list{1});
    for i=2:n_files
        runfiles_list{i}=rundata(runfiles_list{1},def_params{i});
    end
else   % multiple par and spe files;
    for i=1:n_files
        runfiles_list{i}=rundata(spe_files{i},par_files{i},def_params{i});
    end       
end
%
% check if all information necessary to define the run is present
%
for i=1:n_files
    undefined  = check_run_defined(runfiles_list{i});
    if undefined==2
        error('GEN_RUNFILES:invalid_argument',' the run data for data file %s are not fully defined',runfiles_list{i}.file_name);
    end
end





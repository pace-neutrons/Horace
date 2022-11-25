function obj = eval_and_set_instr_fun_with_energy_(obj,instrfun,varargin)
% werid hack, which allows to evaluate instrument function with
% parameters fun_par and first parameter -- incident energy on
% instrument container
%
% Inputs:
% intrfun -- function handle evaluating to an instrument
%            first parameter of this function must be incident
%            energy
%varargin -- other parameters of this function
%
% Returns:
% obj    -- experiment info object with instrument, modyfied by
%           evaluating instrfun on every run in the Experiment
% s

if ~isa(instrfun,'function_handle')
    error('HORACE:Experiment:invalid_argument',...
        'The first argument of this function should be instrument function. It is %s', ...
        class(instrfun))
end
if nargin == 3 && iscell(varargin{1}) % function parameters are provided as size(params) = [n_runs,n_pars]
    [max_narg,n_argi]= size(varargin{1});
    arg_expanded_to_cell = true;
else
    n_argi = size(varargin,1);
    narg_in_par = cellfun(@num_par_in_arg,varargin);
    max_narg = max(narg_in_par);
    arg_expanded_to_cell = false;
end


if max_narg == obj.n_runs
    eval_single_par = false;
elseif max_narg == 1
    eval_single_par = true;
else
    error('HORACE:Experiment:invalid_argument',...
        'Number of function  parameters (%d) is not equal to number of runs (%d), contributing to experiment',...
        max_narg,obj.n_runs);
end
if eval_single_par
    if arg_expanded_to_cell
        fun_par = varargin{1};
    else
        fun_par = varargin;
    end
else
    if arg_expanded_to_cell
        fun_par = varargin{1};
    else % arg consists of vectors of size 1 or n_runs
        fun_par = cell(max_narg,n_argi);
        for i=1:n_argi
            if size(varargin{i},1) == 1
                for j=1:max_narg
                    fun_par{j,i} = varargin{i};
                end
            elseif size(varargin{i},1) == max_narg
                fun_par = varargin{1};
                arg_i = varargin{i};
                for j=1:max_narg
                    fun_par{j,i} = arg_i(j);
                end
            else
                error('HORACE:Experiment:invalid_argument',...
                    'Function argument N%d has %d elements, while allowed number is 1 or %d',...
                    i,size(varargin{i},1),max_narg);
            end
        end
    end
end

instr = obj.instruments;
run_data = obj.expdata;

for i=1:obj.n_runs
    efix = run_data(i).efix;
    if eval_single_par
        instr(i) = instrfun(efix,fun_par{1,:});
    else
        instr(i) = instrfun(efix,fun_par{i,:});
    end
end
obj.instruments = instr;

function np = num_par_in_arg(arg)
if isnumeric(arg)
    np = size(arg,1);
else
    np = 1;
end
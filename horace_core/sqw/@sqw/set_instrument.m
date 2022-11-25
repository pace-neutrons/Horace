function obj = set_instrument (obj,instr_or_fun,varargin)
% Change the instrument in an sqw object or array of objects
%
%   >> wout = set_instrument (w, instrument)
%
%   >> wout = set_instrument (w, inst_func, arg1, arg2,...)
%
% EXAMPLES:
%   >> wout = set_instrument (w, instrument);
%   >> wout = set_instrument (w, @maps_instrument, '-efix', 600, 'S')
%
%
% Input:
% -----
%   w               Input sqw object or array of objects
%
%   instrument      Instrument object, or array of instrument objects with
%                  number of elements equal to the number of runs contributing
%                  to the sqw object(s).
%                   If the instrument is any empty object, then the instrument
%                  is set to the empty structure struct().
%
% *OR*
%   inst_func       Function handle to generate instrument object.
%                   The function must be of the form:
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are parameters to be passed to the
%                  instrument definition function (in this case called my_func),
%                  which in this example will be passed as @my_func.
%
%   arg1, arg2,...  Arguments to be provided to the instrument function.
%                  The arguments must be:
%                   - scalars, row vectors (which can be numerical, logical,
%                     structure, cell array or object), or character strings.
%                   - Multiple arguments can be passed, one for each run that
%                     constitutes the sqw object, by having one row per run
%                     i.e
%                       scalar      ---->   column vector (nrun elements)
%                       row vector  ---->   2D array (nrun rows)
%                       string      ---->   cell array of strings
%
%                  Certain arguments win the sqw object can be referred to by
%                  special strings;
%                       '-efix'     ---->   use value of fixed energy in the
%                                           header block of the sqw object
% Output:
% -------
%   wout        Output sqw object with changed instrument

% Original author: T.G.Perring
%

[ok,mess,substitute_efix,argi] = parse_char_options(varargin,{'-efix'});
if ~ok
    error('HORACE:sqw:invalid_argument',mess);
end

% Perform operations
% ==================

if isa(instr_or_fun,'IX_inst')
    % just set instrument provided as input
    obj = set_instr(obj,instr_or_fun);
    return
end
if ~isa(instr_or_fun,'function_handle')
    error('HORACE:sqw:invalid_argument',...
        ['Neither instrument (including IX_null_inst) nor function building instrument is provided as input for the method.\n', ...
        ' Setting instrument as a structure is not allowed any more'])
end
if ~isscalar(instr_or_fun)
    error('HORACE:sqw:invalid_argument',...
        'only one function handle allowed to define instrument')

end
instfunc = instr_or_fun;
instfunc_args=check_function_args(argi{:});
if size(instfunc_args,1)==0
    instrument=instfunc();  % call with no arguments
    if ~isa(instrument,'IX_inst')
        error('HORACE:sqw:invalid_argument',...
            'The instrument definition function does not return an object of class IX_inst')
    end
    obj = set_instr(obj,instrument);
else
    % If none of the arguments match substitution arguments we can
    % evaluate the instrument definition function now
    ninst=size(instfunc_args,1);
    if substitute_efix
        obj = set_instr_func(obj,instfunc,instfunc_args);
    else
        instrument=instfunc(instfunc_args{1,:});
        if ~isa(instrument,'IX_inst')
            error('HORACE:sqw:invalid_argument',...
                'The instrument definition function does not return an object of class IX_inst')
        end
        if ninst>1
            instrument=repmat(instrument,ninst,1);
            for i=2:ninst
                instrument(i)=instfunc(instfunc_args{i,:});
            end
        end
        obj = set_instr(obj,instrument);
    end
end


%--------------------------------------------------------------------------
function obj = set_instr_func(obj,istrfunc,instfunc_args)
%

[set_single,~,n_runs_in_obj]=find_set_mode(obj,instfunc_args(:,1));
n_inst_set = 0;
for i=1:numel(obj)

    if set_single
        obj(i).experiment_info = ...
            obj(i).experiment_info.eval_and_set_instr_fun_with_energy( ...
            istrfunc,instfunc_args{:});
    else
        obj(i).experiment_info = ...
            obj(i).experiment_info.eval_and_set_instr_fun_with_energy( ...
            istrfunc,...
            instfunc_args(n_inst_set+1:n_inst_set+n_runs_in_obj(i),:));

        n_inst_set = n_inst_set+n_runs_in_obj(i);
    end
end

%--------------------------------------------------------------------------
function obj = set_instr(obj,instr)
% Change the instrument
% ---------------------

[set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj,instr);

n_inst_set = 0;
for i=1:numel(obj)
    %
    if set_single
        obj(i).experiment_info = obj(i).experiment_info.set_instrument(instr);
    else
        if set_per_obj
            if isempty(instfunc)
                obj(i).experiment_info = obj(i).experiment_info.set_instrument(instr(i));
            else
                obj(i).experiment_info = obj(i).experiment_info.set_instrument(instr);
            end
        else
            obj(i).experiment_info = obj(i).experiment_info.set_instrument( ...
                instr(n_inst_set+1:n_inst_set+n_runs_in_obj(i)));
            n_inst_set = n_inst_set+n_runs_in_obj(i);
        end
    end
end

%--------------------------------------------------------------------------
function  [set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj,val_to_set)
if ~isempty(val_to_set)
    n_val_to_set = numel(val_to_set);
else
    n_val_to_set = 1;
end
set_per_obj = true;
if n_val_to_set  == 1
    set_single = true;
    n_runs_in_obj = 1;
else
    set_single = false;
    n_runs_in_obj = arrayfun(@(x)x.experiment_info.n_runs,obj);
    if n_val_to_set  == numel(obj)
        set_per_obj = true;
    elseif n_val_to_set == sum(n_runs_in_obj)
        set_per_obj = false;
    else
        error('HORACE:sqw:invalid_argument',...
            'An array of object to set was given but its length does not match the number of runs in (all) the sqw source(s) being altered')
    end
end


%==============================================================================
function argout=check_function_args(varargin)
% Check arguments have one of the permitted forms below
%
%   >> [ok, mess, argout]=check_function_args(arg1,arg2,...)
%
% Input:
% ------
%   arg1,arg2,...   Input arguments
%                  Each argument can be a 2D array with 0,1 or more rows
%                  If more than one row in an argument, then this gives the
%                  number of argument sets.
%
% Output:
% -------
%   ok              =true all OK; =false otherwise
%   mess            Error message if not OK; empty string if OK
%   argout          Cell array of arguments, each row a cell array
%                  with the input arguments
%
% Checks arguments have one of following forms:
%	- scalar, row vector (which can be numerical, logical,
%     structure, cell array or object), or character string
%
%   - Multiple arguments can be passed, one for each run that
%     constitutes the sqw object, by having one row per run
%   	i.e
%       	scalar      ---->   column vector (nrun elements)
%           row vector  ---->   2D array (nrun rows)
%        	string      ---->   cell array of strings
%
% Returns arg=[] if not valid form

narg=numel(varargin);


% Find out how many rows, and check consistency
nr=zeros(1,narg);
nc=zeros(1,narg);
for i=1:narg
    if numel(size(varargin{i}))==2
        nr(i)=size(varargin{i},1);
        nc(i)=size(varargin{i},2);
    else
        error('HORACE:sqw:invalid_argument', ...
            'Check arguments have valid array size');

    end
end
if all(nr==max(nr)|nr<=1)
    nrow=max(nr);
else
    error('HORACE:sqw:invalid_argument', ...
        'If any arguments have more than one row, all such arguments must be the same number of rows');

end

% Now create cell arrays of output arguments
if nrow>1
    argout=cell(nrow,narg);
    for i=1:narg
        if ~iscell(varargin{i})
            if nr(i)==nrow
                argout(:,i)=mat2cell(varargin{i},ones(1,nrow),size(varargin{i},2));
            else
                argout(:,i)=repmat(varargin(i),nrow,1);
            end
        else
            if nr(i)==nrow
                if nc(i)>1
                    argout(:,i)=mat2cell(varargin{i},ones(1,nrow),size(varargin{i},2));
                else
                    argout(:,i)=varargin{i};
                end
            else
                argout(:,i)=repmat(varargin(i),nrow,1);
            end
        end
    end
else
    argout=varargin;
end



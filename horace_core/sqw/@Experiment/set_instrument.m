function   obj = set_instrument(obj,instr_or_fun,varargin)
% add or reset instrument, related to the given experiment class
%
if isa(instr_or_fun,'IX_inst')
    if numel(instr_or_fun) == 1
        obj.instruments.unique_objects = instr_or_fun;
        if obj.instruments.n_runs ~= obj.n_runs
            inst = obj.instruments;
            inst = inst.replicate_runs(obj.n_runs); % will work only for single unique instrument
            obj.instruments = inst;
        end
    else
        inst = obj.instruments;
        if numel(instr_or_fun) ~= inst.n_runs
            error('HORACE:Experiment:invalid_argument',...
                'Multiple instruments (N=%d) provided as input for set_instrument function but the number is not 1 and not equal to the number of runs defined in container (%d)', ...
                numel(instr_or_fun),inst.n_runs)
        end
        n_runs = inst.n_runs;
        for i=1:n_runs
            inst(i) = instr_or_fun(i);
        end
        obj.instruments = inst;
    end
elseif isa(instr_or_fun,'unique_objects_container') && strcmp(instr_or_fun.baseclass,'IX_inst')
    if instr_or_fun.n_runs ~= obj.n_runs
        if instr_or_fun.n_runs == 1
            instr_or_fun = instr_or_fun.replicate_runs(obj.n_runs);
        else
            error('HORACE:Experiment:invalid_argument',...
                'Attempt to set instrument as container with %d unique objects, but Experiment contains %d runs so only 1 unique or %d different instruments allowed in the container', ...
                obj.n_runs,instr_or_fun.n_runs,obj.n_runs)
        end
    end
    obj.instruments = instr_or_fun;

elseif isa(instr_or_fun,"function_handle")
    if numel(varargin)==1 && iscell(varargin{1})
        argi = varargin{1};
    else
        argi = varargin;
    end
    istrfun = instr_or_fun;
    [ok,mess,substitute_efix,argi] = parse_char_options(argi,{'-efix'});
    if ~ok
        error('HORACE:sqw:invalid_argument',mess);
    end

    instfunc_args=obj.check_and_expand_function_args(argi{:});
    if size(instfunc_args,1)==0
        instrument=instfunc();  % call with no arguments
        if ~isa(instrument,'IX_inst')
            error('HORACE:sqw:invalid_argument',...
                'The instrument definition function does not return an object of class IX_inst')
        end
        obj = set_instrument(obj,instrument);
    else
        % If none of the arguments match substitution arguments we can
        % evaluate the instrument definition function now
        ninst=size(instfunc_args,1);
        if substitute_efix
            obj = eval_and_set_instr_fun_with_energy_(obj,istrfun,instfunc_args);
        else
            if ninst == 1
                instrument=istrfun(instfunc_args{:});
            else
                instrument=istrfun(instfunc_args{1,:});
            end
            if ~isa(instrument,'IX_inst')
                error('HORACE:sqw:invalid_argument',...
                    'The instrument definition function does not return an object of class IX_inst')
            end
            if ninst>1
                instrument=repmat(instrument,ninst,1);
                for i=2:ninst
                    instrument(i)=istrfun(instfunc_args{i,:});
                end
            end
            obj = set_instrument(obj,instrument);
        end
    end
else
    error('HORACE:Experiment:invalid_argument',...
        'Only IX_inst or function handle which generates an instrument may be provided as input for this function.\nActual input class is: %s', ...
        class(instr_or_fun))
end

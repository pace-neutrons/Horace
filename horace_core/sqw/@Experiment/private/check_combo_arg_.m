function obj = check_combo_arg_(obj)
% verify consistency of Experiment containers
%
% Inputs:
% obj  -- the initialized instance of Experiment obj
%
% Returns:   unchanged object if Experiment components are consistent,
%            Throws HORACE:Experiment:invalid_argument with details of the
%            issue if they are not
nruns = numel(obj.expdata_);
if nruns == 0
    return;
end
mess = '';

if obj.instruments_.n_runs ~= nruns
    if obj.instruments_.n_runs == 1
        obj.instruments_ = obj.instruments_.replicate_runs(nruns);
    else
        mess = sprintf(...
            'Number of instruments: %d is not equal to number of runs: %d; ',...
            obj.instruments_.n_runs,nruns);
    end
end
if obj.samples_.n_runs ~= nruns
    if obj.samples_.n_runs == 1
        obj.samples_ = obj.samples_.replicate_runs(nruns);
    else
        mess = sprintf(...
            '%s\n Number of samples %d is not equal to number of runs: %d; ',...
            mess,obj.samples_.n_runs,nruns);
    end
end
if isempty(obj.runid_map_)
    mess = sprintf('%s\n runid_map is not defined',mess);
else
    if obj.runid_map_.Count ~= nruns
        mess = sprintf(...
            '%s\n Number of elements %d in runid_map is not equal to number of runs: %d; ',...
            mess,obj.runid_map_.Count,nruns);
    else
        ind = obj.runid_map_.values;
        ind  = [ind{:}];
        if any(sort(ind)~=1:nruns)
            mess = sprintf(...
                '%s\n The values in runid_map do not account for every Experiment component; ',...
                mess);
        end
    end
end
if ~isempty(mess)
    error('HORACE:Experiment:invalid_argument',mess);
end
% check if new lattice is defined
% NB unique objects used to reduce check time. Should not be used to
% replace values
new_uni_obj = obj.samples_.expose_unique_objects();
new_lat_def = cellfun(@(x)~isempty(x.alatt),new_uni_obj);
new_ang_def = cellfun(@(x)~isempty(x.angdeg),new_uni_obj);
% if new lattice not defined everywhere
if ~(all(new_lat_def) && all(new_ang_def))
    % if we actually have the old lattice
    if ~isempty(obj.old_lattice_holder_) % try to retrieve old lattice
        one_unique = (obj.old_lattice_holder_.n_unique_objects ==1 && obj.samples_.n_unique_objects == 1);
        if obj.old_lattice_holder_.n_runs == obj.samples.n_runs || one_unique
            % only one unique object so if its lattice was unset then all
            % need changing, don't need to check again
            if one_unique
                uni_source = obj.old_lattice_holder_.unique_objects{1};
                uni_targ  = obj.samples_.unique_objects{1}; % extract the single unique object in the target
                uni_targ.alatt = uni_source.alatt;   % assign the single source lattice to the single target
                uni_targ.angdeg = uni_source.angdeg;
                obj.samples_ = obj.samples_.set_all(uni_targ);            % update all the non-unique target samples with the
                                                        % revised unique target                
            % unspecified number of lattice parameters unset so change what
            % is required
            elseif obj.old_lattice_holder_.n_runs == obj.samples.n_runs
                targ_samp = obj.samples_;
                source_samp = obj.old_lattice_holder_;
                n_runs = obj.samples_.n_runs;
                one_defined = obj.old_lattice_holder_.n_unique_objects ==1;
                the_source = source_samp(1);
                for i=1:n_runs
                    the_samp = targ_samp(i);
                    if ~the_samp.lattice_defined()
                        if one_defined
                            the_samp.alatt = the_source.alatt;
                            the_samp.angdeg = the_source .angdeg;
                        else
                            the_source = source_samp(i);
                            the_samp.alatt = the_source.alatt;
                            the_samp.angdeg = the_source.angdeg;
                        end
                        targ_samp(i)  = the_samp;
                    end
                end
                obj.samples_ = targ_samp;
            else
                warning('HORACE:Experiment:no_available_fixup', ...
                        'number of old lattice parameters does not match current samples');
            end
        else
            
            warning('HORACE:Experiment:invalid_argument', ...
                'Samples in experiment are defined but their lattice is undefined and the old simples define different lattice')
        end
        obj.old_lattice_holder_ = [];
    else
        is_null = cellfun(@(x)isa(x,'IX_null_sample'),new_uni_obj);
        if ~all(is_null)
            warning('HORACE:Experiment:invalid_argument', ...
                'Samples in experiment are defined but their lattice is undefined')
        end
    end
end

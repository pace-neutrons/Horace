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
        obj.instruments_ = obj.instruments_.expand_runs(nruns);
    else
        mess = sprintf(...
            'Number of instruments: %d is not equal to number of runs: %d; ',...
            obj.instruments_.n_runs,nruns);
    end
end
if obj.samples_.n_runs ~= nruns
    if obj.samples_.n_runs == 1
        obj.samples_ = obj.samples_.expand_runs(nruns);
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

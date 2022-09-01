function [ok,mess,obj] = check_combo_arg_(obj)
% verify consistency of Experiment containers
%
% Inputs:
% obj  -- the initialized instance of Experiment obj
%
% Returns:
% ok  -- logical, true if Experiment components are consistent,
%        false, otherwise
% mess -- empty if ok == true, and text, describing the reason
%         for failure if it does not
% obj -- the initial obj with property isvalid_ set ok value
%
ok = true;
mess = '';
nruns = numel(obj.expdata_);
if nruns == 0
    return;
end

if iscell(obj.instruments_)
    disp("check_combo_arg");
end

if n_runs(obj.instruments_) ~= nruns        
    ok = false;
    mess = sprintf(...
        'Number of instruments: %d is not equal to number of runs: %d; ',...
        n_runs(obj.instruments_),nruns);
end
if numel(obj.samples_) ~= nruns
    ok = false;
    mess = sprintf(...
        '%s\n Number of samples %d is not equal to number of runs: %d; ',...
        mess,numel(obj.samples_),nruns);
end
if isempty(obj.runid_map_) 
    ok = false;
    mess = sprintf('%s\n runid_map is not defined',mess);
else
    if obj.runid_map_.Count ~= nruns
        ok = false;
        mess = sprintf(...
            '%s\n Number of elements %d in runid_map is not equal to number of runs: %d; ',...
            mess,obj.runid_map_.Count,nruns);
    else
        ind = obj.runid_map_.values;
        ind  = [ind{:}];
        if any(sort(ind)~=1:nruns)
            ok = false;
            mess = sprintf(...
                '%s\n The values in runid_map do not account for every Experiment component; ',...
                mess);
        end
    end
end
obj.isvalid_ = ok;

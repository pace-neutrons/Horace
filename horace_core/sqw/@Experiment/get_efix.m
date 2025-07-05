function [efix,unique_idx,obj] = get_efix(obj,extract_unique)
% Return cellarray of incident energies from all runs, contributing to
% experiment.
%
% the output cellarray form is necessary for indirect instruments, which
% may have multiple efix. (it is analyser energy there).  Efix may also
% change from run to run.
%
% Inputs:
% obj   -- initialized instance of instrument
% Optional:
% extract_unique
%       -- if provided and true, return result in the form od
%
% Returns:
% efix  
%   either
%      --  cellarray or array of incident energies or crystal analyser
%          energies for indirect instrument one array per run. If number of
%          incident energy values for each element in cellarray is equal to
%          one, the cellarray is converted to array of energies.
%   or 
%      --  If extract_unique == true efix returned in the form of 
%          compact_array of data highlighting equal and unique elements
%          in efix
% 
% efix are considered equal if their relative or absolute difference,
% whatever smaller, is smaller then the value specified in the code.
% At the moment error is equal to [1.e-8,1.e-8]

if nargin == 1
    extract_unique = false;
end
if nargout>1
    extract_unique = true;    
end

efix = arrayfun(@(x)x.efix(:)',obj.expdata_,'UniformOutput',false);
if extract_unique  % calculate indices for equal values
    Diff =[1.e-8,1.e-8];
    unique_idx = calc_idx_for_eq_to_tol(efix,Diff);
    n_unique = numel(unique_idx);
    ef_selected = cell(1,n_unique);
    for i=1:n_unique
        ef_selected{i} = efix{unique_idx{i}(1)};
    end
    efix = ef_selected;
    efix = compact_array(unique_idx,efix);
else
    % enable support for old efix interface used by get_efix Horace.
    % this interface would not work for MUSHRUM
    n_elem = cellfun(@(x)numel(x),efix);
    if all(n_elem==1) %
        efix = [efix{:}];
    end
end
end

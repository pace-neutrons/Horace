function [efix,unique_idx] = get_efix(obj)
% Return cellarray of incident energies from all runs, contributing to
% experiment.
%
% the output cellarray form is necessary for indirect instruments, which
% may have multiple efix. (it is analyzer energy there).  Efix may also
% change from run to run.
%
% Returns:
% efix  -- cellrarray of incident energies for direct instrument, one
%          element per run or cellarray of arrays of crystal analyzer
%          eneries for indirect instrument one cell per run.
%          If two arguments are requested, cellarray of only unique efixed
%          valus is returned.
% unique_idx
%      --  cellarry of arrays of indices for unique efix.
%          If all efix are the same,
%          this cellarray will contain single cell and this cell contains
%          all exp_data indices. I.e. if there are 10 IX_experiment
%          elements, uique_idx = {1:10}. If IX_experiments have two
%          energies, first five efix1 and second five - efix2;
%          unique_idx = {1:5,6:10}. All different efix will contain
%          cellarray unique_idx = {1,2,3,...9,10};
%
% efix are considered equal if their relative or absolute difference,
% whatever smaller, is smaller then the value specified in the code.
% At the moment error is equal to [1.e-8,1.e-8]


efix = arrayfun(@(x)x.efix(:)',obj.expdata_,'UniformOutput',false);
if nargout>1 % calculate indices for equal values
    Diff =[1.e-8,1.e-8];
    unique_idx = calc_eq_indices(efix,Diff);
    n_unique = numel(unique_idx);
    ef_selected = cell(1,n_unique);
    for i=1:n_unique
        ef_selected{i} = efix{unique_idx{i}(1)};
    end
    efix = ef_selected;
end
end

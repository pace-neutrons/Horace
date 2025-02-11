function [en,nuidx]  = get_en_transfer(obj,bin_centre)
%GET_EN_TRANSFER Return cellarray of energy transfer arrays, contributed
% to the experiment.
%
% Duplicated energy transfers arrays are omitted.
% 
% Inputs:
% obj        -- initialized instance of experiment
% Optional:
% bin_centre -- currently assumed that IX_experiment contains bin boundaries 
%               of the contributing neutron events.
%               if bin_centre is true, function returns bin centres of
%               these bins rather than their bin boundaries.

if nargin == 1
    bin_centre = false;    
end
n_runs = obj.n_runs;
en = cell(1,n_runs);
nuidx = zeros(1,n_runs);
exper = obj.exper_data;
en{1} = exper(1).get_en(bin_centre);
nuidx(1) = 1;
n_unique = 1;
for i=2:n_runs
    if exper(i) == exper(i-1) % use fact of fast comparison available 
        % for IX_experiment
        continue;
    end
    n_unique = n_unique+1;
    nuidx(n_unique)= i;
    en{n_unique}  = exper(i).get_en(bin_centre);
end

if n_unique ~= n_runs
    en = en(1:n_unique);
    nuidx = nuidx(1:n_unique);
end

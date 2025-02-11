function detdcn = calc_detdcn_(obj,idx)
%CALC_DETDCN calculate unit vectors directed from sample to each detector% 
%of the detector's array.
% 
% if idx is not empty, calculate detdcn for requested indices only.
%
ndet = obj.ndet;
n_banks = numel(obj.det_bank_);

all_idx = zeros(1,ndet);
phi      = zeros(1,ndet);
azim     = zeros(1,ndet);
idx_start = 1;
for i=1:n_banks
    nd_in_bank = obj.det_bank_(i).ndet;
    idx_end    = idx_start+nd_in_bank-1;
    all_idx(idx_start:idx_end) = obj.det_bank_(i).id;
    phi(idx_start:idx_end)     = obj.det_bank_(i).phi;
    azim(idx_start:idx_end)    = obj.det_bank_(i).azim;
    idx_start = idx_end+1;
end
if ~isempty(idx)
    requested = ismember(all_idx,idx);
    all_idx = all_idx(requested);
    phi     = phi(requested);
    azim    = azim(requested);
end

detdcn = calc_detdcn(phi,azim,all_idx);

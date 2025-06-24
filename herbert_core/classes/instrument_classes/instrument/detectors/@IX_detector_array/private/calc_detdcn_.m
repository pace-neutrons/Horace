function detdcn = calc_detdcn_(obj,idx)
%CALC_DETDCN_ calculate unit vectors directed from sample to each detector
%of the detector's array.
%
% if idx is not empty, calculate detdcn for detectors with requested indices
% only.
% Input:
% obj        -- initialized IX_detectors_array instance containing ndet
%               detectors
% Optional:
% idx        -- list of the indices to select (in the range 1 to number of
%               detectors in the array). If missing, select all detectors.
% returns:
% detdcn     -- [4 x M] array of unit vectors, pointing to the detector's
%               positions in the spectrometer coordinate system (X-axis
%               along the beam direction). M == numel(idx) if idx is present
%               or ndet if it is absent.
%               The array contents is:
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim);idx]
%               where phi is the angle between x-axis and detector
%               direction, azim -- polar angle of detector in spherical
%               coorinate system with z-axis aligned to x and idx -- array
%               of detector id-s from det_bank.id field. (Most often --
%               detector number in the array but Mantid detector-id is also
%               possible)
%
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

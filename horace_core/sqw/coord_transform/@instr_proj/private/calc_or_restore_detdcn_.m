function  detdcn = calc_or_restore_detdcn_(det)
% Calculate unit vectors pointed directed to each detectors or
% or restore prefetched positions for such detectors
% Inputs:
% det    -- the structure, containing detectors information,
%           as obtained by rundata.get_par method [scalar structure]
%
% Returns:
% detdcn -- [3 x ndet] array of unit vectors, poinitng to the detector's
%           positions in the spectrometer coordinate system (X-axis
%           along the beam direction). ndet -- number of detectors
%           Can be later assigned to the next rundata object
%           property "detdcn_cache" to accelerate calculations. (not
%           fully implemented and currently workis with Matlab code only)
%           [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
persistent det_buff;
persistent detdch_buf;


if (isempty(detdch_buf) || ~compare_det(det,det_buff))
    det_buff = det;
    if isempty(det)
        det_buff = [];
    else
        detdcn=calc_detdcn(det);
        detdch_buf =detdcn;
    end
else
    detdcn = detdch_buf;
end

function det_eq = compare_det(det,det_buff)
if any(abs(det.group-det_buff.group)<1.e-8) && ...
        any(abs(det.phi-det_buff.phi)<1.e-8) && ...
        any(abs(det.azim-det_buff.azim)<1.e-8)
    det_eq = true;
else
    det_eq = false;
end


function  detdcn = calc_or_restore_detdcn_(det)
% Calculate unit vectors pointed directed to each detectors or
% or restore prefetched positions for such detectors
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


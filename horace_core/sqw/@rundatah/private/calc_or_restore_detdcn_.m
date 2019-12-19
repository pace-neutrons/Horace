function  detdcn = calc_or_restore_detdcn_(det)
% Calculate unit vectors pointed directed to each detectors or
% or restore prefetched positions for such detectors
%
persistent det_buff;
persistent detdch_buf;


if (isempty(detdch_buf) || ~isequal(det,det_buff))
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


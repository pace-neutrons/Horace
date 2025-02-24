function [idx,minmax_run,minmax_det,minmax_en] = long_idx(run_id,det_id,en_id,minmax_run,minmax_det,minmax_en)
%long_idx  construct long index build from run, detector and energy ID-s
%to use in data compression and pixels identification
%
if nargin<4
    minmax_run = min_max(run_id);
    minmax_det = min_max(det_id);
    minmax_en  = min_max(en_id);
elseif nargin<5
    minmax_det = min_max(det_id);
    minmax_en  = min_max(en_id);
elseif nargin<6
    minmax_en  = min_max(en_id);
end
scale1 = minmax_en(2) -minmax_en(1)+1;
scale2 = minmax_det(2)-minmax_det(1)+1;

idx = scale2*((run_id-minmax_run(1))*scale1+en_id-minmax_en(1))+det_id-minmax_det(1);
if max(idx)>intmax("uint64")
    error('HERBERT:utilities:invalid_argument', [...
        'long run index exceeds maximal uint64 value so you can not accurately define it.'...
        ' Contact Horace developers for help with dealing with this issue']);
end
idx = uint64(idx);
end
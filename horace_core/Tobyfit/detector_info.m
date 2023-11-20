function [x2, d_mat, f_mat, detdcn] = detector_info (det, ielmts)

x2 = det.x2(ielmts);
d_mat  = det.dmat(:,:,ielmts);
f_mat_all = spec_to_secondary (det);
f_mat = f_mat_all(:,:,ielmts);
detdcn_all = det_direction (det);
detdcn = detdcn_all(:,ielmts);

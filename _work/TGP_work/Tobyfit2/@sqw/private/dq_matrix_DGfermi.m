function dq_mat =  dq_matrix_DGfermi (wi, wf, x0, xa, x1, x2, thetam, angvel, s_mat, d_mat, spec_to_rlu, k_to_v, k_to_e)
% Compute matrix for computing deviations in Q (in rlu) from deviations in tm, tch, x, y, z etc.
%
%   >> dq_mat = dq_matrix_DGfermi (wi, wf, x0, xa, x1, x2, thetam, angvel, s_mat, d_mat, spec_to_rlu, k_to_v, k_to_e)
%
% Input: for each pixel:
% ------
%   wi          incident wavevector of nominal neutron  (Ang^-1) [column vector length npix]
%   wf          final wavevector of nominal neutron     (Ang^-1) [column vector length npix]
%   x0          moderator-chopper distance      (m) 	 [column vector length npix]
%   xa          aperture-chopper distance       (m)      [column vector length npix]
%   x1          chopper-sample distance         (m)      [column vector length npix]
%   x2          sample-detector distance        (m)      [column vector length npix]
%   thetam      moderator tilt angle            (rad)    [column vector length npix]
%   angvel      angular frequency of chopper    (rad/s)  [column vector length npix]
%   s_mat       matrix for re-expressing a sample coordinate in the laboratory frame
%              Size is [3,3,npix]
%   d_mat       matrix for expressing a laboratory coordinate in the detector frame
%              Size is [3,3,npix]
%   spec_to_rlu Matrix to convert momentum in spectrometer coordinates to components in r.l.u.
%              Size is [3,3,npix]
%   k_to_e      Constant in E(mev)=k_to_e*(k(Ang^-1))^2
%   k_to_v      Constant in v(m/s)=k_to_v*k(Ang^-1)
%   
% Output:
% -------
%   dq_mat		Matrix to convert deviations in tm, tch etc. into deviations in Q in
%              the spectrometer frame (dQ||,dQperp,dQvert,deps)
%              Size is [4,11,npix]
%
% The order of deviations corresponding to the second row of dq_mat is:
%
%   t_m     deviation in departure time from moderator surface
%   y_a     y-coordinate of neutron at apperture
%   z_a     z-coordinate of neutron at apperture
%   t_ch'   deviation in time of arrival at chopper
%   x_s     x-coordinate of point of scattering in sample frame
%   y_s     y-coordinate of point of scattering in sample frame
%   z_s     z-coordinate of point of scattering in sample frame  
%   x_d     x-coordinate of point of detection in detector frame	
%   y_d     y-coordinate of point of detection in detector frame
%   z_d     z-coordinate of point of detection in detector frame
%   t_d     deviation in detection time of neutron


npix = numel(wi);

% Calculate velocities and times:
% -------------------------------
veli = k_to_v * wi;
velf = k_to_v * wf;
ti = x0./veli;
tf = x2./velf;


% Get some coefficients:
% ----------------------
g1 = (1 - angvel.*(x0+x1).*tan(thetam)./veli );
g2 = (1 - angvel.*(x0-xa).*tan(thetam)./veli );
f1 =  1 + (x1./x0).*g1;
f2 =  1 + (x1./x0).*g2;
gg1 = g1 ./ ( angvel.*(xa+x1) );
gg2 = g2 ./ ( angvel.*(xa+x1) );
ff1 = f1 ./ ( angvel.*(xa+x1) );
ff2 = f2 ./ ( angvel.*(xa+x1) );

cp_i = wi./ti;
ct_i = wi./(xa+x1);
cp_f = wf./tf;
ct_f = wf./x2;


% Calculate the matrix elements:
% -------------------------------
b_mat = zeros(6,11,npix);

ds_mat = mtimesx(d_mat,s_mat);

b_mat(1,1,:) =  cp_i;
b_mat(1,2,:) = -cp_i .* gg1;
b_mat(1,4,:) = -cp_i;
b_mat(1,5,:) =  (cp_i .* gg2) .* squeeze(s_mat(2,1,:));
b_mat(1,6,:) =  (cp_i .* gg2) .* squeeze(s_mat(2,2,:));
b_mat(1,7,:) =  (cp_i .* gg2) .* squeeze(s_mat(2,3,:));

b_mat(2,2,:) = -ct_i;
b_mat(2,5,:) =  ct_i .* squeeze(s_mat(2,1,:));
b_mat(2,6,:) =  ct_i .* squeeze(s_mat(2,2,:));
b_mat(2,7,:) =  ct_i .* squeeze(s_mat(2,3,:));

b_mat(3,3,:) = -ct_i;
b_mat(3,5,:) =  ct_i .* squeeze(s_mat(3,1,:));
b_mat(3,6,:) =  ct_i .* squeeze(s_mat(3,2,:));
b_mat(3,7,:) =  ct_i .* squeeze(s_mat(3,3,:));

b_mat(4,1,:) =  cp_f .* (-x1./x0);
b_mat(4,2,:) =  cp_f .*  ff1;
b_mat(4,4,:) =  cp_f .* ((x0+x1)./x0);
b_mat(4,5,:) =  cp_f .* ( squeeze(s_mat(1,1,:))./veli - squeeze(ds_mat(1,1,:))./velf - ff2.*squeeze(s_mat(2,1,:)) );
b_mat(4,6,:) =  cp_f .* ( squeeze(s_mat(1,2,:))./veli - squeeze(ds_mat(1,2,:))./velf - ff2.*squeeze(s_mat(2,2,:)) );
b_mat(4,7,:) =  cp_f .* ( squeeze(s_mat(1,3,:))./veli - squeeze(ds_mat(1,3,:))./velf - ff2.*squeeze(s_mat(2,3,:)) );
b_mat(4,8,:) =  cp_f./velf;
b_mat(4,11,:)= -cp_f;

b_mat(5,5,:) = -ct_f .* squeeze(ds_mat(2,1,:));
b_mat(5,6,:) = -ct_f .* squeeze(ds_mat(2,2,:));
b_mat(5,7,:) = -ct_f .* squeeze(ds_mat(2,3,:));
b_mat(5,9,:) =  ct_f;

b_mat(6,5,:) = -ct_f .* squeeze(ds_mat(3,1,:));
b_mat(6,6,:) = -ct_f .* squeeze(ds_mat(3,2,:));
b_mat(6,7,:) = -ct_f .* squeeze(ds_mat(3,3,:));
b_mat(6,10,:)=  ct_f;


% Matrix to convert deviations in ki and kf into deviations in Q and eps
% ----------------------------------------------------------------------
qk_mat = zeros(4,6,npix);
qk_mat(1:3,1:3,:) = spec_to_rlu;
qk_mat(1:3,4:6,:) = -mtimesx(spec_to_rlu,permute(d_mat,[2,1,3]));  % inverse of d_mat(:,:,i) is transpose of same
qk_mat(4,1,:) = (2*k_to_e)*wi;
qk_mat(4,4,:) =-(2*k_to_e)*wf;

dq_mat=mtimesx(qk_mat,b_mat);

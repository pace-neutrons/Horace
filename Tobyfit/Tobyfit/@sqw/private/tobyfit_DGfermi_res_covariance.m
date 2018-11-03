function [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_res_covariance...
    (header, detpar, u_to_rlu, use_tube)
% Return 4D momentum-energy covariance matrix for the resolution function
%
%   >> [cov_spec, cov_proj, cov_hkle] = tobyfit_DGfermi_res_covariance...
%                                           (header,detpar,u_to_rlu,use_tube)
% Input:
% ------
%   header      Header structure for a single spe file with a single energy bin
%   detpar      Detector structure for a single detector
%   u_to_rlu    The projection axis vectors u1, u2, u3 in reciprocal
%              lattice vectors. The ith column is ui in r.l.u. i.e.
%                   ui = u_to_rlu(:,i)
%               This is the field u_to_rlu in the data field of an sqw object
%
% Output:
% -------
%   cov_proj    Covariance matrix for wavevector-energy in projection axes
% 
%   cov_spec    Covariance matrix for wavevector-energy in spectrometer axes
%              i.e. x || ki, z vertical upwards, y perpendicular to z and y.
%
%   cov_hkle    Covariance matrix for wavevector-energy in h-k-l-energy


% Get matrix to relate deviations in coordinates t_m...t_d to Q in specxtroemter frame
% ------------------------------------------------------------------------------------
% This block of code effectively does the same job as tobyfit_DGfermi_resconv_init

% Get some constants
c=neutron_constants;
k_to_e = c.c_k_to_emev;     % E(mev)=k_to_e*(k(Ang^-1))^2
k_to_v = 1e6/c.c_t_to_k;    % v(m/s)=k_to_v*k(Ang^-1)
deps_to_dt = 0.5e-6*c.c_t_to_k/c.c_k_to_emev;   % dt(s)=deps_to_dt*x2(m)/kf(Ang^-1)^3 * deps(meV)

% Get energy transfer and bin size
[deps,eps]=energy_transfer_info(header);

% Get instrument information
[ok,mess,ei,x0,xa,x1,thetam,angvel,moderator,aperture,chopper] = instpars_DGfermi (header);
if ~ok, error(mess), end
[wa, ha] = aperture_width_height (aperture);

% Compute ki and kf
ki=sqrt(ei/k_to_e);
kf=sqrt((ei-eps)/k_to_e);

% Get sample, and both s_mat and spec_to_rlu
[ok, mess, sample, s_mat, spec_to_rlu] = sample_coords_to_spec_to_rlu (header);
if ~ok, error(mess), end

% Get detector information
[d_mat, detdcn] = spec_coords_to_det (detpar);
x2=detpar.x2;
det_width=detpar.width;
det_height=detpar.height;

% Time width corresponding to energy bin
dt = deps_to_dt*(x2.*deps./kf.^3);

% Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc.
dq_mat =  dq_matrix_DGfermi (ki, kf, x0, xa, x1, x2, thetam, angvel, s_mat, d_mat,...
    spec_to_rlu, k_to_v, k_to_e);


% Get variances of moderator...detector
% -------------------------------------
% This block of code effectively does the quivalent of tobyfit_DGfermi_resconv

var_mod = (10^-6 * pulse_width(moderator,ei))^2;

var_wa = wa^2 / 12;
var_ha = ha^2 / 12;

var_chop = (10^-6 * pulse_width(chopper,ei))^2;

cov_sam = covariance(sample);

if use_tube
    He3det=IX_He3tube(0.0254,10,6.35e-4);   % 1" tube, 10atms, wall thickness=0.635mm
    var_det_depth = var_d (He3det, kf);
    var_det_width = var_w (He3det, kf);
    var_det_height = det_height^2 / 12;
else
    var_det_depth = 0.015^2 / 12;       % approx dets as 25mm diameter, and FWHH=0.6 diameter
    var_det_width = det_width^2 / 12;
    var_det_height = det_height^2 / 12;
end

var_tdet = dt^2 / 12;


% Compute covariance matrix in spectrometer and projection axes frames
% --------------------------------------------------------------------
cov_x = zeros(11,11);
cov_x(1,1) = var_mod;
cov_x(2,2) = var_wa;
cov_x(3,3) = var_ha;
cov_x(4,4) = var_chop;
cov_x(5:7,5:7) = cov_sam;
cov_x(8:10,8:10) = diag([var_det_depth,var_det_width,var_det_height]);
cov_x(11,11) = var_tdet;

dq_mat = squeeze(dq_mat);   % it is a 4x1x11 matrix
cov_hkle = dq_mat * cov_x * dq_mat';

cov_proj = u_to_rlu \ cov_hkle / u_to_rlu';         % (B^-1)A(B^-1)' = (B^-1)A(B')^-1 = (B\A)/B'

spec_to_rlu4 = eye(4);
spec_to_rlu4(1:3,1:3) = spec_to_rlu;
cov_spec = spec_to_rlu4 \ cov_hkle / spec_to_rlu4';   % (B^-1)A(B^-1)' = (B^-1)A(B')^-1 = (B\A)/B'




%test_covariance(cov_x,dq_mat)
%===================================================
function test_covariance (cov, dq_mat)
contr = zeros(11,1);
for i=1:11
    contr(i) = log(256)*cov(i,i)*dq_mat(4,i)^2;
end
total = sum(contr);
disp('-------------------------------')
disp(sqrt(total))
disp(sqrt(contr))
disp('-------------------------------')

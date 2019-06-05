% ---------------------------------------------------------------------------
% Test detectors
% ---------------------------------------------------------------------------

% Test equivalence of old and new classes

dia1 = 0.0254;  height1 = 0.015; thick1 = 6.35e-4; atms1 = 10; th1 = pi/2;  sth1 = sin(th1);
dia2 = 0.0300;  height2 = 0.025; thick2 = 10.0e-4; atms2 = 6;  th2 = 0.9;   sth2 = sin(th2);
dia3 = 0.0400;  height3 = 0.035; thick3 = 15.0e-4; atms3 = 4;  th3 = 0.775; sth3 = sin(th3);
dia4 = 0.0400;  height4 = 0.035; thick4 = 15.0e-4; atms4 = 7;  th4 = 0.775; sth4 = sin(th4);
dia5 = 0.0400;  height5 = 0.035; thick5 = 15.0e-4; atms5 = 9;  th5 = 0.775; sth5 = sin(th5);
path1 = [sin(th1),0,cos(th1)]';
path2 = [sin(th2),0,cos(th2)]';
path3 = [sin(th3),0,cos(th3)]';
path4 = [sin(th4),0,cos(th4)]';
path5 = [sin(th5),0,cos(th5)]';

det1 = IX_He3tube (dia1, atms1, thick1);
det2 = IX_He3tube (dia2, atms2, thick2);
det3 = IX_He3tube (dia3, atms3, thick3);
det4 = IX_He3tube (dia4, atms4, thick4);
det5 = IX_He3tube (dia5, atms5, thick5);

detarr_1_3 = [det1, det2, det3];
detarr_3_5 = [det3, det4, det5];

ndet1 = IX_det_He3tube (dia1, height1, thick1, atms1);
ndet2 = IX_det_He3tube (dia2, height2, thick2, atms2);
ndet3 = IX_det_He3tube (dia3, height3, thick3, atms3);
ndet4 = IX_det_He3tube (dia4, height4, thick4, atms4);
ndet5 = IX_det_He3tube (dia5, height5, thick5, atms5);

dia_1_3    = [dia1, dia2, dia3];
height_1_3 = [height1, height2, height3];
thick_1_3  = [thick1, thick2, thick3];
atms_1_3   = [atms1, atms2, atms3];
th_1_3     = [th1, th2, th3];
sth_1_3    = [sth1, sth2, sth3];
path_1_3   = [path1,path2,path3];

ndetarr_1_3 = IX_det_He3tube (dia_1_3, height_1_3, thick_1_3, atms_1_3);

ndetarr_3_5 = IX_det_He3tube (dia3, height3, thick3, [atms3,atms4,atms5]);


% Test  detector array
% --------------------
clear eff_1_3 del_d_1_3 var_d_1_3 var_w_1_3

wvec = 10;
for i=1:3
    eff_1_3(i) = effic(detarr_1_3(i),wvec,sth_1_3(i));
    del_d_1_3(i) = del_d(detarr_1_3(i),wvec,sth_1_3(i));
    var_d_1_3(i) = var_d(detarr_1_3(i),wvec,sth_1_3(i));
    var_w_1_3(i) = var_w(detarr_1_3(i),wvec,sth_1_3(i));
end

neff_1_3 = ndetarr_1_3.effic(path_1_3,wvec);
ndel_d_1_3 = ndetarr_1_3.mean_d(path_1_3,wvec);
nvar_d_1_3 = ndetarr_1_3.var_d(path_1_3,wvec);
nvar_w_1_3 = ndetarr_1_3.var_y(path_1_3,wvec);

if ~equal_to_tol(eff_1_3,neff_1_3,1e-12)
    error('effic')
end
if ~equal_to_tol(del_d_1_3,del_d_1_3,1e-12)
    error('del_d')
end
if ~equal_to_tol(var_d_1_3,var_d_1_3,1e-12)
    error('var_d')
end
if ~equal_to_tol(var_w_1_3,var_w_1_3,1e-12)
    error('var_w')
end


% Test single detector
% ------------------------
wvec = 5:15;
eff = effic(det2,wvec,sth2);
delta_d = del_d(det2,wvec,sth2);

neff = ndet2.effic(path2,wvec);
ndelta_d = ndet2.mean_d(path2,wvec);

if ~equal_to_tol(eff,neff,1e-12)
    error('effic')
end
if ~equal_to_tol(delta_d,ndelta_d,1e-12)
    error('del_d')
end



% Test detectors in object_array

% Create three detector sets, one of which is a duplicate of the first
% ----------------------------------------------------------------------
dia1 = 0.0254;  height1 = 0.015; thick1 = 6.35e-4; atms1 = 10; th1 = pi/2;  sth1 = sin(th1);
dia2 = 0.0300;  height2 = 0.025; thick2 = 10.0e-4; atms2 = 6;  th2 = 0.9;   sth2 = sin(th2);
dia3 = 0.0400;  height3 = 0.035; thick3 = 15.0e-4; atms3 = 4;  th3 = 0.775; sth3 = sin(th3);
dia4 = 0.0400;  height4 = 0.035; thick4 = 15.0e-4; atms4 = 7;  th4 = 0.775; sth4 = sin(th4);
dia5 = 0.0400;  height5 = 0.035; thick5 = 15.0e-4; atms5 = 9;  th5 = 0.775; sth5 = sin(th5);

det1 = IXX_He3tube (dia1, height1, thick1, atms1, th1);
det2 = IXX_He3tube (dia2, height2, thick2, atms2, th2);
det3 = IXX_He3tube (dia3, height3, thick3, atms3, th3);
det4 = IXX_He3tube (dia4, height4, thick4, atms4, th4);
det5 = IXX_He3tube (dia5, height5, thick5, atms5, th5);

dia_1_3    = [dia1, dia2, dia3];
height_1_3 = [height1, height2, height3];
thick_1_3  = [thick1, thick2, thick3];
atms_1_3   = [atms1, atms2, atms3];
th_1_3     = [th1, th2, th3];
sth_1_3    = [sth1, sth2, sth3];

det_1_3 = IXX_He3tube (dia_1_3, height_1_3, thick_1_3, atms_1_3, th_1_3);
det_3_5 = IXX_He3tube (dia3, height3, thick3, [atms3,atms4,atms5], th3);


detarr1 = det_1_3;
detarr2 = det_3_5;
detarr3 = det_1_3;

det_table = object_lookup ([detarr1,detarr2,detarr3]);


% Massive detarr
% ----------------
% To test speed of sorting
narr = 100;

ndet1 = 50000;
ndet2 = 70000;

height_big1 = 0.02 + 0.01*rand(1,ndet1);
height_big2 = 0.02 + 0.01*rand(1,ndet2);

detarr_big1 = IXX_He3tube (dia1, height_big1, thick1, atms1, th1);
detarr_big2 = IXX_He3tube (dia2, height_big2, thick2, atms2, th2);
tmp = [detarr_big1,detarr_big2];

detarr_big = tmp(randselection([1,2],100,1));

detlook = object_lookup(detarr_big);




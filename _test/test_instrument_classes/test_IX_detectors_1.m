function test_IX_detectors_1
% Test the methods for a detector array 
%
% Detector arrays are made of banks which in turn are made of detectors

% 3He bank
% --------
x2_1 = [10,10.1,10.2,10.3];
phi_1 = [30,35,40,45];
azim_1 = 45;
det_1 = IX_det_He3tube(0.0254,0.03,0.002,10);

rotvec1 = [0,0,0; 0,20,0; 0,45,0; 0,60,0]';
dbank1 = IX_detector_bank (1001:1004,x2_1,phi_1,azim_1,det_1,'rotvec',rotvec1);


% 3He bank
% --------
x2_2 = 2.5;
phi_2 = [10,10,15,15,20,20];
azim_2 = [0,22.5,45,67.5,90,90];
det_2 = IX_det_He3tube(0.0125,0.015,0.002,6.3);

rotvec2 = [0,10,0; 0,23,0; 0,55,0; 0,60,0; 0,65,0; 0,80,0]';
dbank2 = IX_detector_bank (2001:2006,x2_2,phi_2,azim_2,det_2,'rotvec',rotvec2);


% slab banks
% ----------
x2_3 = [2,2.1,2.2];
phi_3 = [10,21,32];
azim_3 = [180,180,180];
det_3 = IX_det_slab (0.01,0.03,0.2,0.005);

rotvec3 = [0,31,0; 0,28,0; 0,41,0]';
dbank3 = IX_detector_bank (3001:3003,x2_3,phi_3,azim_3,det_3,'rotvec',rotvec3);


% 3He bank
% --------
x2_4 = 4;
phi_4 = [10,20,20];
azim_4 = [10,122.5,167.5];
det_4 = IX_det_He3tube(0.0125,0.015,0.002,[6.3,7.3,15.3]);

rotvec4 = [0,3,0; 0,22,0; 0,47,0]';
dbank4 = IX_detector_bank (4001:4003,x2_4,phi_4,azim_4,det_4,'rotvec',rotvec4);




% Get various quantities for a selection of detctors from the banks:
% ------------------------------------------------------------------
dbank_all = {dbank1, dbank2, dbank3, dbank4};
wvec = 3.2;
eff_all = cellfun(@(x)(x.effic(wvec)),dbank_all,'uniformOutput',false);
mean_all = cellfun(@(x)(x.mean(wvec)),dbank_all,'uniformOutput',false);
covar_all = cellfun(@(x)(x.covariance(wvec)),dbank_all,'uniformOutput',false);

bob = eff_all;
eff_ref = [bob{1}([4,1]), bob{3}(1), bob{4}(3), bob{3}(2), bob{4}(2)];

bob = mean_all;
mean_ref = cat(2, bob{1}(:,[4,1]), bob{3}(:,1), bob{4}(:,3), bob{3}(:,2), bob{4}(:,2));

bob = covar_all;
covar_ref = cat(3, bob{1}(:,:,[4,1]), bob{3}(:,:,1), bob{4}(:,:,3), bob{3}(:,:,2), bob{4}(:,:,2));


% ----------------------------------------------------------------------------
% Make a detector array
% ----------------------
% Tests lots of indexing

dbank_1_3 = [dbank1,dbank2,dbank3];
detarray = IX_detector_array (dbank_1_3,dbank4);

eff = detarray.effic([4,1,11,16,12,15], wvec);
mn  = detarray.mean ([4,1,11,16,12,15], wvec);
cov = detarray.covariance([4,1,11,16,12,15], wvec);

if ~isequal(eff_ref,eff)
    error('efficiency calculation problem')
end

if ~isequal(mean_ref,mn)
    error('mean calculation problem')
end

if ~isequal(covar_ref,cov)
    error('covar calculation problem')
end

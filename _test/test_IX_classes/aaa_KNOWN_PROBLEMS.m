%% =============================================================================================
%                              *** CURRENT PROBLEMS ***
% ==============================================================================================
rootpath=pwd;
load(fullfile(rootpath,'make_data','test_IX_datasets_ref.mat'));

%% ----------------------------------------------------
%  Output of integration of array of 1D datasets
% -----------------------------------------------------
p1arr=repmat(p1,1,5);
i1arr_a=integrate(p1arr,[2,6],'ave')   % *** Shouldn't this give an IX_dataset_1d?


%% -------------------------------------
%  Rebin, integrate non-intuitive
% --------------------------------------
% Behaviour of rebin and integrate aren't always intuitive.
% Particularly,the case when point dataset with option 'int' (the default): if
% the new bins extend beyond the range of the data points. No obviously 'right' algorithm.
% as are really trying to extrapolate, or truncate data at first and final points but
% still giving a value at the new bin centres of the two bins that cover these two points.

wp=p1;  wp.signal=5*ones(size(wp.signal)); wp.error=0.3*wp.error; wp.x_distribution=false;
wpd=wp; wpd.x_distribution=true;
wh=point2hist(wp); wh.x_distribution=false;
whd=point2hist(wp); whd.x_distribution=true;

xb=-7.5:5:27.5;

use_mex('ref_2011_08_30_0946')

% Manipulations of histogram data
% --------------------------------
% - rebin
wh_r_ref  =rebin(wh);
wh_rb_ref =rebin(wh,xb);
whd_r_ref =rebin(whd);
whd_rb_ref=rebin(whd,xb);

hcompare(wh,wh_r_ref,wh_rb_ref)
keep_figure
hcompare(whd,whd_r_ref,whd_rb_ref)
keep_figure

% - integration
wh_i_ref  =integrate(wh);
wh_ib_ref =integrate(wh,xb);
whd_i_ref =integrate(whd);
whd_ib_ref=integrate(whd,xb);

hcompare(wh,wh_i_ref,wh_ib_ref)
keep_figure
hcompare(whd,whd_i_ref,whd_ib_ref)
keep_figure


% Manipulations of point data
% --------------------------------
% - rebin
wp_ra_ref  =rebin(wp);
wp_rab_ref =rebin(wp,xb);
wpd_ra_ref =rebin(wpd);
wpd_rab_ref=rebin(wpd,xb);

pcompare(wp,wp_ra_ref,wp_rab_ref)
keep_figure
pcompare(wpd,wpd_ra_ref,wpd_rab_ref)
keep_figure

wp_ri_ref  =rebin(wp,'int');
wp_rib_ref =rebin(wp,xb,'int');
wpd_ri_ref =rebin(wpd,'int');
wpd_rib_ref=rebin(wpd,xb,'int');

pcompare(wp,wp_ri_ref,wp_rib_ref)
keep_figure
pcompare(wpd,wpd_ri_ref,wpd_rib_ref)
keep_figure

% - integration
wp_ia_ref  =integrate(wp,'ave');
wp_iab_ref =integrate(wp,xb,'ave');
wpd_ia_ref =integrate(wpd,'ave');
wpd_iab_ref=integrate(wpd,xb,'ave');

pcompare(wp,wp_ia_ref,wp_iab_ref)
keep_figure
pcompare(wpd,wpd_ia_ref,wpd_iab_ref)
keep_figure

wp_ii_ref  =integrate(wp,'int');
wp_iib_ref =integrate(wp,xb,'int');
wpd_ii_ref =integrate(wpd,'int');
wpd_iib_ref=integrate(wpd,xb,'int');

pcompare(wp,wp_ii_ref,wp_iib_ref)
keep_figure
pcompare(wpd,wpd_ii_ref,wpd_iib_ref)
keep_figure


%% ----------------------
%  Why different?
% -----------------------
da(hp1)
lx 2 14; ly 4 7; lc 0 8
keep_figure
c2=cut(hp1,[2,0,14],[4,0,7]);
da(c2)
lc 0 8
keep_figure


%% =============================================================================================
%                              *** SOLVED PROBLEMS ***
% ==============================================================================================

%% ----------------------
%  Shouldn't integrate result in integrals in output ?
% -----------------------
kk=integrate(h1);
acolor b
dh(h1)
acolor r
ph(kk)

%% ---------------------
%  IX_dataset_2d from array of IX_dataset_1d: looks wrong, but isn't
% ----------------------

p3h=point2hist(p3);

% Recall that if x axes are not identical then IX_dataset_1d objects are not merged into a
% single IX_dataset_2d. Point data objects p1, p2, p3 all have the same x-axes, but p3h is 
% a histogram object. The output w2a and w2b are therefore arrays of *four* IX_dataset_2d

w2a=IX_dataset_2d([p1,p2,p3h,1.2*p3,p2,p3h],[11,13,15,17,19,24],IX_axis('yon','bushel'),true);
da(w2a)
keep_figure

w2b=IX_dataset_2d([p1,p2,p3h,1.2*p3,p2,p3h],[10,12,14,16,18,20,26],IX_axis('yon','bushel'),true);
da(w2b)
keep_figure

%% ----------------------
%  Rebin error
% -----------------------
% Had a problem about datasets with zero data points in the integration range
hhp=IX_dataset_2d(h1);
hhh=point2hist(hhp);

kk=rebin(hhp,[5,15],[0.5,0.9])

kk=rebin(hhp,[5,15],[0.5,0.9],'int')    % Not actually an error - is correct if just one point

kk=rebin(hhp,(5:15),[0.5,0.9]);
ll=rebin_x(kk,(3:6))
ll=rebin_x(kk,3)

kk=rebin_y(hhh,[5,6,7])


% Investigated systematically
% ---------------------------
% some points are missing => IX_dataset_1d
i_a=integrated(p1,[2,0.5,6],'ave')

% All points are missing => valerr structure
i_b=integrated(p1,[5,0.5,6],'ave')


% Empty point data along one axis
tmp=IX_dataset_2d(1:3,[])
tmp_out=integrate_y(tmp,14,16)
tmp_out=integrate_y(tmp,14,16,'ave')

% Make an array 1D workspaces
p1arr=repmat(p1,1,5);

i1arr_a=integrated(p1arr,[2,0.5,6],'ave')

i1arr_b=integrated(p1arr,[5,0.5,6],'ave')

i1arr_a=integrated(p1arr,[2,6],'ave')

i1arr_b=integrated(p1arr,[5,0.5,6],'ave')

% Make a 2D workspace from a stack of p1
p2=IX_dataset_2d(repmat(p1,1,5));

i2_a=integrated_x(p2,[2,0.5,6],'ave')

i2_b=integrated_x(p2,[5,0.5,6],'ave')


%% =============================================================================================
%                              *** TO DO ***
% ==============================================================================================

%% ----------------------
% Systematic check for sizes of 1d,2d,3d objects
% -----------------------

e1=IX_dataset_1d(zeros(1,0),zeros(1,0),zeros(1,0))

ee1=IX_dataset_1d([],[],[])

objdiff(e1,ee1) % not the same

e2=IX_dataset_2d(zeros(1,0),zeros(1,0),zeros(0,0),zeros(0,0))

%% ----------------------
%  Rebin error
% -----------------------
hh=IX_dataset_2d(h1);
kk=rebin(hh,[5,15],[0.5,0.9]);

kk=rebin(hh,[5,15],[0.5,0.9],'int');


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
% Solved
% ==============================================================================================

%% ----------------------
%  Shouldn't integrate result in integrals in output ?
% -----------------------
kk=integrate(h1);
acolor b
dh(h1)
acolor r
ph(kk)

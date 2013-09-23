% Create modified sqw file from spe file
spe_file='pcsmo_ei35_base.spe';
par_file='map_4to1_dec09.par';
sqw_file='test2.sqw';
efix=35;
gs=0;
gl=0;
gen_sqw_cylinder_test (spe_file, par_file, sqw_file, efix, gs, gl);


% Note that for making cuts you should use the standard cut_sqw function
% However, 

% 2D plot:
cc=cut_sqw('test2.sqw',0.05,[0.3,0.4],0,'-nopix');
plot(cc)

% 1D plots
cc1=cut_sqw('test2.sqw',[0.5,0.8],[0.3,0.4],0,'-nopix');
acolor k
dd(cc1)

cc2=cut_sqw('test2.sqw',[0.8,1.1],[0.3,0.4],0,'-nopix');
acolor b
pd(cc1)

cc_diff=cc1-cc2;
acolor r
pd(cc_diff)

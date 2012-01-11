% Script file to test my various combination scripts...

%Data we will use to test:
%1d case:
test1d_1=tofit_102_1d_hscan(1);
test1d_2=tofit_102_1d_hscan(2);
acolor red
plot(test1d_1);
acolor blue
pp(test1d_2);
keep_figure;

%2d case:
test2d_1=tofit_102_2d(1);
test2d_2=tofit_102_2d(2);
plot(test2d_1); lz 0 2; keep_figure;
plot(test2d_2); lz 0 2; keep_figure;

%=========================================
% TGP 12/1/12: replace calculate_qw_bins_test with calculate_qw_bins; identical function
qw_1d_1=calculate_qw_bins(sqw(test1d_1));
qw_1d_2=calculate_qw_bins(sqw(test1d_2));
qw_2d_1=calculate_qw_bins(sqw(test2d_1));
qw_2d_2=calculate_qw_bins(sqw(test2d_2));

%=========================================

h_1d=[qw_1d_1{1}; qw_1d_2{1}];
get1=get(test1d_1); get2=get(test1d_2);
s_1d=[get1.s; get2.s];
e_1d=[get1.e; get2.e];

[xout_1d,sout_1d,eout_1d]=simple_combine(h_1d,s_1d,e_1d,-2,0.1,0);
%[xout_1d,sout_1d,eout_1d]=simple_combine(qw_1d_1{1},get1.s,get1.e,-2,0.1,0);

figure;
errorbar(xout_1d,sout_1d,sqrt(eout_1d),'or');
axis([-2 0 -0.2 1.2]);
%This all seems to work!


%==========================================

h_2d=[qw_2d_1{1}; qw_2d_2{1}];
k_2d=[qw_2d_1{2}; qw_2d_2{2}];

get2d_1=get(test2d_1); get2d_2=get(test2d_2);
%as you go down the column x increases.
sig_2d_1=reshape(get2d_1.s,numel(get2d_1.s),1);
sig_2d_2=reshape(get2d_2.s,numel(get2d_2.s),1);
err_2d_1=reshape(get2d_1.e,numel(get2d_1.e),1);
err_2d_2=reshape(get2d_2.e,numel(get2d_2.e),1);

[xout_2d,yout_2d,sout_2d,eout_2d]=simple_combine2d(qw_2d_1{1},qw_2d_1{2},sig_2d_1,err_2d_1,0.5,0.05,1.5,-0.5,0.05,0.5);

xout_2d_new=reshape(xout_2d,11,11);
yout_2d_new=reshape(yout_2d,11,11);
sout_2d_new=reshape(sout_2d,11,11);
eout_2d_new=reshape(eout_2d,11,11);

figure;
pcolor(xout_2d_new,yout_2d_new',sout_2d_new);
colormap jet
shading flat

%this also appears to work, although we need to work out how to make things
%sufficiently general such that we don't have to map the data back on to a
%grid manually.
caxis([0 2]);


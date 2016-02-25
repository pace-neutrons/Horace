clear all;
    delim = ':';
if ispc
    sep = '\';
else
    sep = '/';
end
herbert_root = fileparts(which('herbert_init'));
addpath([herbert_root sep '_test' sep 'test_multifit']);
load 'testdata_multifit_1.mat'

%%
%{
%Original multifit
[f1,s1,r1,pp1] = multifit(x1,y1,e1,@mftest_gauss_bkgd,[100,50,7,0,0])
clf; errorbar(x1,y1,e1,'.'); hold all; plot(x1,f1,'-')
[f2,s2,r2,pp2] = multifit([w1 w2],@mftest_gauss_bkgd,[100,50,7,0,0])
figure; errorbar(x1,y1,e1,'.'); hold all; plot(f2(1).x,f2(1).signal,'-');
figure; errorbar(x2,y2,e2,'.'); hold all; plot(f2(2).x,f2(2).signal,'-');
return;
%}

%%
% {
a = multifit_class
v1.x=x1; v1.y=y1; v1.e=e1;
v2.x=x2; v2.y=y2; v2.e=e2;
a.data = {v1 v2};
a.ffun = @mftest_bkgd;
a.fpin = [0,0];
a.fpfree = [0,0];
a.bfun = @mftest_gauss_bkgd;
a.bpin = [100,50,7,0,0];
a.bpbind= {{{4,4,2,1},{5,5,2,1},{1,3}},{{1,3}}};
struct(a)
a=a.run_fit
struct(a)
a.fitdata
%}

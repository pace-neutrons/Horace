function test_dnd_symm(varargin)
%
% Validate the dnd symmetrisation, combination and rebin routines


%% Copied from template in test_multifit_horace_1

banner_to_screen(mfilename)

testdir=fileparts(mfilename('fullpath'));

%% Use sqw file on RAE's laptop to perform tests. Data saved to a .mat file on SVN server for validation by others.
% data_source='C:\Russell\PCMO\ARCS_Oct10\Data\SQW\ei140.sqw';
% proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';

%What we actually want to do is to simulate some cross-section that is
%symmetric so that we can compare results easily.
stiffness=80; gam=0.1; amp=10;

%To ensure some of the catches for dnd symmetrisation work properly, need
%to add some errorbars to all of the data points as well. Take from the
%original data. Errorbars are rescaled to be appropriate size for new
%signal array

% w3d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[0,1.4,100]);
% w3d_sqw=sqw_eval(w3d_sqw,@fake_cross_sec,[stiffness,gam,amp]);
% errs=w3d_sqw.data.pix(8,:); 
% w3d_sqw.data.pix(9,:)=errs;
% w3d_sqw=cut(w3d_sqw,[-1,0.025,1],[-1,0.025,1],[0,1.4,100]);
% w3d_d3d=d3d(w3d_sqw);
% 
% w2d_qe_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[0,1.4,100]);
% w2d_qe_sqw=sqw_eval(w2d_qe_sqw,@fake_cross_sec,[stiffness,gam,amp]);
% errs=w2d_qe_sqw.data.pix(8,:);
% w2d_qe_sqw.data.pix(9,:)=errs; 
% w2d_qe_sqw=cut(w2d_qe_sqw,[-1,0.025,1],[0,1.4,100]);
% w2d_qe_d2d=d2d(w2d_qe_sqw);
% 
% w2d_qq_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[30,40]);
% w2d_qq_sqw=sqw_eval(w2d_qq_sqw,@fake_cross_sec,[stiffness,gam,amp]);
% errs=w2d_qq_sqw.data.pix(8,:);
% w2d_qq_sqw.data.pix(9,:)=errs;
% w2d_qq_sqw=cut(w2d_qq_sqw,[-1,0.025,1],[-1,0.025,1]);
% w2d_qq_d2d=d2d(w2d_qq_sqw);
% 
% w1d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[30,40]);
% w1d_sqw=sqw_eval(w1d_sqw,@fake_cross_sec,[stiffness,gam,amp]);
% errs=w1d_sqw.data.pix(8,:);
% w1d_sqw.data.pix(9,:)=errs;
% w1d_sqw=cut(w1d_sqw,[-1,0.025,1]);
% w1d_d1d=d1d(w1d_sqw);
% 
% % 
% % %
% save(w3d_sqw,[testdir,filesep,'w3d_sqw.sqw']);
% save(w3d_d3d,[testdir,filesep,'w3d_d3d.sqw']);
% save(w2d_qe_sqw,[testdir,filesep,'w2d_qe_sqw.sqw']);
% save(w2d_qe_d2d,[testdir,filesep,'w2d_qe_d2d.sqw']);
% save(w2d_qq_sqw,[testdir,filesep,'w2d_qq_sqw.sqw']);
% save(w2d_qq_d2d,[testdir,filesep,'w2d_qq_d2d.sqw']);
% save(w1d_sqw,[testdir,filesep,'w1d_sqw.sqw']);
% save(w1d_d1d,[testdir,filesep,'w1d_d1d.sqw']);

%The above can now be read into the test routine directly.
w3d_sqw=read_sqw(fullfile(testdir,'w3d_sqw.sqw'));
w3d_d3d=read_dnd(fullfile(testdir,'w3d_d3d.sqw'));
w2d_qe_sqw=read_sqw(fullfile(testdir,'w2d_qe_sqw.sqw'));
w2d_qe_d2d=read_dnd(fullfile(testdir,'w2d_qe_d2d.sqw'));
w2d_qq_sqw=read_sqw(fullfile(testdir,'w2d_qq_sqw.sqw'));
w2d_qq_d2d=read_dnd(fullfile(testdir,'w2d_qq_d2d.sqw'));
w1d_sqw=read_sqw(fullfile(testdir,'w1d_sqw.sqw'));
w1d_d1d=read_dnd(fullfile(testdir,'w1d_d1d.sqw'));




%% Symmetrisation tests

%sqw symmetrisation:
w3d_sqw_sym=symmetrise_sqw(w3d_sqw,[0,0,1],[-1,1,0],[0,0,0]);
w2d_qe_sqw_sym=symmetrise_sqw(w2d_qe_sqw,[0,0,1],[-1,1,0],[0,0,0]);

cc=cut(w3d_sqw_sym,[-1,0.025,1],[-0.1,0.1],[0,1.4,100]);

if ~equal_to_tol(cc,w2d_qe_sqw_sym,-1e-8), assertTrue(false,'sqw symmetrisation fails due to cut rounding problem'), end

%at present this fails, due to problem in cut algorithm (somewhere)

%d2d symmetrisation:
w2_1=symmetrise_horace_2d(w2d_qe_d2d,[0,NaN]);
w2_2=symmetrise_horace_2d(w2d_qq_d2d,[-0.005,NaN]);

w2_1a=symmetrise_horace_2d(w2d_qe_d2d,[0,0,1],[-1,1,0],[0,0,0]);
w2_2a=symmetrise_horace_2d(w2d_qq_d2d,[0,0,1],[-1,1,0],[-0.005,-0.005,0]);

%confirm that if we symmetrise about an existing axis, then routines above
%are consistent.
if ~equal_to_tol(w2_1,w2_1a,-1e-8), assertTrue(false,'d2d symmetrisation about fixed midpoint failed'), end
if ~equal_to_tol(w2_2,w2_2a,-1e-8), assertTrue(false,'d2d symmetrisation about fixed midpoint failed'), end

%compare symmetrisation along a diagonal (shoelace vs sqw symm). These are
%actually unlikely to be the same, because the methodology is totally
%different...
%Diagonal symm axis
w2_2b=symmetrise_horace_2d(w2d_qq_d2d,[0,0,1],[0,1,0],[0,0,0]);
w2_2b_s=d2d(symmetrise_sqw(w2d_qq_sqw,[0,0,1],[0,1,0],[0,0,0]));

w2_2b=cut(w2_2b,[-1,0.025,1],[-1.0167,0.025,1.0333]);
w2_2b_s=cut(w2_2b_s,[-1.0125,0.025+3.5e-8,1],[-1.0167,0.025+3.5e-8,1.0333]);

%Is a solution to validating these running a fit with our original sqw
%function?
[wfit_qq,fitdata_qq]=fit_sqw(w2d_qq_sqw,@fake_cross_sec,[stiffness,gam,amp],[1,0,0]);%obviously this is fine
[wfit_2b,fitdata_2b]=fit_sqw(w2_2b,@fake_cross_sec,[stiffness,gam,amp],[1,0,0]);
[wfit_2b_s,fitdata_2b_s]=fit_sqw(w2_2b_s,@fake_cross_sec,[stiffness,gam,amp],[1,0,0]);

if ~equal_to_tol(fitdata_2b.p(1),fitdata_2b_s.p(1),-2.05e-2), assertTrue(false,'d2d symmetrisation about diagonal (non shoelace algorithm) failed'), end



%Random symm axis (ensure shoelace algorithm is actually tested)
w2_2c=symmetrise_horace_2d(w2d_qq_d2d,[0,0,1],[0.5,1,0],[0,0,0]);
w2_2c_s=d2d(symmetrise_sqw(w2d_qq_sqw,[0,0,1],[0.5,1,0],[0,0,0]));

%Not easy to validate this.
c1=cut(compact(w2_2c),[],[-1.4,-1.1]);
c2=cut(compact(w2_2c_s),[],[-1.4,-1.1]);

[wfit_c1,fitdata_c1]=fit_func(c1,@mgauss,[22,-0.015,0.07,22,-0.33,0.07],[1,0,1,1,1,1]);
[wfit_c2,fitdata_c2]=fit_func(c2,@mgauss,[22,-0.015,0.07,22,-0.33,0.07],[1,0,1,1,1,1]);

toterr=sqrt(fitdata_c1.sig.^2 + fitdata_c2.sig.^2);
fitdiff=abs(fitdata_c1.p - fitdata_c2.p);

if ~all(fitdiff<=1.2*toterr), assertTrue(false,'d2d symmetrisation about arbitrary axis (shoelace algorithm) failed'), end


%d1d symmetrisation (a whole lot easier)
w1_1=symmetrise_horace_1d(w1d_d1d,0.25);
w1_1s=symmetrise_sqw(w1d_sqw,[0,0,1],[-1,1,0],[0.25,0.25,0]);

acolor red
plot(w1_1);
acolor black
pp(w1_1s);

[wfit1_1,fitdata1_1]=fit_func(w1_1,@mgauss,[20,0.75,0.062,20,1.25,0.062],...
    [1,1,0,1,1,0],@quad_bg,[8.95,-5.3,0.1],[1,1,1],'keep',[0.5,1.5]);

[wfit1_1s,fitdata1_1s]=fit_func(d1d(w1_1s),@mgauss,[20,0.75,0.062,20,1.25,0.062],...
    [1,1,0,1,1,0],@quad_bg,[8.95,-5.3,0.1],[1,1,1],'keep',[0.5,1.5]);
    
toterr=sqrt(fitdata1_1.sig.^2 + fitdata1_1s.sig.^2);
fitdiff=abs(fitdata1_1.p - fitdata1_1s.p);

%NB - test here is very fiddly, the fitting to gaussians is not great, but
%we are within 2 s.d. on the peak position with suspiciously small
%errorbar...

if ~all(fitdiff<=2*toterr), assertTrue(false,'d1d symmetrisation about midpoint failed'), end






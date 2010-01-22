%Script file to test the various rebinning calculations.
%==========================================================================

%Test 1d case with coarser grid:
xin=[0:0.1:3]';
xcen=0.5.*(xin(1:end-1)+xin(2:end));
xout=[-0.45:0.2:3.55]';
sin=gauss(xcen,[10,0,2]);
ein=rand(size(sin)).*sqrt(sin);
%ein([1 5 9 17 22])=1000;%put certain errors to different values
nin=ones(size(sin)); nin([1,5,8,15,19])=0;
figure;
errorbar(xcen,sin,sqrt(ein),'or');
hold on

[sout,eout,nout]=rebin_1d_general(xin,xout,sin,ein,nin);
%figure;
errorbar(0.5.*(xout(1:end-1)+xout(2:end)),sout,sqrt(eout),'ob');

%Realise that until now we have been implicitly considering the case where
%the spacing of xout is larger than that of xin. However we should in
%principle be able to cope with rebinning on to a finer grid (resulting in
%larger errorbars). This will require some extra work.

%Test 1d case with finer grid:
xin=[0:0.1:2]';
xcen=0.5.*(xin(1:end-1)+xin(2:end));
xout=[-0.08:0.04:2.08]';
sin=gauss(xcen,[10,0,2]);
ein=0.1.*sqrt(sin);
nin=ones(size(sin)); nin([1,5,8,15,19])=0;
figure;
errorbar(xcen,sin,sqrt(ein),'or');
hold on

[sout,eout,nout]=rebin_1d_general(xin,xout,sin,ein,nin);
figure;
errorbar(0.5.*(xout(1:end-1)+xout(2:end)),sout,sqrt(eout),'ob');
%this seems to work now.

%Now test the completely general case, where the output and/or input grids
%are irregularly spaced (somewhat unlikely, but it could happen)
xin=[0 0.1 0.3 0.4 0.45 0.6 0.7 0.8 0.95 1.05 1.3 1.4 1.6 1.8 1.9 2];
xcen=0.5.*(xin(1:end-1)+xin(2:end));
xout=[0:0.05:1 1.3:0.3:2.2]';
sin=gauss(xcen,[10,0,2]);
ein=0.1.*sqrt(sin);
nin=ones(size(sin)); nin([1,5,8,15])=0;
figure;
errorbar(xcen,sin,sqrt(ein),'or');
hold on

[sout,eout,nout]=rebin_1d_general(xin,xout,sin,ein,nin);
%figure;
errorbar(0.5.*(xout(1:end-1)+xout(2:end)),sout,sqrt(eout),'ob');
%this also appears to work fine, which is a relief...

%The only issue appears to be due to rounding errors - e.g. if the uppermost bin
%boundary of the input data coincides with a bin boundary in the output
%then we can get an extra point at the end with a very large errorbar. This
%isn't too much of a problem for the 1d case, but it can result in
%misleading plots in the 2d case. Need to think about how to deal with this
%reliably.
%
%Solution is to set a tolerance check at the end of the function on the
%output errors. If any of them are a factor of 1000 greater than the
%maximum of the input errors then we assume they are spurious, and are
%therefore removed.
%
%NB must also implement this for the 2d case.



%==============
%Now that the 1d case works, we must vectorise the code so that it works
%for the 2d case. What we will do here is, instead of xin etc being
%vectors, they must be matrices. The bin boundary matrices must be those
%generated from the command "ndgrid".


xin_vec=[0:0.25:3];
xout_vec=[0:0.5:3.5];
yin_vec=[10:0.5:20];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[10 0 15 1 2]);
ein_mat=0.1.*sqrt(sin_mat);
nin_mat=ones(size(sin_mat));
%make a few elements have no pixels:
randmat=rand(size(nin_mat));
nin_mat(randmat<0.2)=0;
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar

[xout_mat,yout_mat,sout_mat,eout_mat,nout_mat]=rebin_2d_1axis(xin_mat,yin_mat,...
    xout_vec,sin_mat,ein_mat,nin_mat);

xout_cen=0.5.*(xout_mat(1:end-1,1:end-1)+xout_mat(2:end,2:end));
yout_cen=0.5.*(yout_mat(1:end-1,1:end-1)+yout_mat(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout_mat); shading flat; colormap jet; colorbar;

%===============
%Now test fine grid version of this:
xin_vec=[0:0.25:3];
xout_vec=[0:0.05:3.5];
yin_vec=[10:0.5:20];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[10 0 15 1 2]);
ein_mat=0.1.*sqrt(sin_mat);
nin_mat=ones(size(sin_mat));
%make a few elements have no pixels:
randmat=rand(size(nin_mat));
nin_mat(randmat<0.2)=0;
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar

[xout_mat,yout_mat,sout_mat,eout_mat,nout_mat]=rebin_2d_1axis(xin_mat,yin_mat,...
    xout_vec,sin_mat,ein_mat,nin_mat);

xout_cen=0.5.*(xout_mat(1:end-1,1:end-1)+xout_mat(2:end,2:end));
yout_cen=0.5.*(yout_mat(1:end-1,1:end-1)+yout_mat(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout_mat); shading flat; colormap jet; colorbar;
%seems to be OK

%=============================
%I think the way to rebin the 2nd axis is to transpose the various input
%matrices, and then use the same function as above
xin_vec=[0:0.25:3];
xout_vec=[0:0.5:3.5];
yin_vec=[10:0.5:20];
yout_vec=[10:1:20];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[10 0 15 1 2]);
sin_mat=rand(size(sin_mat)).*sin_mat;
ein_mat=0.1.*sqrt(sin_mat);
nin_mat=ones(size(sin_mat));
%make a few elements have no pixels:
randmat=rand(size(nin_mat));
nin_mat(randmat<0.2)=0;
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar

[xout_mat,yout_mat,sout_mat,eout_mat,nout_mat]=rebin_2d(xin_mat,yin_mat,...
    sin_mat,ein_mat,nin_mat,xout_vec,yout_vec);
caxis([0 5]);

xout_cen=0.5.*(xout_mat(1:end-1,1:end-1)+xout_mat(2:end,2:end));
yout_cen=0.5.*(yout_mat(1:end-1,1:end-1)+yout_mat(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout_mat); shading flat; colormap jet; colorbar;
caxis([0 5]);


%==========================================================================


%Now test dependent functions:

%=========================
%Test 1d combine:
xin1=[-3:0.1:3]';
xcen1=0.5.*(xin1(1:end-1)+xin1(2:end));
sin1=gauss(xcen1,[10,0,2]);
%ein1=rand(size(sin1)).*sqrt(sin1);
ein1=ones(size(sin1));
nin1=ones(size(sin1));
figure;
errorbar(xcen1,sin1,sqrt(ein1),'or');
hold on;
%
xin2=[-2:0.1:5]';
xcen2=0.5.*(xin2(1:end-1)+xin2(2:end));
sin2=gauss(xcen2,[10,0,2]);
%ein2=rand(size(sin2)).*sqrt(sin2);
ein2=ones(size(sin2));
nin2=ones(size(sin2));
errorbar(xcen2,sin2,sqrt(ein2),'ob');
%
[xout,yout,eout]=combine_1d(xin2,sin2,ein2,nin2,xin1,sin1,ein1,nin1,[]);
figure;
errorbar(0.5.*(xout(1:end-1)+xout(2:end)),yout,sqrt(eout),'ok');

%========================
%Test 1d symmetrisation:
xin1=[-4.0:0.1:3.0]';
xcen1=0.5.*(xin1(1:end-1)+xin1(2:end));
sin1=gauss(xcen1,[10,0,2]);
%ein1=rand(size(sin1)).*sqrt(sin1);
ein1=ones(size(sin1));
nin1=ones(size(sin1));
figure;
errorbar(xcen1,sin1,sqrt(ein1),'or');
%
[xout,yout,eout,nout]=symmetrise_1d(xin1,sin1,sqrt(ein1),nin1,4);
figure;
errorbar(0.5.*(xout(1:end-1)+xout(2:end)),yout,sqrt(eout),'ok');

%=======================
%Test 2d combine:
xin_vec=[0:0.25:4];
yin_vec=[10:0.5:25];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[10 0 15 1 2]);
%sin_mat=rand(size(sin_mat)).*sin_mat;
ein_mat=0.1.*sqrt(sin_mat);
nin_mat=ones(size(sin_mat));
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar
%
xin_vec2=[0:0.25:4];
yin_vec2=[10:0.5:25];
[xin_mat2,yin_mat2]=ndgrid(xin_vec2,yin_vec2);
xcen2=0.5.*(xin_mat2(1:end-1,1:end-1)+xin_mat2(2:end,2:end));
ycen2=0.5.*(yin_mat2(1:end-1,1:end-1)+yin_mat2(2:end,2:end));
%
sin_mat2=gauss_2d(xcen2,ycen2,[10 2 20 1 2]);
%sin_mat2=rand(size(sin_mat2)).*sin_mat2;
ein_mat2=0.1.*sqrt(sin_mat2);
nin_mat2=ones(size(sin_mat2));
figure;
pcolor(xcen2,ycen2,sin_mat2); shading flat; colormap jet; colorbar
%
[xout,yout,sout,eout,nout]=combine_2d(xin_mat,yin_mat,sin_mat,ein_mat,nin_mat,...
    xin_mat2,yin_mat2,sin_mat2,ein_mat2,nin_mat2,[0.8,3]);

xout_cen=0.5.*(xout(1:end-1,1:end-1)+xout(2:end,2:end));
yout_cen=0.5.*(yout(1:end-1,1:end-1)+yout(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout); shading flat; colormap jet; colorbar;

%=========================
%Test 2d symmetrise (x-axis only):
xin_vec=[-6:0.25:4];
yin_vec=[10:0.5:25];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[5 -2 15 0.5 2]) + gauss_2d(xcen,ycen,[5 2 15 0.5 2]);
%sin_mat=rand(size(sin_mat)).*sin_mat;
ein_mat=0.1.*sqrt(sin_mat);
%ein_mat=ones(size(sin_mat));
nin_mat=ones(size(sin_mat));
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar
%
[xout,yout,sout,eout,nout]=symmetrise_2d_1axis(xin_mat,yin_mat,sin_mat,ein_mat,nin_mat,0);
xout_cen=0.5.*(xout(1:end-1,1:end-1)+xout(2:end,2:end));
yout_cen=0.5.*(yout(1:end-1,1:end-1)+yout(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout); shading flat; colormap jet; colorbar

%=========================
%Test symmetrisation with 2 axes:
xin_vec=[-6:0.25:4];
yin_vec=[10:0.5:25];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[5 -2 15 0.5 2]) + gauss_2d(xcen,ycen,[5 2 15 0.5 2]);
%sin_mat=rand(size(sin_mat)).*sin_mat;
ein_mat=0.1.*sqrt(sin_mat);
%ein_mat=ones(size(sin_mat));
nin_mat=ones(size(sin_mat));
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar
%
[xout,yout,sout,eout,nout]=symmetrise_2d(xin_mat,yin_mat,sin_mat,ein_mat,nin_mat,[0,15]);
xout_cen=0.5.*(xout(1:end-1,1:end-1)+xout(2:end,2:end));
yout_cen=0.5.*(yout(1:end-1,1:end-1)+yout(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout); shading flat; colormap jet; colorbar
%It looks like this works, so I now have the complete set of functions
%required for this type of operation on 1d and 2d datasets with orthogonal
%cartesian axes.


%==========================================================================
%==========================================================================

%Next step is to begin considering the more complex generic rebin, where
%the axes of the input and output co-ordinates are not parallel. The main
%application of this is to rebin |Q| for powder data.
xin=[0; 2; 2.5; 0.5]; yin=[0; 0; 1; 1];
xin_old=xin; yin_old=yin;
for i=1:10
    xin=[xin xin_old+2*i];
    yin=[yin yin_old];
end
xin_old=xin; yin_old=yin;
for i=1:5
    xin=[xin xin_old+(0.5*i)];
    yin=[yin yin_old+i];
end

xout=[0; 4; 4; 0]; yout=[0; 0; 2; 2];
xout_old=xout; yout_old=yout;
for i=1:6
    xout=[xout xout_old+4*i];
    yout=[yout yout_old];
end
xout_old=xout; yout_old=yout;
for i=1:3
    xout=[xout xout_old];
    yout=[yout yout_old+2*i];
end

sin=1+xin(1,:).*yin(1,:); ein=ones(size(sin)); nin=ein;

figure;
patch(xin,yin,sin,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
caxis([0 60]);
axis([0 28 0 8]);
colorbar;

[sout,eout,nout]=rebin_shoelace(xin,yin,sin,ein,nin,xout,yout);
%This seems to work, at least superficially (although we need to convert
%errors to fractional errors, and then back again...)
figure;
patch(xout,yout,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
caxis([0 60]);
axis([0 28 0 8]);
colorbar;

%================================
%Now see what happens if we have output bins that are smaller than the
%input bins:
[sout2,eout2,nout2]=rebin_shoelace(xout,yout,sout,eout,nout,xin,yin);

figure;
patch(xin,yin,sout2,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
caxis([0 60]);
axis([0 28 0 8]);
colorbar;
%superficially this appears to work, but we must do some more rigorous
%error testing before we can be certain it works as advertised...


%=================================
%A good test is having a single input bin, and then a series of small
%output bins which run across it:
xin=[0; 4; 4; 0]; yin=[0; 0; 2; 2];

xout=[-2; -1; -1; -2]; yout=[0.5; 0.5; 1.5; 1.5];
xout_old=xout; yout_old=yout;
for i=1:7
    xout=[xout xout_old+i];
    yout=[yout yout_old];
end

sin=1; ein=ones(size(sin)); nin=ein;

figure;
patch(xin,yin,sin,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;
[sout,eout,nout]=rebin_shoelace(xin,yin,sin,ein,nin,xout,yout);
figure;
patch(xout,yout,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;

%================
%Compare to the simple 2d rebinning function:
xin_vec=[0 4];
xout_vec=[-2:6];
yin_vec=[0 2];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);

sin_mat=1;
ein_mat=1;
nin_mat=1;

[xout_mat,yout_mat,sout_mat,eout_mat,nout_mat]=rebin_2d_1axis(xin_mat,yin_mat,...
    xout_vec,sin_mat,ein_mat,nin_mat);
%so accounting for the lack of y-rebin (which I can't be arsed to do), the
%answer gives what we expect it to. So the shoelace is doing something
%funny with the errors... This has been corrected now.

%==========================================================================

%Next step is to do some speed testing to see where the bottlenecks are.
%For this to be meaningful we need a big dataset:
xin=[0; 2; 2.5; 0.5]; yin=[0; 0; 1; 1];
xin_old=xin; yin_old=yin;
for i=1:200
    xin=[xin xin_old+2*i];
    yin=[yin yin_old];
end
xin_old=xin; yin_old=yin;
for i=1:50
    xin=[xin xin_old+(0.5*i)];
    yin=[yin yin_old+i];
end

xout=[0; 4; 4; 0]; yout=[0; 0; 2; 2];
xout_old=xout; yout_old=yout;
for i=1:65
    xout=[xout xout_old+4*i];
    yout=[yout yout_old];
end
xout_old=xout; yout_old=yout;
for i=1:25
    xout=[xout xout_old];
    yout=[yout yout_old+2*i];
end

sin=1+xin(1,:).*yin(1,:); ein=ones(size(sin)); nin=ein;

figure;
patch(xin,yin,sin,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;
%
[sout,eout,nout]=rebin_shoelace(xin,yin,sin,ein,nin,xout,yout);
figure;
patch(xout,yout,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;

%Summary: no. input bins = 5151.
%         no. output bins = 1716.
%         time taken = 34 seconds.

%Redo with double number of input and output bins (i.e. extend twice as far
%along the x-axis):
%  no inputs = 10251
%  no outputs = 3406
%  time taken = 68.9 seconds. So very simply it appears that the time taken
%  scales as expected for this case.

%Now use doubled output bin number, but the original input bin number:
% no inputs = 5151
% no outputs = 3406
% time taken = 34.6 seconds (i.e. the preprocessing function does its job)

% Now use original output bin number and doubled input bin:
% no inputs = 10251
% no outputs = 1716
% time taken = 43 seconds

%==========================================================================

%Test rebinning on Mslice data:
spe_dir='C:\Russell\SrFe2As2\Merlin_Jun09\data\Normalised\';
par_file='C:\Russell\SrFe2As2\Merlin_Jun09\dummy.par';
phx_file='C:\Russell\SrFe2As2\Merlin_Jun09\one2one_091.phx';

cut_path='C:\Russell\SrFe2As2\Merlin_Jun09\cuts\';
slice_path='C:\Russell\SrFe2As2\Merlin_Jun09\slices\';

spe50_cpara=[spe_dir,'mer_50meV_6K.spe'];
spe100_cpara=[spe_dir,'mer_100meV_6K.spe'];
spe180_cpara=[spe_dir,'mer_180meV_6K.spe'];
spe300_cpara=[spe_dir,'mer_300meV_6K.spe'];%have not yet done anything with the Ei=300 data
spe450_cpara=[spe_dir,'mer_450meV_6K.spe'];
spe450_cpara_subs=[spe_dir,'test_subtraction.spe'];


ei50=50.434; ei100=100.45; ei180=179.07; ei450=442.846; ei300=300;
emode=1;
alatt=[5.57,5.51,12.298];
angdeg=[90,90,90];
% u=[0.999,-0.0349,0];
% v=[0,0,1];
u=[0.9996,-0.0179,-0.0458];%NB this has been changed following analysis of orientation cuts
v=[0.0091,-0.016,0.9992];

% Control the output
make_cuts=true;
write_cut=true;

make_slices=true;
write_slices=true;

mslice_load_data (spe450_cpara_subs, phx_file, ei450, emode, 'S(Q,w)', '')
%mslice_sample(alatt,angdeg,u,v,-93)
mslice_sample(alatt,angdeg,u,v,-90)
mslice_calc_proj([1,0,0],[0,1,0],[0,0,0,1],'Q_H','Q_K','E')

%====================
test_mslice_rebin(1)=slice_2d (fromwindow,[0,0.03,2],[-1,0.05,1],[200,220],...
            'plot',0,'range',[0 1]);
keep;
test_mslice_rebin(2)=slice_2d (fromwindow,[0,0.1,2],[-1,0.1,1],[200,220],...
            'plot',0,'range',[0 1]);
keep;
%
%Now rebin the first one:
dx=diff(test_mslice_rebin(1).vx) /2;
xin_vec=test_mslice_rebin(1).vx(1:end-1) - dx;
xin_vec=[xin_vec (test_mslice_rebin(1).vx(end)-dx(end)) (test_mslice_rebin(1).vx(end)+dx(end))]';
dy=diff(test_mslice_rebin(1).vy) /2;
yin_vec=test_mslice_rebin(1).vy(1:end-1) - dy;
yin_vec=[yin_vec (test_mslice_rebin(1).vy(end)-dy(end)) (test_mslice_rebin(1).vy(end)+dy(end))]';
sin=test_mslice_rebin(1).intensity;
ein=test_mslice_rebin(1).error_int;
nin=double((~isnan(sin) & ~isnan(ein)) &  ein~=0);
xout=[-0.1:0.1:2.1]'; yout=[-1.1:0.1:1.1]';
[xin,yin]=ndgrid(xin_vec,yin_vec);
%
ein=ein.*sin;%convert errors here so that we force program to deal with absolute errors.
[xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,sin',ein',nin',xout,yout);

xout_cen=0.5.*(xnew(1:end-1,1:end-1)+xnew(2:end,2:end));
yout_cen=0.5.*(ynew(1:end-1,1:end-1)+ynew(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout); shading flat; colormap jet; colorbar;
sout_p=sout';
caxis([0 1]);
%dealing with this has highlighted 2 points:
% 1 - Mslice rebins according to error, not fractional error. Discuss with
%Toby which way is right...
% 2 - Were getting problems originally because we were not checking for
% NaNs in the input signal/error matrices. This has now been corrected.


%==========================================================================

%Also speed test the 2d cartesian rebinning:
xin_vec=[0:0.01:10];
xout_vec=[-1:0.05:11];
yin_vec=[0:0.05:20];
yout_vec=[-1:0.3:21];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[10 5 8 3 6]);
sin_mat=rand(size(sin_mat)).*sin_mat;
ein_mat=0.1.*sqrt(sin_mat);
nin_mat=ones(size(sin_mat));
%make a few elements have no pixels:
randmat=rand(size(nin_mat));
nin_mat(randmat<0.2)=0;
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar
caxis([0 5]);

[xout_mat,yout_mat,sout_mat,eout_mat,nout_mat]=rebin_2d(xin_mat,yin_mat,...
    sin_mat,ein_mat,nin_mat,xout_vec,yout_vec);


xout_cen=0.5.*(xout_mat(1:end-1,1:end-1)+xout_mat(2:end,2:end));
yout_cen=0.5.*(yout_mat(1:end-1,1:end-1)+yout_mat(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout_mat); shading flat; colormap jet; colorbar;
caxis([0 5]);

%input signal has 1000x400 elements. output has 270x73 elements.
%time taken = 3.85s

%==========================================================================
%Aside - it would be good to create a new colourmap that is nicer than
%Radu's one that works in both colour and b/w. Have seen one that goes from
%black to white through shades of blue/turqoise.
newmap=ones(20,3);
newcol=linspace(0,1,20);
newmap(:,1)=newcol';
newmap(:,2)=newcol';
figure;
pcolor(xout_cen,yout_cen,sout_mat); shading flat; colormap(newmap); colorbar;
caxis([0 5]);

%==========================================================================

%Test my 2d rebinning against Libisis IXTdataset2d rebinning function:

%First set up, and then use RAE method:
xin_vec=[0:0.25:3];
xout_vec=[0:0.5:3.5];
yin_vec=[10:0.5:20];
yout_vec=[10:1:20];
[xin_mat,yin_mat]=ndgrid(xin_vec,yin_vec);
xcen=0.5.*(xin_mat(1:end-1,1:end-1)+xin_mat(2:end,2:end));
ycen=0.5.*(yin_mat(1:end-1,1:end-1)+yin_mat(2:end,2:end));
%
sin_mat=gauss_2d(xcen,ycen,[10 0 15 1 2]);
sin_mat=rand(size(sin_mat)).*sin_mat;
ein_mat=0.1.*sqrt(sin_mat);
nin_mat=ones(size(sin_mat));
%make a few elements have no pixels:
randmat=rand(size(nin_mat));
nin_mat(randmat<0.2)=0;
figure;
pcolor(xcen,ycen,sin_mat); shading flat; colormap jet; colorbar
caxis([0 5]);
[xout_mat,yout_mat,sout_mat,eout_mat,nout_mat]=rebin_2d(xin_mat,yin_mat,...
    sin_mat,ein_mat,nin_mat,xout_vec,yout_vec);


xout_cen=0.5.*(xout_mat(1:end-1,1:end-1)+xout_mat(2:end,2:end));
yout_cen=0.5.*(yout_mat(1:end-1,1:end-1)+yout_mat(2:end,2:end));
figure;
pcolor(xout_cen,yout_cen,sout_mat); shading flat; colormap jet; colorbar;
caxis([0 5]);

%====
%Now use IXT method:
[xoutIXT,youtIXT,soutIXT,eoutIXT]=rebin_2d_IXT(xin_vec,yin_vec,sin_mat,ein_mat,xout_vec,yout_vec);

[xoutIXT,youtIXT]=ndgrid(xoutIXT,youtIXT);
%plot it
xout_cenIXT=0.5.*(xoutIXT(1:end-1,1:end-1)+xoutIXT(2:end,2:end));
yout_cenIXT=0.5.*(youtIXT(1:end-1,1:end-1)+youtIXT(2:end,2:end));
figure;
pcolor(xout_cenIXT,yout_cenIXT,soutIXT); shading flat; colormap jet; colorbar;
caxis([0 20]);
%
%This shows that the speed of the two pieces of code, at least for this
%example, is pretty much identical. However the outputs are totally
%different - this is in part due to how we handle errorbars (fractional
%error vs absolute error) - however a bigger issue appears to be the fact
%that the IXT method sums the signal/partial signal from all the contributing
%input bins and puts it into the output bin - i.e. the IXT method does not
%appear to normalise upon rebinning.

%==========================================================================

%Now do a speed test on a much larger dataset:
xin=[0; 2; 2.5; 0.5]; yin=[0; 0; 1; 1];
xin_old=xin; yin_old=yin;
for i=1:49
    xin=[xin xin_old+2*i];
    yin=[yin yin_old];
end
xin_old=xin; yin_old=yin;
for i=1:99
    xin=[xin xin_old+(0.25*i)];
    yin=[yin yin_old+i];
end

xout=[0; 4; 4; 0]; yout=[0; 0; 2; 2];
xout_old=xout; yout_old=yout;
for i=1:29
    xout=[xout xout_old+4*i];
    yout=[yout yout_old];
end
xout_old=xout; yout_old=yout;
for i=1:55
    xout=[xout xout_old];
    yout=[yout yout_old+2*i];
end

sin=1+xin(1,:).*yin(1,:); ein=ones(size(sin)); nin=ein;

figure;
patch(xin,yin,sin,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;
%
[sout,eout,nout]=rebin_shoelace(xin,yin,sin,ein,nin,xout,yout);
figure;
patch(xout,yout,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;

%==========================================================================

%Do a more realistic speed test, where we use some MARI data:
cd 'C:\SVN_area\Horace_sqw_test\Powder_development2\';
[data,det,keep,det0,pix]=powder_get_data(...
    'C:\Russell\LaOFeAs\Mari_Jun08\Data\AbsUnits_SPE\MAR_Sum_DRP059_25meV.spe',...
    'C:\Russell\LaOFeAs\Mari_Jun08\Map_and_phx\phx_files\mari_resa.phx',...
    'C:\Russell\LaOFeAs\Mari_Jun08\Map_and_phx\Map_files\mari_res.map');

proj=[1,4];%(Q,E) axes
ei=25;
outbins=powder_calcproj(data,det,proj,ei);
tth=outbins.bin1; en=outbins.bin2;
%
sw_x=tth(1:(end-1),1:(end-1)); se_x=tth(1:(end-1),2:end);
nw_x=tth(2:end,1:(end-1)); ne_x=tth(2:end,2:end);
sw_y=en(1:(end-1),1:(end-1)); se_y=en(1:(end-1),2:end);
nw_y=en(2:end,1:(end-1)); ne_y=en(2:end,2:end);

sw_x=reshape(sw_x,1,numel(sw_x)); se_x=reshape(se_x,1,numel(se_x));
nw_x=reshape(nw_x,1,numel(nw_x)); ne_x=reshape(ne_x,1,numel(ne_x));
sw_y=reshape(sw_y,1,numel(sw_y)); se_y=reshape(se_y,1,numel(se_y));
nw_y=reshape(nw_y,1,numel(nw_y)); ne_y=reshape(ne_y,1,numel(ne_y));

xmat=[sw_x; se_x; ne_x; nw_x];
ymat=[sw_y; se_y; ne_y; nw_y];

cmat=reshape(data.S,[1,numel(data.S)]);
emat=reshape(data.ERR,[1,numel(data.ERR)]);
npix=double(cmat~=0 & emat~=0);
figure;
patch(xmat,ymat,cmat,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
caxis([0 10]);

xbin_test=[0; 0.1; 0.1; 0]; ybin_test=[-10; -10; -9; -9];
xbin_test_old=xbin_test; ybin_test_old=ybin_test;
for i=1:72
    xbin_test=[xbin_test xbin_test_old+(0.1*i)];
    ybin_test=[ybin_test ybin_test_old];
end
xbin_test_old=xbin_test; ybin_test_old=ybin_test;
for i=1:32
    xbin_test=[xbin_test xbin_test_old];
    ybin_test=[ybin_test ybin_test_old+i];
end

[sout,eout,nout]=rebin_shoelace(xmat,ymat,cmat,emat,npix,xbin_test,ybin_test);
figure;
patch(xbin_test,ybin_test,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;

%With the old shoelace algorithm this takes 222 seconds, of which 177
%seconds was spent calculating intersection points
%
% Unforfunately it appears that the calculation has gone wrong, and
% produced zeros where it should not have done.

%Retry with different signal and error matrices:
cmat2=xmat(1,:) .* ymat(1,:);
emat2=rand(size(cmat2)).*10;
nmat2=ones(size(cmat2));
figure;
patch(xmat,ymat,cmat2,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
[sout,eout,nout]=rebin_shoelace(xmat,ymat,cmat2,emat2,nmat2,xbin_test,ybin_test);
figure;
patch(xbin_test,ybin_test,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
%this looks to have worked, so there is a problem somewhere with dealing
%with zeros (either in signal, error or npix arrays)

%Store convex hull method:
sout_conv=sout; eout_conv=eout; nout_conv=nout;%81s
%
%Store old method:
sout_old=sout; eout_old=eout; nout_old=nout;%222 seconds

%Compare:
sdiff=(sout_old-sout_conv)./sout_old; ediff=(eout_old-eout_conv)./eout_old;
ndiff=(nout_old-nout_conv)./nout_old;
%there are a couple of points that are not quite the same. however there
%are only 10 points where the signal is >0.1% different between the 2
%methods
%
% The new program is doing something wrong regarding going along the chains
% to find intersection points. Now fixed this.
%
% Code acceleration means we can get the timing down to ~80 seconds for the
% above grid.


%=================
%now need to work out what is going wrong with the empty pixels when we try
%to rebin the real MARI data.
[sout,eout,nout]=rebin_shoelace(xmat,ymat,cmat,emat,npix,xbin_test,ybin_test);
figure;
patch(xbin_test,ybin_test,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;
%have now fixed this. Was due to not getting rid of NaNs and points with
%zero errorbar.

%==================

%Now do some proper profiling. This means we need to look at using
%different output bins:

%Previously we found that with 85500 input bins and 2409 output bins it
%takes 81 seconds.

%With 4983 output bins it took 129 seconds.

%With 9933 output bins it took 222 seconds.

xbin_test=[0; 0.025; 0.025; 0]; ybin_test=[-10; -10; -9; -9];
xbin_test_old=xbin_test; ybin_test_old=ybin_test;
for i=1:300
    xbin_test=[xbin_test xbin_test_old+(0.025*i)];
    ybin_test=[ybin_test ybin_test_old];
end
xbin_test_old=xbin_test; ybin_test_old=ybin_test;
for i=1:32
    xbin_test=[xbin_test xbin_test_old];
    ybin_test=[ybin_test ybin_test_old+i];
end

[sout,eout,nout]=rebin_shoelace(xmat,ymat,cmat,emat,npix,xbin_test,ybin_test);
figure;
patch(xbin_test,ybin_test,sout,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;
caxis([0 10]);

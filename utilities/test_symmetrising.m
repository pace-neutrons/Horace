%Script file to test ideas for symmetrisation of data.

data_source_midE='/data/scratch/sqs43493/MnSi_Nov08_Ei180_normalised.sqw';
data_source_lowE='/data/scratch/sqs43493/MnSi_May08/MnSi_May_normalised_new.sqw';%note we have regenerated
%the low energy dataset at last, so that H and K are no longer exchanged.
data_source_highE='/data/scratch/sqs43493/MnSi_Nov08_Ei380_norm_test.sqw';
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr'; proj.uoffsef=[0,0,0,0];

test_data=cut_sqw(data_source_lowE,proj,[0.9,1.1],[-2,0.05,2],[1.9,2.1],[25,30]);
acolor blue
plot(test_data);

testref=symmetrise_test(test_data,[1,0,0],[0,0,1],[0,0,0]);
acolor red
pp(testref);
keep_figure;

%this seems to work!
%
%See if it works on a 2d object:
test_data_2d=cut_sqw(data_source_lowE,proj,[-1,0.05,3],[-2,0.05,2],[1.9,2.1],[25,30]);
plot(test_data_2d);
keep_figure;

testref_2d=symmetrise_test(test_data_2d,[1,0,0],[0,0,1],[0,0,0]);
plot(testref_2d);
keep_figure;
%this also works, which is nice!

test_data_3d=cut_sqw(data_source_lowE,proj,[-1,0.05,3],[-2,0.05,2],[1.9,2.1],[10,0,20]);

%===============================

%Now work on the dnd case:
test_data_d2d=d2d(test_data_2d);
test_data_d3d=d3d(test_data_3d);
%

test2d=symmetrise_dnd_test(test_data_d2d,[0,0,1],[1,1,0],[0,0,0]);
plot(test2d); lz 0 2;
keep_figure;

aftersymcut=cut(test2d,[],[0.5,1]);
presymcut=cut(test_data_d2d,[],[0.5,1]);

acolor red
plot(presymcut);
acolor black
pp(aftersymcut);
keep_figure;
%Looking at the errorbars, we see there is something wrong here.

presymcut2=cut(test_data_d2d,[],[-1,-0.5]);
sumcut=mrdivide(plus(presymcut,presymcut2),2);
acolor blue
plot(sumcut);
acolor black
pp(aftersymcut);
keep_figure;

%this lot needs more testing, as well as some serious acceleration.

%===============================================

%Look at simpler cases:
testout=symmetrise_2d_leftright(test_data_d2d,-0.02);
plot(test_data_d2d); lz 0 2; keep_figure;
plot(testout); lz 0 2; keep_figure;
%
presymcut=cut(test_data_d2d,[],[0.5,0.8]);
aftersymcut=cut(testout,[],[0.5,0.8]);
acolor red
plot(presymcut);
acolor black
pp(aftersymcut);
keep_figure;
%
getin=get(presymcut); getout=get(aftersymcut);
ratio=getin.e ./ getout.e;
%
%Looks like this has done what we expected, which is nice.

%===
%Now test updown version:
testout=symmetrise_2d_updown(test_data_d2d,-1);
plot(test_data_d2d); lz 0 2; keep_figure;
plot(testout); lz 0 2; keep_figure;
%
presymcut=cut(test_data_d2d,[0.5,0.8],[]);
aftersymcut=cut(testout,[0.5,0.8],[]);
acolor red
plot(presymcut);
acolor black
pp(aftersymcut);
keep_figure;
%this also looks OK!

%==========================================================================
%==========================================================================

%This code development is all very well, but what we really want is a
%generic tool to rebin 1 or 2 dimensional datasets on to a new grid. The 1d
%case is actually pretty easy, and is probably superior to the existing
%libisis stuff (albeit somewhat slower).

%The 2d case is somewhat more complicated, in that there are several
%different ways of doing the rebinning. The shoelace algorith actually only
%needs to be used if the axes of the 2 grids are not parallel (e.g. natural
%binning in (|Q|,E) co-ordinates in mslice powder mode). 
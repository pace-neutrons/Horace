%% Horace as an extensible framework

%==== A special case based on analysis in Ewings et al, Phys. Rev. B 94,
%014405 (2016). %============

%Define a trajectory in Q-space and do dispersion plots for CE model:
aa=sqrt(3.8483*3.8514);  % geometric mean of a and b
bb=aa;
cc=3.7481;
lattice=[aa,bb,cc,90,90,90];

rlp=[0,0,0;  0.125,0.125,0;  0,0.25,0;  0,0,0;  -0.125,0.125,0;  0,0.25,0;  0,0.25,0.25;  0,0,0;  0,0,0.25];
rlp_lab={'G','X','M','G','Y','M','L','G','Z'};

% Initial
% -------
%ds=0.2;
ds=0;
fj2=0;
fj3=0;
pin=[9.01,fj2,fj3,0.45,2.09,2.09,0.0727,0];%Exchange parameters with no further neighbour coupling
%and no charge disproportionation.

%Use noplot just to do the calculation:
[w1,iref]=dispersion_plot(lattice,rlp,@co_2_ds_dispersion,pin,'noplot','labels',rlp_lab);

%Plot without structure factors
acolor k
dl(w1)

%Notice that wref is actually a 1-by-4 array, because in this model there
%are 4 spin wave branches.

%==
%Now set further neighbour terms to be non-zero:
pref=[9.01,0.93,-0.97,0.45,2.09,2.09,0.0727,0];
[wref,iref]=dispersion_plot(lattice,rlp,@co_2_ds_dispersion,pref,'noplot','labels',rlp_lab);

acolor r
pl(wref)

%===
%Test the effect of setting charge disporportionation to be non-zero, and
%further neighbour terms to be zero:
ds=0.2;
fj2=0;
fj3=0;
pinit=[9.01,fj2,fj3,0.45,2.09,2.09,0.0727,ds];

[wtest,iref]=dispersion_plot(lattice,rlp,@co_2_ds_dispersion,pinit,'noplot','labels',rlp_lab);

%Plot without structure factors
acolor b
pl(wtest)

%================
%Repeat above with structure factors:
ecent=[0,0.5,80];
fwhh=2;
disp2sqw_plot(lattice,rlp,@co_2_ds_dispersion,pin,ecent,fwhh,'labels',rlp_lab); keep_figure;
disp2sqw_plot(lattice,rlp,@co_2_ds_dispersion,pinit,ecent,fwhh,'labels',rlp_lab); keep_figure;
disp2sqw_plot(lattice,rlp,@co_2_ds_dispersion,pref,ecent,fwhh,'labels',rlp_lab); keep_figure;

%======================

%Now try fitting one model to the other, i.e. can we get the same
%dispersion with zero further neighbour exchange terms by varying the
%charge disporportionation?

% Create 'data points' with fake error bars
const=0.2;      % create error bars as a fraction of energy plus a constant
frac=0.0;

np=numel(wref(1).x);%this is the same for all of the wref
nd=numel(wref);
x=zeros(np,nd);     % Purely dummy as we don't use x in the function evaluation
y=zeros(np,nd);
e=zeros(np,nd);
for i=1:nd
    y(:,i)=wref(i).signal;
    e(:,i)=const+frac*wref(i).signal;%in fact we just set the errorbar to be a constant.
end

%Reference parameter set (no charge disprop, non-zero nnn exch)
pref=[9.01,0.93,-0.97,0.45,2.09,2.09,0.0727,0];

%Initial guess for charge disprop:
ds=0.127;
fj2=0;
fj3=0;
pinit=[9.01,fj2,fj3,0.45,2.09,2.09,0.0727,ds];

%Decide which parameters to vary.

%We will start by fixing j2 and j3 to be zero and allow ds to vary:
pfree=[1,0,0,1,1,1,0,1];    % alter the fixed parameters to get the results below
%pbind=[];
pbind={{5,6}};     % if varying jc

% Now perform fit
[wfit,fitpar]=multifit(x, y, e, @en_calc, {pinit,@co_2_ds_dispersion,lattice,rlp}, pfree, pbind, 'list',2);
pfit=fitpar.p;

%Some jiggery pokery to make a plot of the output
[wfit,iref]=dispersion_plot(lattice,rlp,@co_2_ds_dispersion,pfit,'noplot','labels',rlp_lab);

acolor black
dl(wref)
acolor red
pl(wfit)

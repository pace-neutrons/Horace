ff0 = IXX_moderator(10,13,'ikcarp',[5,25,0.4]);

ffslim = ff0; ffslim.slot_width = 0.010;
ffwide = ff0; ffwide.slot_width = 0.031;

t = -40:0.001:40;
y = pulse_shape (ff0,t); w0=IX_dataset_1d(t,y);
y = pulse_shape (ffwide,t); ww=IX_dataset_1d(t,y);
y = pulse_shape (ffslim,t); ws=IX_dataset_1d(t,y);

acolor k b r
dl([w0,ww,ws])


% Test distributions
% -------------------

n=1e7;

obj = ffslim;

y = pulse_shape (obj,t); wshape=IX_dataset_1d(t,y);
area=integrate(wshape);
wdistr = area.val * samp2distr(obj.rand(n,1));
acolor r
dl(wshape)
acolor b
ph(wdistr)



%==================================================
% Test shape of distribution

pp=[3,20,0.4];
tmax=10*max(pp);
npnt=200;

t=0:0.001:tmax;

mm=IX_moderator(0,0,'ikcarp',pp);
y=pulse_shape(mm,0,t);
w=IX_dataset_1d(t,y);

mmfast=IX_moderator(0,0,'ikcarp',[pp(1),0,0]);
y=pulse_shape(mmfast,0,t);
wfast=(1-pp(3))*IX_dataset_1d(t,y);

mmslow=IX_moderator(0,0,'ikcarp',[pp(1),pp(2),1]);
y=pulse_shape(mmslow,0,t);
wslow=pp(3)*IX_dataset_1d(t,y);

acolor b r k
dl([wfast,wslow,w])


tsamp = ikcarp_pdf_xvals (npnt, pp(1), pp(2));
wsamp = IX_dataset_1d(tsamp,zeros(size(tsamp)));
pm(wsamp)
numel(tsamp)



%==================================================
% Compare old and new

% ikcarp
pp=[3,20,0.4];
tmax=10*max(pp);
npnt=200;

t=0:0.001:tmax;

mm=IX_moderator(0,0,'ikcarp',pp);
yold=pulse_shape(mm,0,t);
wold=IX_dataset_1d(t,yold);

nn=IXX_moderator(0,0,'ikcarp',pp);
ynew=pulse_shape(nn,t);
wnew=IX_dataset_1d(t,ynew);

acolor r
dl(wold)
acolor k
pl(wnew)


% ikcarp_param
pp=[0.04,25,0.4];
tmax=10*max(pp);
npnt=200;

t=0:0.001:tmax;

mm=IX_moderator(0,0,'ikcarp_param',pp);
yold=pulse_shape(mm,100,t);
wold=IX_dataset_1d(t,yold);

nn=IXX_moderator(0,0,'ikcarp_par',pp,'uniform',[],0,0,0,0,100);
ynew=pulse_shape(nn,t);
wnew=IX_dataset_1d(t,ynew);

acolor r
dl(wold)
acolor k
pl(wnew)



%==================================================
% Sampling

% ikcarp
pp=[3,20,0.4];
tmax=10*max(pp);
npnt=200;

t=0:0.001:tmax;

nn=IXX_moderator(0,0,'ikcarp',pp);
ynew=pulse_shape(nn,t);
wnew=IX_dataset_1d(t,ynew);

tsamp = rand(nn,1e7,1);
wsamp = samp2distr(tsamp);
 
acolor r
dl(wnew)
acolor k
ph(wsamp)




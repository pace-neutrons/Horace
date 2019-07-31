ff=IXX_fermi_chopper(10,600,0.049,1.3,0.0028);

ff500 = ff; ff500.energy = 500; % gamma = eps
ff200 = ff; ff200.energy = 200; % gamma < 1
ff163 = ff; ff163.energy = 163; % gamma = 1-eps
ff162 = ff; ff162.energy = 162; % gamma = 1+eps
ff100 = ff; ff100.energy = 100; % gamma = 1.64
ff50 = ff;  ff50.energy = 50;   % gamma = 2.86

t = -20:0.001:20;
y = pulse_shape (ff500,t); w500=IX_dataset_1d(t,y);
y = pulse_shape (ff200,t); w200=IX_dataset_1d(t,y);
y = pulse_shape (ff163,t); w163=IX_dataset_1d(t,y);
y = pulse_shape (ff162,t); w162=IX_dataset_1d(t,y);
y = pulse_shape (ff100,t); w100=IX_dataset_1d(t,y);
y = pulse_shape (ff50,t); w50=IX_dataset_1d(t,y);

acolor k b r m g c
dl([w500,w200,w163,w162,w100,w50])

% auto-time:
[y,t] = pulse_shape (ff163); wtmp=IX_dataset_1d(t,y);
dl([w163,wtmp])


% Test distributions
% -------------------

n=1e7;

obj = ff200;

y = pulse_shape (obj,t); wshape=IX_dataset_1d(t,y);
area=integrate(wshape);
wdistr = area.val * samp2distr(obj.rand(n,1));
acolor r
dl(wshape)
acolor b
ph(wdistr)






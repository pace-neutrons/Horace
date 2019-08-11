ff0 = IXX_doubledisk_chopper(10,280,0.28,0.020,0.020);

ffslim = ff0; ffslim.slot_width = 0.010;
ffwide = ff0; ffwide.slot_width = 0.031;

t = -40:0.001:40;
y = pulse_shape (ff0,t); w0=IX_dataset_1d(t,y);
y = pulse_shape (ffwide,t); ww=IX_dataset_1d(t,y);
y = pulse_shape (ffslim,t); ws=IX_dataset_1d(t,y);

acolor k b r
dl([w0,ww,ws])

% Auto-times:
[y,t] = pulse_shape (ff0); w0=IX_dataset_1d(t,y);
[y,t] = pulse_shape (ffwide); ww=IX_dataset_1d(t,y);
[y,t] = pulse_shape (ffslim); ws=IX_dataset_1d(t,y);

acolor k b r
dl([w0,ww,ws])
pm([w0,ww,ws])


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






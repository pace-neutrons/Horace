function [ok, sig_est, dw, dwchi] = is_histogram_equivalent (w1, w2, fac)
% Compare two histograms assumed to contain poisson counts in each bin
%
%   >> [ok, sig_est] = is_histogram_equivalent (w1,w2)
%
% Test passes if the differences in each bin, normalised by error bars, form
% a distribution with stndard deviation <= fac. We should expect std = 1; the
% acceptable tolerance depends ont he number of samples.
%
% For this function to be useful, need about many points in the histogram
% and many counts in each bin

w2reb = rebin(w2,w1);

dw = w1 - w2reb;     % catch case of w1,w2 having different x axes
rat = dw.signal./dw.error;

dwchi = dw;
dwchi.signal = rat;
dwchi.error = ones(size(rat));

sig_est = std(rat(isfinite(rat)));
ok = (sig_est<=fac);

function [mean_val, sig_mean, sig_val, sig_sig, cov_val, minval, maxval] = sampling_stats (X)
% Get estimate of some statistical quantities for a set of observations
%
%   >> [val, err] = estimator (arr)
%
% Input:
% ------
%   X       Array of values: size is [N, nvar]
%           - N = number of observations
%           - nvar = number of random variables
%
% Output:
% -------
%   mean_val    Estimated mean of values (row vector)
%   sig_mean    Estimated standard error on mean (row vector)
%   sig_val     Estimated standard error of values (row vector)
%   sig_sig     Estimated standard error on standard error (row vector)
%   cov_val     Estimated covariance matrix of values
%   minval      Minimum value (row vector)
%   maxval      Maximum value (row vector)
%
% See:
% - CR Rao (1973) Linear Statistical Inference and its Applications 2nd Ed, John Wiley & Sons, NY
% - https://stats.stackexchange.com/questions/156518/what-is-the-standard-error-of-the-sample-standard-deviation


sz = size(X);
if numel(sz)>2 || sz(1)<2 || sz(2)<1
    error('Observations must form a 2D array of at least one column and two observations')
end
N = sz(1);

% Min and max values:
minval = min(X, [], 1);
maxval = max(X, [], 1);

% Get mean and estimated error on mean
Xmean = mean(X,1);  % ensures mean is performed down the columns
Xcov = cov(X);      % normalise by N-1
Xsig = sqrt(diag(Xcov)');

mean_val = Xmean;
sig_val = Xsig;
cov_val = Xcov;
sig_mean = Xsig / sqrt(N);

% Get estimated errors on diagonal of covariance
dX = X - Xmean;
mu4 = mean(dX.^4,1);
var_var = (mu4 - ((N-3)/(N-1))*(Xsig.^4)) / N;

sig_sig = sqrt(var_var) ./ (2*Xsig);

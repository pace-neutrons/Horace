function [mean_val, sig_mean, sig_val, sig_sig, cov_val, sig_cov, minval, maxval] = ...
    sampling_statistics (X)
% Get estimate of some statistical quantities for a set of observations
%
%   >> [mean_val, sig_mean, sig_val, sig_sig, cov_val, minval, maxval] = ...
%                                                       sampling_statistics (X)
%
% Input:
% ------
%   X       Matrix of values; each column represents a random variable and the 
%           rows represent observations. That is, if size(X) = [N, nvar] then
%           - N = number of observations
%           - nvar = number of random variables
%
% Output:
% -------
%   mean_val    Estimated means of values (row vector length nvar)
%   sig_mean    Estimated standard errors on means (row vector length nvar)
%   sig_val     Estimated standard errors of values (row vector length nvar)
%   sig_sig     Estimated standard errors on standard errors (row vector length nvar)
%   cov_val     Estimated covariance matrix of values (matrix size [nvar,nvar])
%   minval      Minimum value (row vector length nvar)
%   maxval      Maximum value (row vector length nvar)
%
% For details of the algorithms (and in particular the estimate of stnadard 
% errors on standard errors) see:
% - CR Rao (1973) Linear Statistical Inference and its Applications 2nd Ed, John Wiley & Sons, NY
% - https://stats.stackexchange.com/questions/156518/what-is-the-standard-error-of-the-sample-standard-deviation


sz = size(X);
if numel(sz)>2 || sz(1)<2 || sz(2)<1
    error('HERBERT:sampling_statistics:invalid_argument', ['Observations ',...
        'must form a 2D array of at least one column and two observations'])
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
sig_mean = Xsig / sqrt(max([1,N-1]));

% Get estimated errors on standard deviations (i.e. sqrt of diagonal of
% covariance)
dX = X - Xmean;
mu4 = mean(dX.^4,1);
var_var = (mu4 - ((N-3)/(N-1))*(Xsig.^4)) / N; % see references in leading comments

sig_sig = sqrt(var_var) ./ (2*Xsig);    % use delta method on var_var

% Get estimated errors on covariance matrix elements
% Simple calculation lead to 
%   Var(cov(x,y)) = (<((x-<x>)(y-<y>))^2> - <(x-<x>)(y-<y>)>^2) / N
% This is *almost* the same as the expression for when x==y used above, except
% that a factor ((N-3)/(N-1)) appears on the second term. Let's use the simple
% expression when calculating the variance of the covariance matrix. Sure to be
% good as N -> Inf, but for small N  could lead to negative estimate? Could
% fudge in the ((N-3)/(N-1)), but while it gives the correct result for the
% diagonal of the covariance matrix, it may not be right for the off-diagonal
% terms. Summary: simple formula.

dX2 = dX.^2;
dX2Y2 = repmat(dX2,[1,1,3]) .* repmat(permute(dX2,[1,3,2]), [1,3,1]);

var_cov = (squeeze(mean(dX2Y2,1)) - Xcov.^2) / N;
sig_cov = sqrt(var_cov);


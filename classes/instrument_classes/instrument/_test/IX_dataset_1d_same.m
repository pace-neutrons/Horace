function [ok,chisqr,wresid] = IX_dataset_1d_same (wref,wnoisy,tol)
% Determine if two IX_dataset_1d are the same within error bars
%
%   >> [ok,chisqr] = datasets_same (wref,wnoisy,tol)
%
% Input:
% ------
%   wref    Reference IX_dataset_1d. Will interpolate onto x values of wtrial.
%           Error bars will be ignored
%
%   wnoisy  Trial IX_dataset_1d. Error bars used as measure of equality
%
%   tol     Tolerance. ok if chisqr <= tol
%
% Output:
% -------
%   ok      True if test passed
%
%   chisqr  Actual value of chisqr

if ishistogram(wref)
    wref = hist2point(wref);
end

if ishistogram(wnoisy)
    wnoisy = hist2point(wnoisy);
end

if ~exist('tol','var')
    tol = 1;
end


signal_ref = interp1(wref.x,wref.signal,wnoisy.x,'linear','extrap');
chisqr = sum(((wnoisy.signal(:) - signal_ref(:))./wnoisy.error).^2) / numel(signal_ref);

wresid = wnoisy;
wresid.signal = (wnoisy.signal(:) - signal_ref(:));

if isfinite(chisqr) && chisqr<=tol
    ok = true;
else
    ok = false;
end

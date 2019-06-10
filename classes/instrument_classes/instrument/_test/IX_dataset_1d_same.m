function [ok,mess,wdiff,chisqr_red] = IX_dataset_1d_same (w1,w2,varargin)
% Determine if two IX_dataset_1d are the same within error bars
%
%   >> [ok,mess,wdiff,chisqr_red] = IX_dataset_1d_same (w1,w2)
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


wdiff = IX_dataset_1d;
chisqr_red = NaN;

keyval_def = struct('rebin',false,'xtol',0,'chisqr',false,'tol',0);
flags = {'rebin','chisqr'};
[par, keyval, present] = parse_arguments (varargin, keyval_def, flags);
if numel(par)==1 && ~present.tol
    keyval.tol = par{1};
elseif ~isempty(par)
    error('Check input arguments')
end


% Check x-axis tolerance, or rebin:
if ~keyval.rebin
    if xor(ishistogram(w1),ishistogram(w2)) && numel(w1.x)==numel(w2.x)
        [ok, mess] = equal_to_tol (w1.x, w2.x, keyval.xtol);
        if ~ok
            mess = ['x-axes: ',mess];
            return
        end
    else
        ok = false;
        mess = 'Must both be histogram or both point array, and same number of x-values';
        return
    end
else
    % Make both histogram or both point
    if ishistogram(w1) && ~ishistogram(w2)
        w2 = point2hist(w2);
    elseif ~ishistogram(w1) && ishistogram(w2)
        w1 = point2hist(w1);
    end
    % Ensure same x-axis
    if ~isequal(w1.x,w2.x)
        w2 = rebin(w2,w1);
    end
end

% Check that signal and error are finite, infinite or NaN in the same places


% Check signals or chisqr:
wdiff = w2 - w1;

if keyval.chisqr
    s = wdiff.signal(:)';
    e = wdiff.error(:)';
    if all(s(e==0)==0)  % if s and e are zero, then this is OK
        chisqr = (s./e).^2;
        chisqr = chisqr(isfinite(chisqr));
        chisqr_red = sum(chisqr)/numel(chisqr);
        [ok, mess] = equal_to_tol (chisqr_red, 1, keyval.tol);
        if ~ok
            mess = ['chisqr: ',mess];
            return
        end
    else
        ok = false;
        mess = 'chisqr: non-zero residual where the standard deviation is non-zero, for one or more points';
        return
    end
    
else
    [ok, mess] = equal_to_tol (w1.signal, w2.signal, keyval.tol);
    if ~ok
        mess = ['signal: ',mess];
        return
    end
    
end

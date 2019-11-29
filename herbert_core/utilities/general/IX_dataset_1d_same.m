function [ok,mess,wdiff,chisqr] = IX_dataset_1d_same (w1,w2,varargin)
% Determine if two IX_dataset_1d are the same within error bars
%
%   >> [ok,mess,wdiff,chisqr_red] = IX_dataset_1d_same (w1,w2)
%   >> [ok,mess,wdiff,chisqr_red] = IX_dataset_1d_same (w1,w2,tol)
%
% Input:
% ------
%   w1, w2  Datasets to compare. If one is hostogram and the other point
%           data, then the point data is converted to histogram before
%           comparison. w2 is also rebinned to the same
%
%   tol     Tolerance on matching signal. Same convention as the function
%           equal_to_tol:
%
%           tol = [abs_tol, rel_tol]
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
%
%               If either criterion is satisfied then equality within tolerance
%               is accepted.
%
%           If scalar:
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%
%           Default: [0,0]
%
% Optional arguments:
%  'tol'    Alternative to third argument tol above. That is,
%               >> ... IX_dataset_1d_same (w1,w2,tol)
%               >> ... IX_dataset_1d_same (w1,w2,'tol',tol)
%           are identical.
%
%  'rebin' If true, rebin w2 to the same x values as w1 if they do not match
%           Default: false
%
%  'xtol'   Tolerance on x-axis value matching; format same as tol above.
%           Default: [0,0].
%           Only applies if 'rebin' is false.
% 
%  'chisqr' Comparison of signal is done on the value of chisqr for (w1-w2)
%           The tolerance 'tol' appies to the average value of
%           (signal./error)^2 with respect to unity.
%
% Output:
% -------
%   ok      True if test passed
%
%   wdiff   If defined, (w1-w2). Rebinning is performed on w2 if 'rebin' is
%           true.
%
%   chisqr  Average value of (signal/error)^2


wdiff = IX_dataset_1d;
chisqr = NaN;

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
        chisqr_sum = (s./e).^2;
        chisqr_sum = chisqr_sum(isfinite(chisqr_sum));
        chisqr = sum(chisqr_sum)/numel(chisqr_sum);
        [ok, mess] = equal_to_tol (chisqr, 1, keyval.tol);
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

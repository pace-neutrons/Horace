function [ww_f,pp_f,ok,mess] = mftest_mf_and_f_multiple_datasets (ww,varargin)
% Test equivalence of fit and loop of multifit for array datasets
%
%   [ww_f,pp_f,ok,mess] = mftest_mf_and_f_multiple_datasets (ww,varargin)
%
%   ww          array of datasets, or cell array of datasets with one fo the acceptable forms for fit
%   varargin    all the other argumnets that can be passed to fit or multifit
%
%   ww_f        output fits
%   pp_f        output fit parameters
%   ok          true if no problems, false otherwise
%   mess        error message if not ok ('' if ok)
%
% Routine compares output of fit with that from running multifit in a loop over all the
% datasets.

% Call to fit
[ww_f,pp_f,ok,mess]=fit(ww, varargin{:});
if ~ok, return, end

% Call to multifit
if iscell(ww)
    ww_fref=cell(size(ww));
else
    ww_fref=ww;
end
for i=1:numel(ww)
    if iscell(ww)
        [ww_fref{i},pp_fref(i),ok,mess]=fit(ww{i}, varargin{:});
    else
        [ww_fref(i),pp_fref(i),ok,mess]=fit(ww(i), varargin{:});
    end
    if i==1, pp_fref=repmat(pp_fref,size(ww)); end
end

tol=0;
ok=equal_to_tol(ww_f,ww_fref,tol);
if ~ok, error('Test failed: fitted datasets'), end
ok=equal_to_tol(pp_f,pp_fref,tol);
if ~ok, error('Test failed: fit parameters'), end

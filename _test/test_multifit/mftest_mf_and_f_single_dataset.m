function [y1_fit, wstruct1_fit, w1_fit, p1_fit] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,varargin)
% Test, for single dataset 
% - equivalence of fitting xye, structure and IX_dataset_1d input in multifit, and
% - equivalence of multifit and fit
%
%   >> [y1_fit, wstruct1_fit, w1_fit, p1_fit] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,varargin)
%
%   x1,y1,e1    x,y,e data in standard form for multifit
%   wstruct1    equivalent structure with fields x,y,e
%   w1          object with equivalent x-y-e data
%
% Note that the input can be for an arbitrary dimensional object; varargin needs to be
% the set of arguments to be passed to fit and multifit following the input data set.
%
% Author: T.G.Perring

tol=0;

% Perform multifit
[y1_mfit,py1_mfit]=multifit(x1,y1,e1,varargin{:});
[wstruct1_mfit,pwstruct1_mfit]=multifit(wstruct1,varargin{:});
[w1_mfit,pw1_mfit]=multifit(w1,varargin{:});

ok=equal_to_tol(y1_mfit,wstruct1_mfit.y,tol);
if ~ok, error('Test failed: struct'), end
ok=equal_to_tol(py1_mfit,pwstruct1_mfit,tol);
if ~ok, error('Test failed: struct-fitpar'), end

ok=equal_to_tol(y1_mfit',w1_mfit.signal,tol);
if ~ok, error('Test failed: object'), end
ok=equal_to_tol(py1_mfit,pw1_mfit,tol);
if ~ok, error('Test failed: object-fitpar'), end

% Perform fit
[y1_fit,py1_fit]=fit(x1,y1,e1,varargin{:});
[wstruct1_fit,pwstruct1_fit]=fit(wstruct1,varargin{:});
[w1_fit,pw1_fit]=fit(w1,varargin{:});

ok=equal_to_tol(y1_mfit,y1_fit,tol);
if ~ok, error('Test failed: struct'), end
ok=equal_to_tol(py1_mfit,py1_fit,tol);
if ~ok, error('Test failed: struct-fitpar'), end

ok=equal_to_tol(y1_mfit,wstruct1_fit.y,tol);
if ~ok, error('Test failed: struct'), end
ok=equal_to_tol(py1_mfit,pwstruct1_fit,tol);
if ~ok, error('Test failed: struct-fitpar'), end

ok=equal_to_tol(y1_mfit',w1_fit.signal,tol);
if ~ok, error('Test failed: object'), end
ok=equal_to_tol(py1_mfit,pw1_fit,tol);
if ~ok, error('Test failed: object-fitpar'), end

% Copy fit parameters
p1_fit=py1_mfit;

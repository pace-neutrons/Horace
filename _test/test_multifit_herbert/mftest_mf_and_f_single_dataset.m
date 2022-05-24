function [y1_mfit, wstruct1_mfit, w1_mfit, p1_mfit] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,varargin)
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
mf = multifit(x1,y1,e1);
[y1_mfit,py1_mfit] = mf_perform_fit (mf, varargin{:});

mf = multifit(wstruct1);
[wstruct1_mfit,pwstruct1_mfit] = mf_perform_fit (mf, varargin{:});

mf = multifit(w1);
[w1_mfit,pw1_mfit] = mf_perform_fit (mf, varargin{:});


assertTrue(equal_to_tol(y1_mfit,wstruct1_mfit.y,tol),'Test failed: struct');
assertTrue(equal_to_tol(py1_mfit,pwstruct1_mfit,tol),'Test failed: struct-fitpar');
assertTrue(equal_to_tol(y1_mfit',w1_mfit.signal,tol),'Test failed: object');
assertTrue(equal_to_tol(py1_mfit,pw1_mfit,tol),'Test failed: object-fitpar');


% ------------- *** FIT IS CURRENTLY DISABLED -----------------------------
% % Perform fit
% [y1_fit,py1_fit]=fit(x1,y1,e1,varargin{:});
% [wstruct1_fit,pwstruct1_fit]=fit(wstruct1,varargin{:});
% [w1_fit,pw1_fit]=fit(w1,varargin{:});
%
% assertTrue(equal_to_tol(y1_mfit,y1_fit,tol),'Test failed: struct');
% assertTrue(equal_to_tol(py1_mfit,py1_fit,tol),'Test failed: struct-fitpar');
% assertTrue(equal_to_tol(y1_mfit,wstruct1_fit.y,tol),'Test failed: struct');
% assertTrue(equal_to_tol(py1_mfit,pwstruct1_fit,tol),'Test failed: struct-fitpar');
% assertTrue(equal_to_tol(y1_mfit',w1_fit.signal,tol),'Test failed: object');
% assertTrue(equal_to_tol(py1_mfit,pw1_fit,tol),'Test failed: object-fitpar');
% -------------------------------------------------------------------------

% Copy fit parameters
p1_mfit=py1_mfit;


%--------------------------------------------------------------------------
function [wout,fitpar] = mf_perform_fit (mf, varargin)

% Find foreground and background functions and arguments
for i=2:numel(varargin)
    if isa(varargin{i},'function_handle')
        ib = i;
        nargb = numel(varargin) - ib;
        nargf = ib - 2;
        break
    end
    ib = [];
    nargf = numel(varargin) - 1;
end
forefunc = varargin{1};
if nargf>=1, pin = varargin{2}; else, pin = []; end
if nargf>=2, pfree = varargin{3}; else, pfree = []; end
if nargf>=3, pbind = varargin{4}; else, pbind = []; end
if nargf>=4, error('Too many foreground function arguments'); end

if ~isempty(ib)
    backfunc = varargin{ib};
    if nargb>=1, bpin = varargin{ib+1}; else, bpin = []; end
    if nargb>=2, bpfree = varargin{ib+2}; else, bpfree = []; end
    if nargb>=3, bpbind = varargin{ib+3}; else, bpbind = []; end
    if nargb>=4, error('Too many background function arguments'); end
end

% Perform the fit
mf = mf.set_fun(forefunc);
if ~isempty(pin), mf = mf.set_pin (pin); end
if ~isempty(pfree), mf = mf.set_free (pfree); end
if ~isempty(ib)
    mf = mf.set_bfun(backfunc);
    if ~isempty(bpin), mf = mf.set_bpin (bpin); end
    if ~isempty(bpfree), mf = mf.set_bfree (bpfree); end
end
% BIndings must be set after the functions in case foreground/background cross-binding
if ~isempty(pbind), mf = mf.set_bind (pbind); end
if ~isempty(ib)
    if ~isempty(bpbind), mf = mf.set_bbind (bpbind); end
end
[wout,fitpar] = mf.fit();

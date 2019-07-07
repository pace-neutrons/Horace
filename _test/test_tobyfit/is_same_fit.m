function ok = is_same_fit (fp1, fp2, tol, mask, bmask)
% Determine if two sets of fit parameters are the same within errors
%
%   >> ok = is_same_fit (fp1, fp2)
%   >> ok = is_same_fit (fp1, fp2, fac)
%   >> ok = is_same_fit (fp1, fp2, fac, mask, bmask)
%
% Parameter values with zero standard deviation are ignored as being fixed
% parameters
%
% Input:
% ------
%   fp1, fp2    Output fit parameter structure from multifit
%
%   tol         Tolerance [sigfac, abstol, reltol] (default: [1,0,0])
%                   sigfac  Agreement within: sigfac * sqrt(sig1^2 + sig^2)
%                   abstol  Agreement to absolute amount
%                   reltol  Relative tolerance
%               If any of the requirements is met, then the test passes
%
%   mask        Logical mask of which parameters to compare
%                   e.g. [1,1,0,0,1] compare only parameters 1,2,and 5
%
%   bmask       Logical mask of which background parameters to compare
%
% Output:
% -------
%   OK          True if all parameters are equal within tolerance


% Defaults for optional arguments
if nargin<3
    tol=[1,0,0];
elseif isscalar(tol)
    tol = [tol,0,0];    % for legacy use before introduction of abstol and reltol
end
if nargin<4
    mask=[];
end
if nargin<5
    bmask=[];
end

% Get parameters and st. dev for the two fit sets
if isfield(fp1,'p'), p=fp1.p; sig=fp1.sig; else p=[]; sig=[]; end
if isfield(fp1,'bp'), bp=fp1.bp; bsig=fp1.bsig; else bp=[]; bsig=[]; end
p = make_vec(p);
bp = make_vec(bp);
np1 = numel(p);
nbp1 = numel(bp);
p1 = [p,bp];
sig1=[make_vec(sig),make_vec(bsig)];

if isfield(fp2,'p'), p=fp2.p; sig=fp2.sig; else p=[]; sig=[]; end
if isfield(fp2,'bp'), bp=fp2.bp; bsig=fp2.bsig; else bp=[]; bsig=[]; end
p = make_vec(p);
bp = make_vec(bp);
np2 = numel(p);
nbp2 = numel(bp);
p2 = [p,bp];
sig2=[make_vec(sig),make_vec(bsig)];

if ~(np1==np2 && nbp1==nbp2)
    error('Different number of parameters in the two sets being compared')
end

% Tolerance
tol_from_err = abs(tol(1)) * sqrt(sig1.^2 + sig2.^2);
tol_from_abs = abs(tol(2));
tol_from_rel = abs(tol(3)) * (max(abs(p1),abs(p2)));
tol_max = max(tol_from_err,max(tol_from_abs,tol_from_rel));

% Mask parameters from comparison
if isempty(mask)
    mask=true(1,np1);
elseif numel(mask)~=np1
    error('Check the length of mask the foreground mask array')
end
if isempty(bmask)
    bmask=true(1,nbp1);
elseif numel(bmask)~=nbp1
    error('Check the length of mask the background mask array')
end
keep=[logical(mask),logical(bmask)];

fixed = (sig1==0 & sig2==0);     % assume zero st dev means the parameters were fixed
keep(fixed) = false;

% Perform comparison
%  [(p1(keep)'-p2(keep)')./tol_max(keep)']
ok = all(abs(p1(keep)-p2(keep))<=tol_max(keep));

%---------------------------------------------------------------------------
function p=make_vec(pin)
if ~isempty(pin)
    if iscell(pin)
        p=cell2mat(pin);
    else
        p=pin;
    end
else
    p=[];
end

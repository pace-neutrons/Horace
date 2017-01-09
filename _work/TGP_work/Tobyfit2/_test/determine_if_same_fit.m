function ok = determine_if_same_fit (fp1, fp2, fac, mask, bmask)
% Determine if two sets of fit parameters are the same within errors
%
%   >> ok = determine_if_same_fit (fp1, fp2)
%   >> ok = determine_if_same_fit (fp1, fp2, fac)
%   >> ok = determine_if_same_fit (fp1, fp2, fac, mask, bmask)
%
% The routine works when some or all parmaeters are fixed: zero error
% bars are OK for parameters that are equal.
%
% Input:
% ------
%   fp1, fp2    Output fit parameter structure from multifit
%   fac         Multiple of sqrt(sig1^2 + sig^2) (default: 1)
%
% Output:
% -------
%   OK          True if all parameters are equal within tolerance


if nargin<3
    fac=1;
end
if nargin<4
    mask=[];
end
if nargin<5
    bmask=[];
end

if isfield(fp1,'p'), p=fp1.p; sig=fp1.sig; else p=[]; sig=[]; end
if isfield(fp1,'bp'), bp=fp1.bp; bsig=fp1.bsig; else bp=[]; bsig=[]; end
p1=[make_vec(p),make_vec(bp)];
sig1=[make_vec(sig),make_vec(bsig)];

if isfield(fp2,'p'), p=fp2.p; sig=fp2.sig; else p=[]; sig=[]; end
if isfield(fp2,'bp'), bp=fp2.bp; bsig=fp2.bsig; else bp=[]; bsig=[]; end
p2=[make_vec(p),make_vec(bp)];
sig2=[make_vec(sig),make_vec(bsig)];

tol = abs(fac) * sqrt(sig1.^2 + sig2.^2);

if isempty(mask)
    mask=true(size(p));
end
if isempty(bmask)
    bmask=true(size(bp));
end
keep=[logical(mask),logical(bmask)];

ok = equal_to_abs (p1(keep),p2(keep),tol(keep));

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

%---------------------------------------------------------------------------
function ok = equal_to_abs (a,b,tol)

eq=(a==b);
if ~isempty(eq)     
    aa=a(~eq); bb=b(~eq); del=tol(~eq);
    ok=all(abs(aa(:)-bb(:))<=abs(del(:)));
else
    ok=true;
end

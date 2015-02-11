function [ok,pref,pbin,noff,match]=make_bin_boundary_descriptor(varargin)
% Determine if a set of bins match
%
%   >> [ok,pbin,noff,match] = make_bin_boundary_descriptor (p1,p2,...)
%   >> [ok,pbin,noff,match] = make_bin_boundary_descriptor (p1,p2,...,'tol',tol)
%
% Input:
% ------
%   p1,p2,. Bin boundaries, i.e. each of p1, p2,.. is a column vector with
%          length at least two of equally spaced strictly monotonic increasing
%          values.
%
%   tol     Acceptable tolerance as a fraction of the bin width
%
% Output:
% -------
%   ok      True if bins are commensurate to within the given tolerance
%
%   pref    If ok, the bin boundaries that include all input bin boundaries sets.
%           If not ok, then =[]
%
%   pbin    If ok, this is a rebin descriptor [plo,pstep,phi] that
%          defines the minimum set of bin boundaries that is the superset of
%          p1,p2,... Note: plo, phi are bin *centres*
%           If not ok, pbin=[NaN,NaN,NaN]
%
%   noff    Row vector [n1,n2,...] with offsets of bin number of p1, p2,...
%          in the set of bin boundaries defined by pbin.
%           If not ok, then noff is a row vector of NaNs
%
%   match   True if p1,p2,... are all identical within tolerance


% Original author: T.G.Perring
%
% $Revision: 942 $ ($Date: 2014-12-03 12:17:44 +0000 (Wed, 03 Dec 2014) $)


% Parse input
if nargin>2 && ischar(varargin{end-1})
    if strcmpi(varargin{end-1},'tol')
        tol=varargin{end};
    else
        error('Check input argument types')
    end
    p=varargin(1:end-2);
else
    tol=0;
    p=varargin;
end
np=numel(p);


% Determine if bins are commensurate within the given tolerance
pmin=zeros(1,np);
pmax=zeros(1,np);
pstep=zeros(1,np);
nbnd=zeros(1,np);
for i=1:numel(p)
    pmin(i)=p{i}(1);
    pmax(i)=p{i}(end);
    if numel(p{i})>1 && pmin(i)<pmax(i)
        nbnd(i)=numel(p{i});
        pstep(i)=(pmax(i)-pmin(i))/(nbnd(i)-1);
    else
        [ok,pref,pbin,noff,match]=error_output(np);
        return
    end
end

pmin_min=min(pmin);
pmax_max=max(pmax);
pstep0=median(pstep);
mmin=zeros(1,np);
mmax=zeros(1,np);
for i=1:numel(p)
    m=(p{i}-pmin_min)/pstep0;
    dm=m-(round(m(1))+(0:numel(m)-1)');
    if ~all(abs(dm)<tol)
        [ok,pref,pbin,noff,match]=error_output(np);
        return
    end
    mmin(i)=round(m(1));
    mmax(i)=round(m(end));
end

if all(mmin==0) && all(nbnd==nbnd(1))
    match=true;
else
    match=false;
end


% Construct set of bin boundaries and bin boundary descriptor
% (Catch case of one set of boundaries including all sets, if can:
% Find candidate sets, allowing for rounding (it could be that one or more sets
% are fine, except that rounding errors in another set means that its phi is
% fractionally higher. We don't want rounding errors to result in these
% candidate sets not being considered)

ind=find((pmin-0.1*pstep<pmin_min) & (pmax+0.1*pstep)>pmax_max);
if numel(ind)>0
    if numel(ind)==1
        ib=ind(1);
    else
        % First get those with equal lowest pmin, then highest pmax within that set
        [dummy,ix]=sortrows([pmin(ind)',-pmax(ind)']);
        ib=ind(ix(1));
    end
    pref=p{ib};
    if nbnd(ib)>2
        pbin=[pref(1)+0.5*pstep(ib), pstep(ib), pref(end)-0.5*pstep(ib)];
    else
        pbin=[0.5*(pref(1)+pref(2)), pstep(ib), 0.5*(pref(1)+pref(2))];     % avoid plo>phi from rounding
    end
    
    % Sanity check: if TGP has understood the algorithms, this test should always pass
    ptmp=make_const_bin_boundaries(pbin);
    if ~(numel(pref)==numel(ptmp) && max(abs(pref-ptmp))/pbin(2)<4*tol)
        error('Algorithm problem - contact T.G.Perring')
    end
    
else
    pstep0=(pmax_max-pmin_min)/max(mmax);
    if max(mmax)>1
        pbin=[pmin_min+0.5*pstep0, pstep0, pmax_max-0.5*pstep0];
    else
        pbin=[0.5*(pmin_min+pmax_max), pstep0, 0.5*(pmin_min+pmax_max)];
    end
    pref=make_const_bin_boundaries(pbin);
    
    % Sanity check: if TGP has understood the algorithms, this test should always pass
    if ~(numel(pref)==max(mmax)+1 && ...
            abs(pref(1)-pmin_min)/pstep0<4*tol && abs(pref(end)-pmax_max)/pstep0<4*tol)
        error('Algorithm problem - contact T.G.Perring')
    end
    
end

ok=true;
noff=mmin;

%-------------------------------------------------------------------------------------
function [ok,pref,pbin,noff,match]=error_output(np)
ok=false; pref=[]; pbin=[NaN,NaN,NaN]; noff=NaN(1,np); match=false;

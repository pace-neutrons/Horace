function [powmap,powpar]=powder_map(varargin)
% Create map and par objects from an input par object
%
%   >> [powmap,powpar]=powder_map(par,phi)
%   >> [powmap,powpar]=powder_map(par,phi,'squeeze')
%
% Input:
% ------
%   par         parObject i.e. object with detector parameter data
%   phi         Binning:
%                  - dphi
%               or - [phi_min, dphi, phi_max]
%
% Optional keyword:
%  'squeeze'    Empty output workspaces will be removed from the final
%               map and par objects.
%
% Output:
% -------
%   powmap      powder map object
%   powpar      powder par object


% Original author: T.G.Perring 23 Sep 2013

% Parse input arguments
% ---------------------
if nargin>=1 && is_string(varargin{end}) && ~isempty(varargin{end})...
        && strncmpi(varargin{end},'squeeze',numel(varargin{end}))
    squeeze=true;
    narg=nargin-1;
else
    squeeze=false;
    narg=nargin;
end

if narg==2
    par=varargin{1};
    phi=varargin{2};
else
    error('Check number of arguments')
end

if isscalar(phi) && phi>0   % single number is step size
    phi_min=0;
    phi_max=max(par.phi);
    dphi=phi;
elseif numel(phi)==3
    phi_min=phi(1);
    phi_max=phi(3);
    dphi=phi(2);
end
if phi_max<phi_min || dphi<=0
    error('Check scattering angle binning')
end


% Get indicies of new workspaces
% ------------------------------
ok=(par.phi>=phi_min)&(par.phi<=phi_max);
ind=floor((par.phi(ok)-phi_min)/dphi);

imax=max(ind);
phibin=phi_min+dphi*(0:imax+1);
% Account for rounding errors
ind(ind<0)=0;   
if phi_max<=phibin(end-1)
    ind(ind==imax)=imax-1;
    phibin=phibin(1:end-1);
elseif phi_max>phibin(end)
    ind(par.phi(ok)>phibin(end))=imax+1;
    phibin=[phibin,phibin(end)+dphi];
end
% Make ind run from 1, not 0
ind=ind+1;  
imax=max(ind);


% Now construct map and par objects
% ---------------------------------
nw=numel(par.group);
w=Inf(1,nw);
s=1:nw;
w(ok)=ind;
[w,ix]=sort(w);
s=s(ix);
nw_new=numel(ind);
map.ns=accumarray(w(1:nw_new)',ones(1,nw_new),[imax,1])';
map.s=s(1:nw_new);
map.wkno=[];

tmp.filename='';
tmp.filepath='';
tmp.group=1:imax;
x2=par.x2(ix);
tmp.x2=accumarray(w(1:nw_new)',x2(1:nw_new),[imax,1])'./map.ns;
tmp.phi=0.5*(phibin(2:end)+phibin(1:end-1));
tmp.azim=zeros(1,imax);
tmp.width=2*(tmp.x2.*tand(0.5*dphi));
tmp.height=zeros(1,imax);

if squeeze
    keep=(map.ns>0);
    % Update map
    map.ns=map.ns(keep);
    % Update par
    tmp.group=1:sum(keep);
    tmp.x2=tmp.x2(keep);
    tmp.phi=tmp.phi(keep);
    tmp.azim=tmp.azim(keep);
    tmp.width=tmp.width(keep);
    tmp.height=tmp.height(keep);
end
powmap=IX_map(map);
powpar=parObject(tmp);

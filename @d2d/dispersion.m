function w1d=dispersion(w2d,dispreln,p)
% Calculate dispersion relation(s) along the momentum plot axis of a 2D dataset
%
%   >> w1d=dispersion(w2d,dispreln,p)
%
%   w2d         2D dataset that provides the axes for the calculation
%               One of the plot axes MUST be energy transfer
%
%   dispreln    Handle to function that calculates the dispersion relation
%               Must have form:
%                   w = dispreln (qh,qk,ql,p)
%                where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [j1,j2,j3]  as three exchange constants
%                   w           Array containing calculated energies; if more than
%                              one dispersion relation, then a cell array of arrays
%
%   p           Parameters to be passed to dispersion relation calculation above
%
% Output
%   w1d         1D dataset (or array of 1d datssets) containing the dispersion
%               relation (or relations)

npnt=501;  % Number of points along plot axis at which to evaluate dispersion relation

if ~any(w2d.pax==4) % no projection axis is energy
    error ('Must have energy as one of the projection axes')
end

% Get offset to Q points in the frame of the plot axes (general algorithm)
p0=w2d.p0;
u=w2d.u;
uint=w2d.uint;
pax=w2d.pax;
iax=w2d.iax;
ptot=p0;

for i=1:length(iax)
    ptot=ptot+(0.5*(uint(1,i)+uint(2,i)))*u(:,iax(i));  % overall displacement of plot volume in (rlu;en)
end

% Create list of Q points at which to evaluate dispersion relation
p1=w2d.p1;
pstep=(p1(end)-p1(1))/(length(p1-1));
pmin=p1(1)+pstep/2;
pmax=p1(end)-pstep/2;
pstep_plot=(pmax-pmin)/(npnt-1);
pcent_plot=linspace(pmin,pmax,npnt)';    % column vector
pbound_plot=linspace(pmin-pstep_plot/2,pmax+pstep_plot/2,npnt+1)';    % column vector

qh=ptot(1) + pcent_plot*u(1,pax(1));
qk=ptot(2) + pcent_plot*u(2,pax(1));
ql=ptot(3) + pcent_plot*u(3,pax(1));

% Calculate dispersion relation(s):
wdisp = dispreln(qh,qk,ql,p);
ndisp=length(wdisp);     % number of dispersion relations

% Package results as d1d array - removing energy as a plot axis
data=get(w2d);
ind=find(data.pax~=4);
data.pax=data.pax(ind);       % remove energy from plot axes
data.iax=[data.iax,4];        % add energy as integration axis
data.uint=[data.uint,[0;0]];  % make energy integration range 0 to 0 
data.p1=pbound_plot;
data=rmfield(data,'p2');
data.s=wdisp{1};
data.e=zeros(size(data.s));
data.n=ones(size(data.s)); 

w1d=d1d(data);
w1d(ndisp)=w1d;
for i=2:ndisp
    data.s=wdisp{i};
    w1d(i)=d1d(data);
end

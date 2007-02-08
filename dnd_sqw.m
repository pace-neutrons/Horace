function weight=dnd_sqw(din,sqwfunc,p)
% Calculate sqw along the momentum plot axis of an n-dimensional dataset
%
%   >> weight=sqw(din,sqwfunc,p)
%
%   din         Dataset that provides the axes and points for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Must have form:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%               qh,qk,ql,en Arrays containing the coordinates of a set of points
%               p           Vector of parameters needed by dispersion function 
%                           e.g. [A,js,gam] as intensity, exchange, lifetime
%               weight      Array containing calculated energies; if more than
%                           one dispersion relation, then a cell array of arrays
%
%   p           Parameters to be passed to dispersion relation calculation above
%
% Output
%   weight      S(Q,w) on a grid with same size as din.s

% Get offset to Q points in the frame of the plot axes
p0=din.p0;
u=din.u;
uint=din.uint;
pax=din.pax;
iax=din.iax;
ptot=p0;

for i=1:length(iax)
    ptot=ptot+(0.5*(uint(1,i)+uint(2,i)))*u(:,iax(i));  % overall displacement of plot volume in (rlu;en)
end

% Create list of Q points at which to evaluate dispersion relation
if length(pax)>1
    for i=1:length(pax)
        ptemp{i}=(din.(['p',int2str(i)])(2:end)+din.(['p',int2str(i)])(1:end-1))/2;
    end
    pp=ndgridcell(ptemp);
    qh=ptot(1)*ones(size(pp{1}));
    qk=ptot(2)*ones(size(pp{1}));
    ql=ptot(3)*ones(size(pp{1}));
    en=ptot(4)*ones(size(pp{1}));
    for i=1:length(pax)
        qh = qh + pp{i}*u(1,pax(i));
        qk = qk + pp{i}*u(2,pax(i));
        ql = ql + pp{i}*u(3,pax(i));
        en = en + pp{i}*u(4,pax(i));
    end
elseif length(pax)==1
    pp=(din.p1(2:end)+din.p1(1:end-1))/2;
    qh=ptot(1) + pp*u(1,pax(1));
    qk=ptot(2) + pp*u(2,pax(1));
    ql=ptot(3) + pp*u(3,pax(1));
    en=ptot(4) + pp*u(4,pax(1));
else
    qh=ptot(1);
    qk=ptot(2);
    ql=ptot(3);
    en=ptot(4);
end

% Evaluate S(Q,w):
weight = sqwfunc(qh,qk,ql,en,p);

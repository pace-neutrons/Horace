function qw=dnd_calculate_qw(din)
% Calculate qh,qk,ql,en for the centres of the bins of an n-dimensional dataset
%
%   >> [qh,qk,ql,en]=dnd_calculate_qe(din)
%
%   din     Dataset that provides the axes and points for the calculation
%   qw      Components of momentum (in rlu) and energy for each bin in the dataset
%           Arrays are package as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en

p0=din.p0;
u=din.u;
uint=din.uint;
pax=din.pax;
iax=din.iax;
ptot=p0;

for i=1:length(iax)
    ptot=ptot+(0.5*(uint(1,i)+uint(2,i)))*u(:,iax(i));  % overall displacement of plot volume in (rlu;en)
end

% Create list of Q and energy points
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

% package as cell array of column vectors for convenience with fitting routines etc.
qh = reshape(qh,numel(qh),1);   % get into single column
qk = reshape(qk,numel(qk),1);   % get into single column
ql = reshape(ql,numel(ql),1);   % get into single column
en = reshape(en,numel(en),1);   % get into single column
qw = {qh, qk, ql, en};

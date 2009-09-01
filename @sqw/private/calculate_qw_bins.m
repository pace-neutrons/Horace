function qw=calculate_qw_bins(win)
% Calculate qh,qk,ql,en for the centres of the bins of an n-dimensional sqw dataset
%
%   >> qw=calculate_qw_bins(win)
%
%   win     Input sqw object
%
%   qw      Components of momentum (in rlu) and energy for each bin in the dataset
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en
%

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

u0=win.data.uoffset;
u=win.data.u_to_rlu;
iax=win.data.iax;
iint=win.data.iint;
pax=win.data.pax;

ptot=u0;
for i=1:length(iax)
    % get offset from integration axis, accounting for non-finite limit(s)
    if isfinite(iint(1,i)) && isfinite(iint(2,i))
        iint_ave=0.5*(iint(1,i)+iint(2,i));
    else
        iint_ave=0;
    end
    ptot=ptot+iint_ave*u(:,iax(i));  % overall displacement of plot volume in (rlu;en)
end

% Create list of Q and energy points
if length(pax)>1
    ptemp=cell(1,length(pax));
    for i=1:length(pax)
        ptemp{i}=0.5.*(win.data.p{i}(1:end-1) + win.data.p{i}(2:end));
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
    pp=0.5.*(win.data.p{1}(2:end)+win.data.p{1}(1:end-1));
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
qw = {qh(:), qk(:), ql(:), en(:)};

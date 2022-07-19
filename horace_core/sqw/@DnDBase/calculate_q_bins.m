function [q,en]=calculate_q_bins(win)
% TODO: Overload for different projection! #825
% Calculate qh,qk,ql,en for the centres of the bins of an n-dimensional sqw or dnd dataset
%
%   >> [q,en]=calculate_q_bins(win)
%
% Input:
% ------
%   win     Input sqw/dnd object
%
% Output:
% -------
%   q       Components of momentum (in rlu) for each bin in the dataset for a single energy bin
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql
%   en      Column vector of energy bin centres. If energy was an integration axis, then returns the
%           centre of the energy integration range

if numel(win)~=1
    error('HORACE:DnDBase:invalid_argument', ...
        'Only a single object is valid - cannot take an array of %s objects', ...
        class(win))
end

u0 = win.offset;
% TODO: Overload for different projection! #825
u = win.proj.u_to_rlu;
iax = win.iax;
iint = win.iint;
pax = win.pax;

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

% Create list of Q points
en_is_axis=(numel(pax)>0)&(pax(end)==4);
nqpax=numel(pax)-en_is_axis;
if nqpax>1
    ptemp=cell(1,nqpax);
    for i=1:nqpax
        ptemp{i} = 0.5 .* (win.p{i}(1:end-1) + win.p{i}(2:end));
    end
    pp=ndgridcell(ptemp);
    qh=ptot(1)*ones(size(pp{1}));
    qk=ptot(2)*ones(size(pp{1}));
    ql=ptot(3)*ones(size(pp{1}));
    for i=1:nqpax
        qh = qh + pp{i}*u(1,pax(i));
        qk = qk + pp{i}*u(2,pax(i));
        ql = ql + pp{i}*u(3,pax(i));
    end
elseif nqpax==1
    pp = 0.5 .* (win.p{1}(2:end) + win.p{1}(1:end-1));
    qh=ptot(1) + pp*u(1,pax(1));
    qk=ptot(2) + pp*u(2,pax(1));
    ql=ptot(3) + pp*u(3,pax(1));
else
    qh=ptot(1);
    qk=ptot(2);
    ql=ptot(3);
end

% Package as cell array of column vectors for convenience with fitting routines etc.
q = {qh(:), qk(:), ql(:)};

% Create list of energy points
if en_is_axis
    en=ptot(4) + 0.5 .* (win.p{end}(2:end) + win.p{end}(1:end-1));
else
    en=ptot(4);
end

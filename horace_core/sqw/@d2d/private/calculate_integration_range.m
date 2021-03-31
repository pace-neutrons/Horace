function [irange,uoff]=calculate_integration_range(w1,w2)
%
% Calculate the integration range for an object made by combining the d2d
% objects w1 and w2.
%
% w1 and w2 have already been checked to ensure that their data planes are
% parallel.
%
% RAE 22/1/10
%

iax11=w1.data_.u_to_rlu(:,w1.data_.iax(1));
iax12=w1.data_.u_to_rlu(:,w1.data_.iax(2));
off11=w1.data_.uoffset(w1.data_.iax(1));
off12=w1.data_.uoffset(w1.data_.iax(2));

iax21=w2.data_.u_to_rlu(:,w2.data_.iax(1));
iax22=w2.data_.u_to_rlu(:,w2.data_.iax(2));
off21=w2.data_.uoffset(w2.data_.iax(1));
off22=w2.data_.uoffset(w2.data_.iax(2));

iint1=w1.data_.iint;
iint2=w2.data_.iint;

if isequal(1e-5.*round(1e5.*iax11),1e-5.*round(1e5.*iax21))
    %must compare 1st cols of iint1 and iint2
    lo1=min([iint1(1,1) iint2(1,1)]);
    hi1=max([iint1(2,1) iint2(2,1)]);
    lo2=min([iint1(1,2) iint2(1,2)]);
    hi2=max([iint1(2,2) iint2(2,2)]);
    uoff1=(off11+off21)./2;
    uoff2=(off12+off22)./2;
elseif isequal(1e-5.*round(1e5.*iax12),1e-5.*round(1e5.*iax21))
    %must compare 1st col of iint1 with 2nd col of iint2, and v.v
    lo1=min([iint1(1,1) iint2(1,2)]);
    hi1=max([iint1(2,1) iint2(2,2)]);
    lo2=min([iint1(1,2) iint2(1,1)]);
    hi2=max([iint1(2,2) iint2(2,1)]);
    uoff1=(off11+off22)./2;
    uoff2=(off12+off21)./2;
else
    error('Horace error: logic flaw in horace_combine_2d. Contact R. Ewings for help');
end

irange=[lo1 lo2; hi1 hi2];
utmp=w1.data_.uoffset;
utmp(w1.data_.iax(1))=uoff1;
utmp(w1.data_.iax(2))=uoff2;
uoff=utmp;

function [sout,eout] = integrate_1d_points (x, s, e, xout)
% Integrate 1D point dataset for intervals in a set of bin boundaries.
%
%   >> [yout, eout] = integrate_1d_points (x, y, e, xout)
%
% Input:
%   x           input x values
%   y           input y values
%   e           input error bars
%   xout        output bin boundaries
%
% Output:
%   yout        output y values
%   eout        output error bars

%   T.G. Perring		2011-07-19		First release. Based very closely on INTEGRATE_1D_POINT in mgenie.

% disp('Matlab!')
% Perform checks on input parameters:
nx = numel(s);
if size(x) ~= nx
    error('Sizes of x and signal arrays do not correspond')
end
if numel(e) ~= nx
    error('Sizes of signal and error arrays do not correspond')
end
if nx <= 1
    error('Must have at least two data points to perform integration')
end

nb = numel(xout)-1;
if nb<1
    error('Sizes of output integration limits array too small (integrate_1d_points)')
end

% Perform integration
sout=zeros(1,nb);
eout=zeros(1,nb);

% Check that there is an overlap between the integration range and the points
if x(nx)<=xout(1) || xout(nb+1)<=x(1)
    return
end

% Get to starting output bin and input data point
if xout(1)>=x(1)
    ml=lower_index(x,xout(1));       % xout(1) <= x(ml)
    ib=1;
else
    ml=1;
    ib=upper_index(xout,x(1));       % xout(ib) <= x(1)
end

% At this point, we have xout(ib)<=x(ml) for the first output bin, index ib, that overlaps with input data range
% Now get mu s.t. x(mu)<=xout(ib+1)
while ib<=nb
    mu=ml-1;    % can have mu=ml-1 if there are no data points in the interval [xout(ib),xout(ib+1)]
    while mu<nx && x(mu+1)<=xout(ib+1)
        mu=mu+1;
    end
    % Gets here if 1) x(mu+1)>xout(ib+1), or (2) mu=nx in which case the last x point is in output bin index ib
    [sout(ib),eout(ib)] = single_integrate_1d_points(x,s,e,xout(ib),xout(ib+1),ml,mu);
    % Update ml for next output bin
    if mu==nx || ib==nb
        return  % no more output bins in the range [x(1),x(end)], or completed last output bin
    end
    ib=ib+1;
    if x(mu)<xout(ib)
        ml=mu+1;
    else
        ml=mu;
    end
end

%======================================================================================================================
function [val, errbar] = single_integrate_1d_points (x, s, e, xmin, xmax, ml, mu)
% Integrate point data between two limits
%
%   >> [val, errbar] = single_integrate_1d_points (x, s, e, xmin, xmax, ml, mu)
%
% Input:
%   x           x-coordinates of points
%   s           Signal
%   e           Error bars on signal
%   xmin        Lower integration limit
%   xmax        Upper integration limit
%   ml          Smallest ml such that xmin =< x(ml)
%   mu          Largest  mu such that x(mu)=< xmax
%
% Output:
%   val         Integral
%   errbar      Standard deviation on val
%
% The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
% the values in the array s.
%
% It is assumed that checks have been made to ensure that (1) xmin < xmax, and that (2) there is an overlap between the
% input x array and the interval [xmin,xmax] i.e. xmin =< x(ml) and x(mu) =< xmax for ml, mu in the range 1 to size(x)

%	T.G. Perring		2011-07-24		First release. Matlab translation of fortran code


% Perform integration:
nx = numel(x);

if mu<ml
    %	special case of no data points in the integration range
    ilo = max(ml-1,1);	% x(1) is end point if ml=1
    ihi = min(mu+1,nx);	% x(nx) is end point if mu=nx
    val = 0.5 * ((xmax-xmin)/(x(ihi)-x(ilo))) * ...
        ( s(ihi)*((xmax-x(ilo))+(xmin-x(ilo))) + s(ilo)*((x(ihi)-xmax)+(x(ihi)-xmin)) );
    errbar = 0.5 * ((xmax-xmin)/(x(ihi)-x(ilo))) * ...
        sqrt( (e(ihi)*((xmax-x(ilo))+(xmin-x(ilo))))^2 + (e(ilo)*((x(ihi)-xmax)+(x(ihi)-xmin)))^2 );
else
    %	xmin and xmax are separated by at least one data point in x(:)
    %	Set up effective end points:
    if ml>1	% x(1) is end point if ml=1
        x1eff = (xmin*(xmin-x(ml-1)) + x(ml-1)*(x(ml)-xmin))/(x(ml)-x(ml-1));
        s1eff = s(ml-1)*(x(ml)-xmin)/((x(ml)-x(ml-1)) + (xmin-x(ml-1)));
        e1eff = e(ml-1)*(x(ml)-xmin)/((x(ml)-x(ml-1)) + (xmin-x(ml-1)));
    else
        x1eff = x(ml);
        s1eff = 0;
        e1eff = 0;
    end
    if mu<nx	% x(mu) is end point if mu=nx
        xneff = (xmax*(x(mu+1)-xmax) + x(mu+1)*(xmax-x(mu)))/(x(mu+1)-x(mu));
        sneff = s(mu+1)*(xmax-x(mu))/((x(mu+1)-x(mu)) + (x(mu+1)-xmax));
        eneff = e(mu+1)*(xmax-x(mu))/((x(mu+1)-x(mu)) + (x(mu+1)-xmax));
    else
        xneff = x(nx);
        sneff = 0;
        eneff = 0;
    end
    
    %	xmin to x(ml):
    val = (x(ml)-x1eff)*(s(ml)+s1eff);
    errbar = (e1eff*(x(ml)-x1eff))^2;
    
    %	x(ml) to x(mu):
    if mu==ml		% one data point, no complete intervals
        errbar = errbar + (e(ml)*(xneff-x1eff))^2;
    elseif mu==ml+1	% one complete interval
        val = val + (s(mu)+s(ml))*(x(mu)-x(ml));
        errbar = errbar + (e(ml)*(x(ml+1)-x1eff))^2 + (e(mu)*(xneff-x(mu-1)))^2;
    else
        val = val + sum((s(ml+1:mu)+s(ml:mu-1)).*(x(ml+1:mu)-x(ml:mu-1)));
        errbar = errbar + (e(ml)*(x(ml+1)-x1eff))^2 + (e(mu)*(xneff-x(mu-1)))^2 ...
            + sum((e(ml+1:mu-1).*(x(ml+2:mu)-x(ml:mu-2))).^2);
    end
    
    %	x(mu) to xmax:
    val = val + (xneff-x(mu))*(s(mu)+sneff);
    errbar = errbar + (eneff*(xneff-x(mu)))^2;
    
    val = 0.5*val;
    errbar = 0.5*sqrt(errbar);
end

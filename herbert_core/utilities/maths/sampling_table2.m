function [xtab,cumpdf]=sampling_table2(x,pdf,step)
% Create lookup table from which to create random sampling of a probability distribution
%
%   >> [xtab,cumpdf]=sampling_table2(x,pdf)      % table with default number of points
%   >> [xtab,cumpdf]=sampling_table2(x,pdf,step) % table has specified number of points
%
% Differs from sampling_table in that cumpdf is not assumed to correspond to
% equally spaced intervals between 0 and 1.
%
% Use the output to generate random sampling as follows:
%   >> cumpdf_ran = rand(1000,50000);
%   >> X = interp1(cumpdf,xtab,cumpdf_ran,'pchip','extrap');
%
% or use the utility function rand_cumpdf2:
%   >> X = rand_cumpdf2 (xtab, cumpdf,...)
%
% Note that cumpdf may have more than one leading zero, and/or more than one
% trailing one, which will cause the interpolation to fail. 
%
% Input:
% -------
%   x       Vector of independent variable; strictly monotonic increasing and
%          at least three points.
%   pdf     Probability distribution: vector same number of elements as x,
%          and y(1)=y(end)=0, all other points >=0 and at least one point >0
%          The distribution does not need to be normalised; this will be
%          performed internally.
%   step    Define the graininess of the lookup table
%               npnt            Divide the range of x into npnt equally spaced
%                              values
%               [npnt, ndiv]    Divide each interval such that:
%                   npnt    Minimum number of points (at least 4)
%                   ndiv    How much finer to divide an interval at the minimum
%                               Default: [500,10]
%                               If one of the numbers is set to 0 or NaN then
%                              the default is used for the corresponding parameter
%               xtab            Explicitly give the output values
%
% Output:
% -------
%   xtab    Values of independent variable of the pdf at the values of the
%          cumulative pdf (column vector)
%   cumpdf  Cumulative probability distribution function (column vector)

% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% Default parameters
npnt_def = 500;     % minimum number of points in intermediate pdf (must be >=4)
ndiv_def = 10;      % how much finer to divide an interval at the minimum

% Parse input
x=x(:); pdf=pdf(:);
if numel(x)~=numel(pdf) || numel(x)<3
    error('x and y arrays must have the same number of elements and there must be at least three elements')
end
if ~all(diff(x))>0
    error('x values must be strictly monotonic increasing')
end
if pdf(1)~=0 || pdf(end)~=0 || any(pdf<0) || all(pdf==0)
    error('y array elements must all be >=0 and at least one >0')
end

if nargin==2
    step = [npnt_def,ndiv_def];
end

if isnumeric(step)
    if numel(step)==2 && ~any(step<0)
        % Case of [npnt, ndiv]
        if isnan(step(1)) || step(1)==0
            npnt_min = npnt_def;
        else
            if step(1)>=4
                npnt_min = step(1);
            else
                error('Must have npnt_min >=4')
            end
        end
        if isnan(step(2)) || step(2)==0
            ndiv_min = ndiv_def;
        else
            ndiv_min = step(2);
        end
        % Make array of x values at which to get cumulative integral
        n = numel(x);
        ndiv = max(ceil((npnt_min-1)/(n-1)),ndiv_min);
        dx = ((1:ndiv-1)/ndiv)'*diff(x)';
        xtab = [x(1:end-1)';(repmat(x(1:end-1)',ndiv-1,1) + dx)];
        xtab = [make_column(xtab); x(end)];
        
    elseif numel(step)==1 && step>=4
        % Case of number of points equally spaced over range of x
        xtab = (x(1)*(step-1:-1:0) + x(end)*(0:step-1))'/(step-1);
    elseif numel(step)>=4 && step(1)<=x(1) &&...
            step(end)>=x(end) && all(diff(step(:))>0)
        % Case of explicit values for the independent variable
        xtab = step(:);
    else
        error('Check the ''step'' parameter')
    end
else
    error('Check the ''step'' parameter')
end

% Evaluate integrals and get cumulative pdf
yout = integrate_1d_points_matlab (x, pdf, zeros(size(x)), xtab);
cumpdf = [0;cumsum(yout)];
cumpdf = cumpdf/cumpdf(end);


%======================================================================================================================
function [sout,eout] = integrate_1d_points_matlab (x, s, e, xout)
% Integrates point data along axis iax=1 of an IX_dataset_nd with dimensionality ndim=1.
%
%   >> [sout,eout] = integrate_1d_points_matlab (x, s, e, xout)
%
% Input:
% ------
%   x       Integration axis coordinates of points
%   s       Signal array
%   e       Standard deviations on signal array
%   xout    Array of integration axis coordinates between which to integrate
%          e.g. [x1,x2,x3,x4] outputs integrals in the range x1 to x2, x2 to x3, and x3 to x4
%           resulting in an array of integrals in output array sout (below) of length 3
%
% Output:
% -------
%   sout    Integrated signal
%   eout    Standard deviations on integrated signal

iax=1;
ndim=1;

% Perform checks on input parameters and initialise output arrays
% ---------------------------------------------------------------
nx=numel(x);
sz=[size(s),ones(1,ndim-numel(size(s)))];   % this works even if ndim=1, i.e. ones(1,-1)==[]
if nx<2
    error('Must have at least two data points to perform integration of point data')
end
if sz(iax)~=nx || numel(size(s))~=numel(size(e)) || any(size(s)~=size(e))
    error('Check sizes of input arrays')
end

nb = numel(xout)-1;
if nb<1
    error('Sizes of output integration limits array too small')
end
sz_out=sz;
sz_out(iax)=nb;

sout=zeros(sz_out);     % trailing singletons in sz do not matter - they are squeezed out in the call to zeros
eout=zeros(sz_out);

sz_wrk=sz;
sz_wrk(iax)=1;          % size of work array needed later

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
    [sout(ib),eout(ib)] = single_integrate_nd_iax_points_matlab_template(x,s,e,iax,xout(ib),xout(ib+1),ml,mu,sz_wrk);
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
function [val, errbar] = single_integrate_nd_iax_points_matlab_template (x, s, e, iax, xmin, xmax, ml, mu, sz_wrk)
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
        sqrt( (e(ihi)*((xmax-x(ilo))+(xmin-x(ilo)))).^2 + (e(ilo)*((x(ihi)-xmax)+(x(ihi)-xmin))).^2 );
else
    %	xmin and xmax are separated by at least one data point in x(:)
    %	Set up effective end points:
    if ml>1	% x(1) is end point if ml=1
        x1eff = (xmin*(xmin-x(ml-1)) + x(ml-1)*(x(ml)-xmin))/(x(ml)-x(ml-1));
        s1eff = s(ml-1)*(x(ml)-xmin)/((x(ml)-x(ml-1)) + (xmin-x(ml-1)));
        e1eff = e(ml-1)*(x(ml)-xmin)/((x(ml)-x(ml-1)) + (xmin-x(ml-1)));
    else
        x1eff = x(ml);
        s1eff = zeros(sz_wrk);
        e1eff = zeros(sz_wrk);
    end
    if mu<nx	% x(mu) is end point if mu=nx
        xneff = (xmax*(x(mu+1)-xmax) + x(mu+1)*(xmax-x(mu)))/(x(mu+1)-x(mu));
        sneff = s(mu+1)*(xmax-x(mu))/((x(mu+1)-x(mu)) + (x(mu+1)-xmax));
        eneff = e(mu+1)*(xmax-x(mu))/((x(mu+1)-x(mu)) + (x(mu+1)-xmax));
    else
        xneff = x(nx);
        sneff = zeros(sz_wrk);
        eneff = zeros(sz_wrk);
    end
    
    %	xmin to x(ml):
    val = (x(ml)-x1eff)*(s(ml)+s1eff);
    errbar = (e1eff*(x(ml)-x1eff)).^2;
    
    %	x(ml) to x(mu):
    if mu==ml		% one data point, no complete intervals
        errbar = errbar + (e(ml)*(xneff-x1eff)).^2;
    elseif mu==ml+1	% one complete interval
        val = val + (s(mu)+s(ml))*(x(mu)-x(ml));
        errbar = errbar + (e(ml)*(x(ml+1)-x1eff)).^2 + (e(mu)*(xneff-x(mu-1))).^2;
    else
        xwrk=repmat(reshape((x(ml+1:mu)-x(ml:mu-1)),[ones(1,iax-1),mu-ml,1]),sz_wrk);
        val = val + sum((s(ml+1:mu)+s(ml:mu-1)).*xwrk, iax);
        xwrk=repmat(reshape((x(ml+2:mu)-x(ml:mu-2)),[ones(1,iax-1),mu-ml-1,1]),sz_wrk);
        errbar = errbar + (e(ml)*(x(ml+1)-x1eff)).^2 + (e(mu)*(xneff-x(mu-1))).^2 ...
            + sum((e(ml+1:mu-1).*xwrk).^2, iax);
    end
    
    %	x(mu) to xmax:
    val = val + (xneff-x(mu))*(s(mu)+sneff);
    errbar = errbar + (eneff*(xneff-x(mu))).^2;
    
    val = 0.5*val;
    errbar = 0.5*sqrt(errbar);
end


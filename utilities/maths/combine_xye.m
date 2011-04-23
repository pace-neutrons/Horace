function [wout,ok,mess]=combine_xye(w,xjoin,delta,tol)
% Combine xye data
%
%   >> wout=combine_xye(w,xjoin,delta)
%
%   >> wout=combine_xye(w,xjoin,delta,tol)  % combine with tolerance
%
%   w       array of n structures, fields w.x, w.y, w.e
%   xjoin   array of x values at which to join the x arrays (n-1 values, i.e. one per overlap)
%   delta   width overlap regions (so merge over the range xjoin(i)-delta/2 to xjoin(i)+delta/2
%   tol     tolerance on x values
%               - if positive: absolute tolerance
%               - if negative: relative tolerance on smallest interval in all datasets
%           Default: relative tolerance of 10%  (i.e. tol=-0.1)
%         
%
% The elements of w must be either all histogram data or all to point data
% A tolerance for the x values is assumed, equal to 0.1


nw=numel(w);

% Check input data is histogram or point
dn=numel(w(1).x)-numel(w(1).y);
bad=false;
for i=1:nw
    if numel(w(i).x)-numel(w(i).y)~=dn;
        bad=true;
        break
    end
end
if ~bad && dn==0
    hist=false;
elseif ~bad && dn==1
    hist=true;
else
    wout=[]; ok=false; mess='Check input arrays correspond to all histogram or all point data';
    if nargout<=1, error(mess), end
    return
end

% Check intervals between x values
del=Inf;
for i=1:nw
    deltmp=min(diff(w(i).x));
    if ~isempty(deltmp)
        del=min(del,deltmp);
    end
end
if isinf(del)
    del=0;  % only one datapoint in each of the datasets
elseif del<=0
    wout=[]; ok=false; mess='Check input arrays have strictly monotonic increasing x values';
    if nargout<=1, error(mess), end
    return
end

% Get tolerance. Recall del=0 iff one data point per spectrum
if exist('tol','var')
    if tol<0
        abstol=abs(tol*del);
    else
        abstol=abs(tol);
    end
else
    abstol=0.1*del;
end

% Get the range of data that will be taken from each of the datasets
x=cell(1,nw);
irange=cell(1,nw);
for iw=1:nw
    if iw==1
        xlo=w(1).x(1); xhi=xjoin(iw)+delta/2;
    elseif iw==nw
        xlo=xjoin(iw-1)-delta/2; xhi=w(nw).x(end);
    else
        xlo=xjoin(iw-1)-delta/2; xhi=xjoin(iw)+delta/2;
    end
    [irange{iw},contained]=interval_in_array(w(iw).x,[xlo,xhi],hist);
    if isequal(contained,true)
        x{iw}=w(iw).x(irange{iw}(1):irange{iw}(2)+double(hist));
    else
        wout=[]; ok=false; mess='x values for the datasets do not all cover the required ranges for the merging of datasets';
        if nargout<=1, error(mess), end
        return
    end
end
[xout,irange_out,shared]=super_array(x{:},'tol',abstol);
if ~shared
    wout=[]; ok=false; mess='x values for the datasets are not coincident on the ranges over which they are merged';
    if nargout<=1, error(mess), end
    return
end

% Perform the convolution
if ~hist
    xrange = xout;
else
    xrange = 0.5*(xout(1:end-1)+xout(2:end));
end
wy=zeros(size(xrange));
we=zeros(size(xrange));
for i=1:nw
    if i==1,
        cent = xrange(1);
        width = 2*(xjoin(1)-xrange(1));
    elseif i==nw
        cent = xrange(end);
        width = 2*(xrange(end)-xjoin(nw-1));
    else
        cent = 0.5*(xjoin(i)+xjoin(i-1));
        width = xjoin(i)-xjoin(i-1);
    end
    smooth= hat2(width, 1, delta(1), 1/delta(1), xrange(irange_out{i}(1):irange_out{i}(2))-cent);
    wy(irange_out{i}(1):irange_out{i}(2)) = wy(irange_out{i}(1):irange_out{i}(2)) + smooth.*(w(i).y(irange{i}(1):irange{i}(2)));
    we(irange_out{i}(1):irange_out{i}(2)) = we(irange_out{i}(1):irange_out{i}(2)) + (smooth.*(w(i).e(irange{i}(1):irange{i}(2)))).^2;
end
we= sqrt(we);

wout.x=xout;
wout.y=wy;
wout.e=we;
ok=true;
mess='';


%=======================================================================================================
function y= hat2(w1, h1, w2, h2, x)

% function y=hat2(w1, h1, w2, h2, x)
% This function calculates the convolution of 2 hat functions centred 
% at 0 with widths w1, w2 and heights h1,h2, over a range given by x.

% Joost van Duijn: 29-08-03

if nargin<5,
    error('Insuficient number of paramters given');
end
if (w1<0)||(w2<0),
    error('Width of the 2 hat functions need to be positive');
end


% Irrespective of the input widths, the convolution will be calculated as
% that of of a broad top hat (width w, height p) with a narrow top hat
% (width delta, height q).
%
%             ____|____ delta*p*q
%            /    |    \
%           /     |    |\
% _________/______|____|_\___________ x
%                 0    |  w/2+delta/2
%                      w/2-delta/2
if w1>w2,
    w= w1;
    p= h1;
    delta= w2;
    q= h2;
elseif w1<w2,
    w= w2;
    p= h2;
    delta= w1;
    q= h1;
else
    w= w1;
    p= h1;
    delta= w2;
    q= h2;
end

x= abs(x);
y= zeros(size(x));

temp1= x<((w-delta)/2);
temp2= ((w-delta)/2)<=x&x<((w+delta)/2);

y(temp1)= delta*p*q;
y(temp2)= (delta*p*q)-(p*q*(x(temp2)-(w-delta)/2));

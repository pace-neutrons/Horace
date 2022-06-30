function [xout,irange,shared]=super_array(varargin)
% Create superset of elements from monotonic increasing arrays with an overlap region.
%
%   >> [xout,irange1,irange2,shared]=super_array(x1,x2,x3,...)
%   >> [xout,irange1,irange2,shared]=super_array(x1,x2,x3,...,'tol',tol)
%
% Input:
% -----------
%   x1, x2...   set of arrays, assumed monotonic increasing
%   tol         tolerance within which to define values to be equal
%               Default: no tolerance
%   
% Output:
% ----------
%   xout        superset of points in x1, x2, x3...
%   irange      Cell array of 1x2 arrays giving index of range of points in xout that match x1,x3,...
%   shared      =true   overlap or junction, with at least one point in common, between
%                       x1&x2, x2&x3, x3&x4,...
%               =false  not all shared ranges or junctions
%               =[]     overlap regions do not have all common points (and
%                       xout,irange1,irange2 will also be set to empty)

nw=numel(varargin);

% Find out if a tolerance has been given, else assume no tolerance
if nw>=2 && ischar(varargin{nw-1})
    if isequal(lower(varargin{nw-1}),'tol')
        tol=varargin{nw};
        nw=nw-2;
    else
        error('Check input argument types')
    end
else
    tol=0;    % accept no tolerance
end

% Check arguments are all numeric (apart from tolerance which has been dealt with above)
if nw>=2
    for i=1:nw
        if ~isnumeric(varargin{i})
            error('One or more arrays to be combined is not numeric')
        end
    end
else
    error('Must have at least two numeric array inputs')
end

xout=varargin{1};
irange=cell(1,nw);
irange{1}=[1,numel(varargin{1})];
shared=true;

for i=2:nw
    if tol==0
        [xout,irange1,irange2,shared_tmp]=super_array2(xout,varargin{i});
    else
        [xout,irange1,irange2,shared_tmp]=super_array2_tol(xout,varargin{i},tol);
    end
    if ~isempty(xout)
        shared = (shared & shared_tmp);
        for j=1:i-1
            irange{j}=irange{j}+(irange1(1)-1);
        end
        irange{i}=irange2;
    else
        irange=[]; shared=[];
        return,
    end
end

%===============================================================================================
function [xout,irange1,irange2,shared]=super_array2(x1,x2)
% Create superset of elements from two monotonic increasing arrays with an overlap region.
%
%   >> [xout,irange1,irange2,shared]=super_array(x1,x2)
%
%   x1, x2      two arrays, assumed monotonic increasing
%   
%   xout        superset of points in x1, x2
%   irange1     index of range of points in xout that match x1
%   irange2     index of range of points in xout that match x2
%   shared      =true   overlap or junction, with at least one point in common
%               =false  no shared range or junction
%               =[]     overlap region does not have all common points (and
%                       xout,irange1,irange2 will also be set to empty)

% Make row vectors for definitiveness
x1=x1(:)';
x2=x2(:)';

% find common range
xlo=max(x1(1),x2(1));
xhi=min(x1(end),x2(end));

if xlo>xhi  % no common elements possible
    if x1(1)<=x2(1)
        xout=[x1,x2];    % row vector
        irange1=[1,numel(x1)];
        irange2=numel(x1)+[1,numel(x2)];
    else
        xout=[x2,x1];    % row vector
        irange1=numel(x2)+[1,numel(x1)];
        irange2=[1,numel(x2)];
    end
    shared=false;
else
    ind1=(x1>=xlo&x1<=xhi);
    ind2=(x2>=xlo&x2<=xhi);
    if ~isequal(x1(ind1),x2(ind2))
        xout=[];irange1=[];irange2=[];shared=[];
    else
        if ind1(1)&&ind1(end)
            % x2 fully contains x1
            xout=x2;
            irange1=[find(ind2,1),find(ind2,1,'last')];
            irange2=[1,numel(x2)];
        elseif ind2(1)&&ind2(end)
            % x1 fully contains x2
            xout=x1;
            irange1=[1,numel(x1)];
            irange2=[find(ind1,1),find(ind1,1,'last')];
        elseif ind2(1)&&ind1(end)
            % neither fully contains the other; x1 extends to lower x, x2 to higher x
            xout=[x1,x2(find(ind2,1,'last')+1:end)];
            irange1=[1,numel(x1)];
            irange2=[numel(xout)-numel(x2)+1,numel(xout)];
        elseif ind1(1)&&ind2(end)
            % neither fully contains the other; x2 extends to lower x, x1 to higher x
            xout=[x2,x1(find(ind1,1,'last')+1:end)];
            irange1=[numel(xout)-numel(x1)+1,numel(xout)];
            irange2=[1,numel(x2)];
        else
            error('Logic problem - see T.G.Perring')
        end
        shared=true;
    end
end


%===============================================================================================
function [xout,irange1_out,irange2_out,shared]=super_array2_tol(x1_in,x2_in,tol)
% Create superset of elements from two monotonic increasing arrays with an overlap region.
%
%   >> [xout,irange1,irange2,shared]=super_array2_tol(x1,x2)
%
%   x1, x2      two arrays, assumed monotonic increasing
%   tol         tolerance within which to define values to be equal
%   
%   xout        superset of points in x1, x2
%   irange1     index of range of points in xout that match x1
%   irange2     index of range of points in xout that match x2
%   shared      =true   overlap or junction, with at least one point in common
%               =false  no shared range or junction
%               =[]     overlap region does not have all common points (and
%                       xout,irange1,irange2 will also be set to empty)

% Order arrays so that x1 has smaller or equal smallest first element
if x1_in(1)<=x2_in(1)
    x1=x1_in(:)';   % make row vector for definiteness
    x2=x2_in(:)';
    swap=false;
else
    x1=x2_in(:)';
    x2=x1_in(:)';
    swap=true;
end
    
n1=numel(x1);
n2=numel(x2);

% March through arrays finding common elements
tol=abs(tol);   % ensure >=0
if any(abs(diff(x1))<=tol) || any(abs(diff(x2))<=tol)
    warning('One or more array element spacings less than or equal to tolerance')
end
ilo=0;
j=1;
for i=1:n1
    if abs(x1(i)-x2(j))<=tol
        if ilo==0   % haven't started shared range yet
            ilo=i;
        end
        j=j+1;
        if j>n2
            break
        end
    elseif ilo~=0   % have previously started a range
        break
    elseif x1(i)>x2(j)  % overlap region, but not all common points
        xout=[]; irange1_out=[]; irange2_out=[]; shared=[];
        return
    end
end

if ilo~=0
    if i==n1
        xout=[x1,x2(j:end)];
        irange1=[1,n1];
        irange2=[ilo,numel(xout)];
    elseif j>=n2
        xout=x1;
        irange1=[1,n1];
        irange2=[ilo,ilo+n2-1];
    else
        xout=[]; irange1_out=[]; irange2_out=[]; shared=[];
        return
    end
    shared=true;
else
    xout=[x1,x2];
    irange1=[1,n1];
    irange2=[n1+1,n1+n2];
    shared=false;
end

% Swap back the order of first and second arrays
if ~swap
    irange1_out=irange1;
    irange2_out=irange2;
else
    irange1_out=irange2;
    irange2_out=irange1;
end

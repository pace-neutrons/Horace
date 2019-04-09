function [value,sigma]=value(w,x)
% Get the signal and standard error for the bin containing a point x in the plot
%
%   >> [s,e]=value(w,x)
%
% Input:
% ------
%   w       sqw object
%
%   x       Vector of coordinates in the display axes of the sqw object
%           The number of coordinates must match the dimensionality of the object.
%          e.g. for a 2D sqw object, x=[x1,x2], where x1, x2 are column vectors.
%           More than one point can be provided by giving more rows
%          e.g.  [1.2,4.3; 1.1,5.4; 1.32, 6.7] for 3 points from a 2D object.
%           Generally, an (n x nd) array, where n is the number of points, nd
%          the dimensionality of the object.
%
% Output:
% -------
%   value   Signal (column vector)
%   sigma   Standard deviation (column vector)


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


if numel(w)~=1
    error('Function only works on a single sqw object')
end

% Get dimensionality of points array
nd = dimensions(w);

% Catch case of zero dimensional object with no x argument
if nd==0 && nargin==0
    value=w.data.s;
    sigma=sqrt(w.data.e);
    return
end

% General case (including zero dimensional sqw object with x argument)
if nd==1 && isvector(x)    % we'll accept a row vector of values for 1D case only
    x=x(:); % guarantee is a column
end
if ~isnumeric(x)||numel(size(x))~=2||size(x,2)~=nd
    error('Check size of coordinate array')
else
    np=size(x,1);
    if np<1
        value=[];
        sigma=[];
        return
    end
end

p=w.data.p;
dax = w.data.dax;   % display axes permutation

value=NaN(np,1);
sigma=NaN(np,1);
ind=cell(1,nd);
ok=true(np,1);
for i=1:nd
    idim=dax(i);
    ind{idim}=upper_index(p{idim},x(:,i));
    ok(ind{idim}==0 | p{idim}(end)<x(:,i))=false;
end
for i=1:nd
    ind{i}=ind{i}(ok);
end
ix=sub2ind(size(w.data.s),ind{:});

value(ok)=w.data.s(ix);
sigma(ok)=sqrt(w.data.e(ix));

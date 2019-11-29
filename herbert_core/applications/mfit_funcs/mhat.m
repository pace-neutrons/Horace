function y = mhat(x, p)
% Multiple hat functions
% 
%   >> y = mhat(x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [h1, c1, wid1, h2, c2, wid2, ...]
%       where wid is the full width of a hat function
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

if rem(length(p),3)==0
    ntriangle=length(p)/3;
    ht=p(1:3:end);
    cen=p(2:3:end);
    wid=p(3:3:end);
    y=zeros(size(x));
    for i=1:ntriangle
        ok=abs(x-cen(i))<abs(wid(i))/2;
        y(ok)=y(ok) + ht(i);
    end
else
    error ('Check number of parameters')
end

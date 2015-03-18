function y = mtriangle(x, p)
% Multiple triangle functions
% 
%   >> y = mtriangle(x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [h1, c1, wid1, h2, c2, wid2, ...]
%       where wid is the full width half height of a triangle
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% R.A.Ewings, T.G.Perring

if rem(length(p),3)==0
    ntriangle=length(p)/3;
    ht=p(1:3:end);
    cen=p(2:3:end);
    wid=p(3:3:end);
    y=zeros(size(x));
    for i=1:ntriangle
        ok=abs(x-cen(i))<abs(wid(i));
        y(ok)=y(ok) + ht(i)*(1-abs((x(ok)-cen(i))/wid(i)));
    end
else
    error ('Check number of parameters')
end

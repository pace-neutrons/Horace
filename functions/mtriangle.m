function y = mtriangle(x, p)
% Multiple triangle peak functions
% 
%   >> y = mtriangle(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [h1, c1, wid1, h2, c2, wid2, ...]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% R.A. Ewings

% Simply calculate function at input values
if rem(length(p),3)==0
    ngauss=length(p)/3;
    ht=p(1:3:end);
    cen=p(2:3:end);
    sig=p(3:3:end);
    y=zeros(size(x));
    for i=1:ngauss
        s=sign(x-cen(i));
        y1=(sig(i)-s.*(x-cen(i)))/sig(i)^2;
        ff=find(y1<0);
        y1(ff)=zeros(size(ff));
        y=y + y1.*(ht(i).*sig(i));
%         s=sign(x-p(2));
%         y=(p(3)-s.*(x-p(2)))/p(3)^2;
%         f=find(y<0);
%         y(f)=zeros(size(f));
%         y=y*p(1)+p(4);
    end
else
    error ('Check number of parameters')
end
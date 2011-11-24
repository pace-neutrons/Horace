function y = mexpon(x, p)
% Multiple exponential functions: y = h*exp(-x/d)
% 
%   >> y = mexpon(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   Vector length 2n: [h1,d1,h2,d2,...]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

if rem(length(p),2)==0
    nexp=length(p)/2;
    ht=p(1:2:end);
    d=p(2:2:end);
    y=zeros(size(x));
    for i=1:nexp
        y=y + ht(i)*exp(-x/d(i));
    end
else
    error ('Check number of parameters')
end

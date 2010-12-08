function y = mgreen(x, p)
% Multiple green functions
% 
%   >> y = mgreen(x,p)
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
        y=y + (abs(sig(i).^2*ht(i))*cen(i)^2 ) ./ ( (cen(i)^2 - x.^2).^2 + (x*sig(i)).^2);
        %(abs(p(3)*p(1))*p(2)^2 ) ./ ( (p(2)^2 - x.^2).^2 + (x*p(3)).^2)
    end
else
    error ('Check number of parameters')
end
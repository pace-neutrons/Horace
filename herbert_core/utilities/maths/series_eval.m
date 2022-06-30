function val = series_eval (x,C,nmin)
% Compute a series expansion for an array of x values
%
%   >> val = series_eval (x,C)          % default nmin=0
%   >> val = series_eval (x,C,nmin)     % smallest power of x is x^nmin (nmin>=0)
%
% Calculates the series:
%
%   val = (x^nmin) * (C(1) + C(1)*C(2)*x^2 + ...
%                           + C(1)*C(2)*...*C(end)*x^(numel(C)-1)
%
% EXAMPLE: to evaluate 1-exp(-x) to x^6:
%       nmin = 1
%       C = [1, -1/2, -1/3, -1/4, -1/5, -1/6]


if numel(C)==0
    error('Coefficients array cannot be empty')
end
if nargin==3 && rem(nmin,1)~=0
    error('Minimum power must be integer >=0')
end
   
val = C(end)*ones(size(x));
for i=numel(C)-1:-1:1
    val = C(i)*(1+x.*val);
end

if ~(nargin==2 || nmin==0)
    if nmin>0
        val = val.*(x.^nmin);
    else
        val = val./(x.^nmin);
    end
end

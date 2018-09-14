function y=maps_flux_gain(ei)
% Gain factor in divergence due to guide on MAPS after the guide rebuid
%
%   >> y = maps_flux_gain (ei)
%
% Data from simulation performed by Russell Ewings with McStas with the 
% rebuilt MAPS geometry, using the MAPS guide and absorbing guide walls
%
% Input:
% ------
%   ei  Vector of incident energies
%
% Output:
% -------
%   y   Vector of calculated flux gain

lam=sqrt(81.804201263673718./ei);

% Parameters fitted to Rob Bewley McStas simulation to lambda=4. Good for lambda<=4.5
% and use linear approx for larger lambda
p=[2.278264717102751  18.892330866761206  -9.676733037636289...
    4.277079967209179  -0.873716983354024   0.091339606316616];
  
y=guide_gain_func(lam,p);

lam_max = 4.5;
dlam = 0.01;
const=guide_gain_func(lam_max,p);
grad =(guide_gain_func(lam_max+dlam,p) - guide_gain_func(lam_max-dlam,p))/(2*dlam);

big=(lam>lam_max);
y(big)=polynomial(lam(big)-lam_max,[const,grad]);

%----------------------------------------------------------------------------------------
function y = guide_gain_func (x,p)
% Function to parameterise guide flux gain. Exponential ensures gain->1 as x->0
x0=p(1);
y = 1 + exp(-x0./x).*polynomial(x,p(2:end));

%----------------------------------------------------------------------------------------
function y=polynomial(x,p)
% Polynomial function
%
%   >> y = polynomial (x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           y = p(1) + p(2)*x + p(3)*x.^2 + ...
%       The order of th polynomial is determined by the length of p.
%
% Output:
% ========
%   y   Vector of calculated y-axis values

n=numel(p);
if n>=1
    y=p(n)*ones(size(x));
    for i=n-1:-1:1
        y=x.*y+p(i);
    end
else
    error('Input parameters must be a vector of length greater or equal to 1');
end

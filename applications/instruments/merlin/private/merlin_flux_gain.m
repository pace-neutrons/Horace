function y=merlin_flux_gain(ei)
% Gain factor in divergence due to guide on MERLIN
%
%   >> y = merlin_flux_gain (ei)
%
% Input:
% =======
%   ei  Vector of incident energies
%
% Output:
% ========
%   y   Vector of calculated flux gain
%
% Data comes from McStas simulations by Rob Bewley c. September 2013 for
% MAPS instrumnet review. Simulations performed over wavelength range 0.5-4
% Ang i.e. c.5meV - c.320meV


lam=sqrt(81.804201263673718./ei);

% Parameters fitted to Rob Bewley McStas simulation to lambda=4. Good for lambda<=3.5
% and use linear approx for larger lambda
p=[1.000000000000000   0.723584927461204  -3.461019858758497   6.870176815937414  -3.962250897938358 ...
   0.960065940459538  -0.084008173502155];

y=polynomial(lam,p);

np=numel(p);
const=polynomial(3.5,p);
grad =polynomial(3.5,(1:np-1).*p(2:end));

big=(lam>3.5);
y(big)=polynomial(lam(big)-3.5,[const,grad]);

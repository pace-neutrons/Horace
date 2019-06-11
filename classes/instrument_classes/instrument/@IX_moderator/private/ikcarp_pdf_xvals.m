function t = ikcarp_pdf_xvals (npnt, tauf, taus)
% Return suitable reduced times for a pdf lookup table
%
% Input:
% ------
%   npnt    Desired number of points. The actual will be a little different
%   tauf    Epithermal decay constant (microseconds)
%   taus    Thermal decay constant (microseconds)


% Parameters to determine point density for the fast and convolution terms
Rmax = 15;     % Range of t: maximum multiple of tauf (or taus)
m = 2;      % Point of cross-over from equal t_red steps to constant fractin of tauf (or taus)

% Get times
t_fast = ikcarp_pdf_xvals_private (npnt/2, tauf, 3*tauf, m, Rmax);
t_slow = ikcarp_pdf_xvals_private (npnt/2, max(tauf,taus), 3*tauf+taus, m, Rmax);

t = unique([t_fast,t_slow]);

%---------------------------------------------------------------------------
function t = ikcarp_pdf_xvals_private (npnt, tau, t_av, m, Rmax)
% Construct times for lookup table

if Rmax*tau>m*t_av
    frac = (Rmax + (m^2)*(t_av/tau))/(npnt-1);
    nlo = round((t_av/tau)*(m*(m+1))/frac) + 1;
    nhi = max(1,round((Rmax - m*(t_av/tau))/frac));
    % For t <= m*t_av, equal spaced intervals of reduced time t/(t+t_av)
    t_red = ((0:(nlo-1))/(nlo-1))*(m/(m+1));
    tlo = t_av*(t_red./(1-t_red));
    % Fot t>m*t_av, equal intervals in t
    i = 1:nhi;
    thi = ((m*t_av)*(nhi-i) + (Rmax*tau)*i)/nhi;
    t = [tlo,thi];
else
    % Reduced time equal steps
    nlo = max(1,round(npnt));
    t_red = ((0:(nlo-1))/(nlo-1))*(m/(m+1));
    t = t_av*(t_red./(1-t_red));
end

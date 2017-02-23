function [t_red,t_av] = area_to_t_ikcarp (area, tauf, taus, R)
% Inverse function to cumulative integral of a normalised Ikeda-Carpenter function
%
%   >> x = area_to_t_ikcarp (area, tauf, taus, R)
%
% Input:
% ------
%   area    Array of areas (0 <=area <1) (Must be <1 as area=1 corresponds to t=Inf)
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term
%
% Output:
% -------
%   t_red   Array of reduced times t_red = t/(t+t_av) such that area is the integral from 0 to t
%           of the Ikeda-Carpenter function. t_av is the first moment of the Ikeda-Carpenter
%           function
%   t_av    First moment of the Ikeda-Carpenter function: t_av = 3*tauf + R*taus

% T.G.Perring 2011-07-22

options = optimset('Display', 'off'); % Turn off Display
t_av = 3*tauf + R*taus;
t_red = zeros(size(area));
for i=1:numel(area)
    aroot = area(i);
    if aroot==0
        t_red(i) = 0;
    elseif aroot==1
        t_red(i) = 1;
    else
        t_red(i) = fzero(@func, 0.5, options);
    end
end

    function y = func(x) % Compute the polynomial.
        if x<0
            y = -aroot;
        elseif x>=1
            y = 1 - aroot;
        else
    		t = t_av*x/(1-x);
            y = area_ikcarp(t,tauf,taus,R) - aroot;
        end
    end
end

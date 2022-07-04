function y = dsho_over_eps (en, en0, gam)
% Delta function response function divided by energy, broadened as DSHO
%
%   >> y = dsho_over_eps (en, en0, gam)
%
% This function broadens the delta function response:
%
%       (delta(en-en0) + delta(en+en0)) / en
% 
% as a damped siomple harmonic oscillator.
% Multiply by en/(1-exp(en/(kB*t))) as returned by the output of:
%
%       bose_times_eps(en,T)
%
% to get the DSHO broadened response of:
%
%       <n(en)+1>*delta(en-en0) + <n(en)>*delta(en+en0)
%
% Input:
% ------
%   en      Array of energy transfers
%   en0     Array of energies of the dispersion. Array with the same size
%          as en
%   gam     Inverse lifetime (same units as en and en0)
%          If gam is scalar, then expanded to the same size as en and en0
%
% Output:
% -------
%   y       Array of calculated response (has the same size as en)

y = ((4/pi)*abs(gam.*en0))./((en.^2-en0.^2).^2 + 4*(gam.*en).^2);

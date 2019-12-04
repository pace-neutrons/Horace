function weight = template_sqw_from_dispersion (qh,qk,ql,en,par)
% Template for a function to broaden a dispersion relation
%
%   >> weight = template_sqw_from_dispersion (qh,qk,ql,en,par)
%
% The template shows how take a delta-function dispersion relation 
%       (<n(en)+1>*delta(en-en(q)) + <n(en)>*delta(en+en(q)))
% where
%       <n(en)+1> = 1/(1-exp(en/kB.T))
%       <n(en)>   = 1/(exp(en/kB.T)-1)
% 
% and broaden it by the response for dampled simple harmonic oscillator with
% inverse lifetime gamma.
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [T, gamma, par(3), par(4),...]
%                   T               Temperature (K)
%                   gamma           Inverse lifetime (meV)
%                   par(3),par(4).. Parameters required to calculate the
%                                   dispersion relations
%
%              Note: each pair of spins in the Hamiltonian appears only once
% Output:
% -------
%   weight      Spectral weight

T = par(1);
gamma = par(2);

[wdisp,idisp] = my_dispersion_relation (qh,qk,ql,par(3:end));

if iscell(wdisp)     % cell array of output for one or more dispersion relations
    weight = zeros(size(wdisp{1}));
    for i=1:numel(wdisp)
        weight = weight + idisp{i} .* (dsho_over_eps (en, wdisp{i}, gamma) .* bose_times_eps(en,T));
    end
else    % must be numeric array for a valid, single, dispersion relation
    weight = idisp .* (dsho_over_eps (en, wdisp, gamma) .* bose_times_eps(en,T));
end

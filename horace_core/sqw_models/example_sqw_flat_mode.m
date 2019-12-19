function lor = example_sqw_flat_mode (qh,qk,ql,en,pars)
% Example model for S(Q,w)
% -------------------------------------------------------------------------
% A model for S(Q,w) must have the form:
%
% 	function ycalc = my_function (qh, qk, ql, en, par)
%
% More generally:
% 	function ycalc = my_function (qh, qk, ql, en, par, c1, c2,...)
%
% where
%   qh, qk, qk  Arrays of h, k, l in reciprocal lattice vectors, one element
%              of the arrays for each data point
%   en          Array of energy transfers at those points
%   par         A vector of numeric parameters that define the
%              function (e.g. [A,J1,J2] as scale factor and exchange parmaeters
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% -------------------------------------------------------------------------
% Dispersionless mode at non-zero energy en0 approximated as a Gaussian in energy
%
%   >> weight = example_sqw_flat_mode (qh,qk,ql,en,pars)
%
% Input:
% ------
%   qh, qk, ql, en  Arrays of Q and energy values at which to evaluate dispersion
%   pars            [Amplitude, en0, fwhh] - the area, centre at FWHH of a
%                   dispersionless mode
% Output:
% -------
%   weight          Spectral weight

HE=pars(1);
CE=pars(2);
GE=pars(3)/sqrt(log(256));
H1=pars(4);
G1=pars(5);
T=pars(6);

kb=1/11.606;
Eb = en/(kB * T);
if (w ~= 0)
    dbal=w/(1-exp(-wb));
else
	dbal=kB*T;
end

elastic=(HE/(GE * sqrt(2*pi))) * exp(-(en - CE)^2 / (2*GE^2));
inelastic = dbal * H1 / ((en - CE)^2 + G1^2);
lor = elastic + inelastic;



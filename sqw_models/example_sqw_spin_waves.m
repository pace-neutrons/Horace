function weight = example_sqw_spin_waves (qh,qk,ql,en,par)
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
% Spectral weight for body centred cubic Heisenberg ferromagnet
%
%   >> weight = example_sqw_spin_waves (qh,qk,ql,en,par)
%
% The spectral weight is for:
%       (S/2) * (<n(en)+1>*delta(en-en(q)) + <n(en)>*delta(en+en(q)))
% broadened by the response for dampled simple harmonic oscillator with
% inverse lifetime gamma.
%
% To get the neutron scattering cross-section per site you must multiply by
%       (kf/ki) * (gyro*r0)^2 * (1 + Qz^2) * (g*F(Q)/2)^2
% where
%       kf, ki      Final and incident neutron wavevectors
%       (gyro*r0)   290.6 mbarn
%       Qz          Component of unit momentum transfer along the moment direction
%       g           Electron gyronagnetic ratio
%       F(Q)        Magnetic form factor
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   en          Array of energy transfer
%   par         Parameters [T, gamma, Seff, gap, JS_p5p5p5, JS_100,...
%                                               JS_110, JS_3p5p5p5, JS_111]
%                   T       Temperature (K)
%                   gamma   Inverse lifetime (meV)
%                   Seff        Intensity scale factor
%                   gap         Gap at zone centre
%                   JS_p5p5p5   First neighbour exchange constant
%                   JS_100      Second neighbour exchange constant
%                   JS_110      Third neighbour exchange constant
%                   JS_3p5p5p5  Fourth neighbour exchange constant
%                   JS_111      Fifth neighbour exchange constant
%
%              Note: each pair of spins in the Hamiltonian appears only once
% Output:
% -------
%   weight      Spectral weight

T = par(1);
gamma = par(2);

[wdisp,idisp] = disp_bcc_hfm (qh,qk,ql,par(3:end));

weight = idisp{1} .* (dsho_over_eps (en, wdisp{1}, gamma) .* bose_times_eps(en,T));

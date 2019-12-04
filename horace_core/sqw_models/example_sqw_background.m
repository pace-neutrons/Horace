function weight = example_sqw_background (qh,qk,ql,en,pars)
% Background S(Q,w) model for cubic system
%
%   >> weight = example_sqw_background (qh,qk,ql,en,pars)
%
% Input:
% ------
%   qh, qk, ql, en  Arrays of Q and energy values at which to evaluate model
%   pars            Parameter [A,B,C,en0,D] in the model
%                      (A + B.*(Q.^2)) .* (C*exp(-en/en0) + D)
%                   where
%                       Q.^2 = (qh.^2+qk.^2+ql.^2)
% Output:
% -------
%   weight          Spectral weight


ampl=pars(1);
en0=pars(2);
sig=pars(3)/sqrt(log(256));

weight=(ampl/(sig*sqrt(2*pi)))*exp(-(en-en0).^2/(2*sig^2));

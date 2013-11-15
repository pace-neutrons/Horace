function weight = sqw_cylinder (qh,qk,ql,en,par)
% Create data set with cylindrical symmetry, axis being along a*
%
%   >> weight = sqw_cylinder (qh,qk,ql,en,par)
%
% Assumes lattice parmaeters satisfy b==c
%
% Input:
% ------
%   qh,qk,ql,en Arrays of h,k,l
%   par         Parameters  weight= par(1)*qh + par(2)*(qh^2+qk^2)
%
% Output:
% -------
%   weight      S(Q,w) calculation; in range 

weight=par(1)*qh +par(2)*(qk.^2+ql.^2);

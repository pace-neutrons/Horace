function pdf = ikcarp_param_recompute_pdf (pp, ei)
% Compute the pdf_table object for Ikeda-Carpenter pulse shape
%
%   >> pdf = ikcarp_recompute_pdf_ (pp, ei)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%   ei          Incident energy (meV) (scalar)
%
% Output:
% -------
%   pdf         pdf_table object


npnt=200;
[tauf, taus, R] = ikcarp_param_convert (pp, ei);
t = ikcarp_pdf_xvals (npnt, tauf, taus);
y = ikcarp (t, tauf, taus, R);
pdf = pdf_table(t,y);

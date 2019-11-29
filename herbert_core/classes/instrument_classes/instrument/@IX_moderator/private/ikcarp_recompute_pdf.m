function pdf = ikcarp_recompute_pdf (pp)
% Compute the pdf_table object for Ikeda-Carpenter pulse shape
%
%   >> pdf = ikcarp_recompute_pdf (pp)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%
% Output:
% -------
%   pdf         pdf_table object


npnt=200;
t = ikcarp_pdf_xvals (npnt, pp(1), pp(2));
y = ikcarp (t, pp(1), pp(2), pp(3));
pdf = pdf_table(t,y);

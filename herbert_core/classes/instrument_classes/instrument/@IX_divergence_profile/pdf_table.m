function pdf = pdf_table(obj)
% Return the pdf in an IX_divergence_profile object
%
%   >> pdf = pdf_table(obj)
%
% Input:
% ------
%   obj     IX_divergence_profile object
%
% Output:
% -------
%   pdf     pdf_table object for sampling from the divergence profile


if ~isscalar(obj), error('Method only takes a scalar divergence object'), end
pdf = obj.pdf_;

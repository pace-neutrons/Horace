function pdf = pdf_table(obj)
% Return the pdf in an IX_doubledisk_chopper object
%
%   >> pdf = pdf_table(obj)
%
% Input:
% ------
%   obj     IX_doubledisk_chopper object
%
% Output:
% -------
%   pdf     pdf_table object for sampling from the pulse shape


if ~isscalar(obj), error('Method only takes a scalar double disk chopper object'), end
pdf = obj.pdf_;

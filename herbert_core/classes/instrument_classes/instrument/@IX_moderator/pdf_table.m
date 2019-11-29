function pdf = pdf_table(obj)
% Return the pdf in an IX_moderator object
%
%   >> pdf = pdf_table(obj)
%
% Input:
% ------
%   obj     IX_moderator object
%
% Output:
% -------
%   pdf     pdf_table object for sampling from the pulse shape


if ~isscalar(obj), error('Method only takes a scalar moderator object'), end
if obj.valid_
    pdf = obj.pdf_;
else
    error('Internal state of the object is invalid so no df can be returned.')
end

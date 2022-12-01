function pdf = pdf_table (obj)
% Return the pdf in an IX_moderator object
%
%   >> pdf = pdf_table (obj)
%
% Input:
% ------
%   obj     IX_moderator object
%
% Output:
% -------
%   pdf     pdf_table object for sampling from the pulse shape


if ~isscalar(obj)
    error('IX_moderator:pdf_table:invalid_argument',...
        'Method only takes a scalar object')
end

pdf = obj.pdf_;

end

function [x_var, x_av] = var (obj)
% Variance and mean of a probability distribution
%
%   >> [x_var, x_av] = var (obj)
%
% Input:
% ------
%   obj     pdf_table object
%          (See <a href="matlab:help('pdf_table');">pdf_table</a> for details)
%
% Output:
% -------
%   x_var   Variance of the distribution obtained by linearly
%           interpolating the points that define the probability
%           distribution. Uses correct integration of the trapezoidal
%           function to return the variance.
%
%   x_av    First moment of the distribution obtained similarly.


if ~isscalar(obj)
    error('HERBERT:pdf_table:invalid_argument',...
        'Method only takes a scalar object')
end

[x_av, x_var] = moments_ (obj);

end

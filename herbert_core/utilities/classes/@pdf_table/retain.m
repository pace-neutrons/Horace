function ok = retain (obj, x)
% Retain independent variable values for a probability distribution
%
%   >> ok = retain (obj, x)
%
% Uses rejection ratio from the probability distribution with repect to a 
% uniform distribution
%
% Input:
% ------
%   obj     pdf_table object
%   x       Array of independent variable values
%
% Output:
% -------
%   ok      Logical array with the same size as x; true if the
%           corresponding point is retained, false if rejected


if ~isscalar(obj), error('Method only takes a scalar object'), end
if ~obj.filled
    error('The probability distribution function is not initialised')
end

ok = (x>=obj.x_(1) & x<=obj.x(end));        % remove points outside range
f = interp1(obj.x_,obj.f_,x(ok),'linear');  % linear interpolate remaining
ok(ok) = (f >= obj.fmax_*rand(size(f)));    % rejection ratio on those left

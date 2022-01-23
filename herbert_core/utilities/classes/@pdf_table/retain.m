function ok = retain (obj, x)
% Retain independent variable values according to a probability distribution
%
%   >> ok = retain (obj, x)
%
% Each element of an array of independent variable values, x, is randomly
% retained according to the value of the provided probability distribution
% as a function of x. More specifically, the algorithm uses the rejection
% ratio method with the probability distribution.
%
% EXAMPLE
% This method is useful for modifying a set of x-axis values by a further
% envelope function:
%
% Suppose a set of values x have been randomly sampled from distribution f,
% and we now want to obtain a set of values x for the product of f with
% another distribution, g, where the probability distribution g is a
% pdf_table object. This can be achieved by the following lines of code:
%
%       % Get a set of random deviates from a distribution f.
%       % This could be done, for example, from a pdf_table object created
%       % for the distribution f as below, or from another source:
%       >> f = pdf_table (...);
%       >> x = rand(f, [1e6,1]);    % get 10^6 random samples from f
%           :
%       % Now create a pdf_table object for the distribution g, then
%       % use the retain method (this method) to reject points according to
%       % g:
%       >> g = pdf_table (...);
%       >> ok = retain (g, x);
%       >> x = x(ok);
%
% Input:
% ------
%   obj     pdf_table object
%          (See <a href="matlab:help('pdf_table');">pdf_table</a> for details)
%
%   x       Array of independent variable values
%
% Output:
% -------
%   ok      Logical array with the same size as x; true if the
%           corresponding point is retained, false if rejected


if ~isscalar(obj)
    error('HERBERT:pdf_table:invalid_argument',...
        'Method only takes a scalar object')
end
if ~obj.filled
    error('HERBERT:pdf_table:uninitialised',...
        'The probability distribution function is not initialised')
end

ok = (x>=obj.x_(1) & x<=obj.x_(end));       % remove points outside range
f = interp1(obj.x_,obj.f_,x(ok),'linear');  % linear interpolate remaining
ok(ok) = (f >= obj.fmax_*rand(size(f)));    % rejection ratio on those left

end

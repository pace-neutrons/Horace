function y = truncdig(x,n)
%TRUNCDIG Truncate to a specified number of digits.
%
%   Y = TRUNCDIG(X, N) truncates the elements of X to N digits.
%
%   For instance, truncdig(10*sqrt(2) + i*pi/10, 4) returns 14.14 + 0.3141i
%
%   See also: FIX, FLOOR, CEIL, ROUND, FIXDEC, ROUNDDIG, ROUNDDEC.

%   Author:      Peter J. Acklam
%   Time-stamp:  2001-05-19 17:05:48 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

% Check number of input arguments.
if verLessThan('matlab', '7.13') %R2011b
    error(nargchk(2, 2, nargin));
else
    narginchk(2, 2);
end


% Quick exit if either argument is empty.
if isempty(x) || isempty(n)
    y = [];
    return
end

% quick exit if given 0 as arguments
if ~any(x(:)) || ~any(n(:))
    y = 0;
    return
end
% Get size of input arguments.
size_x   = size(x);
size_n   = size(n);
scalar_x = all(size_x == 1);         % True if x is a scalar.
scalar_n = all(size_n == 1);         % True if n is a scalar.

% Check size of input arguments and assign output argument.
if ~scalar_x && ~scalar_n && ~isequal(size_x, size_n)
    error([ 'When both arguments are matrices they must have' ...
        ' the same size' ]);
end

% Real part of X.
k = find(real(x));
if ~isempty(k)
    xreal = real(x(k));
    m     = nextpowof10(xreal);
    if scalar_x                       % X is scalar.
        f = 10.^(n - m);
        y = fix(xreal .* f) ./ f;
    else
        y = zeros(size_x);
        if scalar_n                    % N is scalar, X is not.
            f = 10.^(n - m);
        else                           % Neither X nor N is scalar.
            f = 10.^(n(k) - m);
        end
        y(k) = fix(xreal .* f) ./ f;
    end
end

% Imaginary part of X.
k = find(imag(x));
if ~isempty(k)
    ximag = imag(x(k));
    m = nextpowof10(ximag);
    if scalar_x                       % X is scalar.
        f = 10.^(n - m);
        y = y + i*fix(ximag .* f) ./ f;
    else
        if scalar_n                    % N is scalar, X is not.
            f = 10.^(n - m);
        else                           % Neither X nor N is scalar.
            f = 10.^(n(k) - m);
        end
        y(k) = y(k) + i*fix(ximag .* f) ./ f;
    end
end

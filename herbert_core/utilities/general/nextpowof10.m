function p = nextpowof10(x)
%NEXTPOWOF10 Next power of 10.
%
%   P = NEXTPOWOF10(X) returns the smallest integer P such that 10^P >= abs(X).
%
%   Essentially, NEXTPOWOF10(X) is the same as CEIL(LOG(ABS(X)) / LOG(10)), but
%   special care is taken to catch round-off errors.
%
%   See also PREVPOWOF2, NEXTPOW.

%   Author:      Peter J. Acklam
%   Time-stamp:  2003-11-17 11:38:03 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

if verLessThan('matlab', '7.13') %R2011b
    error(nargchk(1, 1, nargin));
else
    narginchk(1, 1);
end

if ~isreal(x)
    error('Input must be real.');
end

x = abs(x);
p = ceil(log(x) / log(10));          % estimate
k = x <= 10.^(p - 1);
p(k) = p(k) - 1;                     % correction

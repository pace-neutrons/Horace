function xtab=sampling_table(x,pdf,npnt)
% Create lookup table from which to create random sampling of a probability distribution
%
%   >> xtab=sampling_table(x,pdf)      % table with default number of points
%   >> xtab=sampling_table(x,pdf,npnt) % table has specified number of points
%
% Differs from sampling_table2 in that the points are assumed to correspond to
% equally spaced intervals of the cumulative probability distribution between
% 0 and 1.
%
% The utility function rand_cumpdf can be used to generate random points from
% the original probability distribution function:
%   >> X = rand_cumpdf (xtab,...)
%
% Input:
% -------
%   x       Vector of independent variable; strictly monotonic increasing and
%          at least three points.
%   pdf     Probability distribution: vector same number of elements as x,
%          and y(1)=y(end)=0, all other points >=0 and at least one point >0
%          The distribution does not need to be normalised; this will be
%          performed internally.
%   npnt    The number of points in the lookup table. Must be at least 4.
%          Default: npnt=500
%
% Output:
% -------
%   xtab    Values of independent variable of the pdf at equally spaced
%          values of the cumulative pdf (column vector) between 0 and 1.

% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


if nargin==2
    npnt=500;
end

% Create lookup table by linear interpolation that is much finer than the desired
% output
step = [10*npnt,0];
[xpdf,cumpdf] = sampling_table2(x,pdf,step);

% Remove excess zeros and ones at the ends of cumpdf; there is at least one of each
ilo=find(cumpdf==0,1,'last');
ihi=find(cumpdf==1,1,'first');
xpdf=xpdf(ilo:ihi);
cumpdf=cumpdf(ilo:ihi);

% Interpolate the lookup table 
A = [0; (1:npnt-2)'/(npnt-1); 1];
xtab = interp1(cumpdf,xpdf,A,'pchip','extrap');

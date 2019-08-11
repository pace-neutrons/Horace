function X = rand_cumpdf_arr(xtab,ind)
% Generate random numbers from a lookup table of probability distributions
%
%   >> X = rand_cumpdf_arr (xtab, ind)
%
% Works by linear interpolation.
%
% Input:
% ------
%   xtab        Array size [npnt,ndist] with xtab(:,i) containing the
%              x coordinates corresponding to equally spaced values of
%              the cumulative pdf (column vector) between 0 and 1, with
%              xtab(1,i) corresponding to cumulative pdf=0 and xtab(end,i)
%              for cumulative pdf=1.
%   ind         Array containing the probability distribution function
%              index from which a random number is to be taken.
%              min(ind(:))>=1, max(ind(:))<=ndist
%
% Output:
% -------
%   X           Array of random numbers from the distributions, with the
%              same size as ind.

% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


np = numel(ind);        % number of random points requested
npnt = size(xtab,1);    % number of points in cumulative pdf
ipnt = 1 + (npnt-1)*rand(np,1) + npnt*(ind(:)-1);     % random indicies (real) in open interval (1,npnt)
X = interp1(1:numel(xtab), xtab(:), ipnt, 'linear', 'extrap');
X = reshape(X,size(ind));


% % Previous version
% np = numel(ind);        % number of random points requested
% npnt = size(xtab,1);    % number of points in cumulative pdf
% 
% ipnt = 1 + (npnt-1)*rand(np,1);     % random indicies (real) in open interval (1,npnt)
% ix = npnt*(ind(:)-1) + floor(ipnt); % interval index in closed interval [1,npnt-1]
% dx = mod(ipnt,1);                   % distance from lower index
% 
% X = (1-dx).*xtab(ix) + dx.*xtab(ix+1);
% X = reshape(X,size(ind));

function rez=round_gen(X,varargin)
% Round towards nearest integer. 
% Compatibility funcion providing Matlab 2014b capabulities to earlie
% versions of matlab
%
% ROUND(X)      rounds the elements of X to the nearest integers.
% ROUND(X,N)    rounds the elements of X the specified number of significant digits.
%
%   See also FLOOR, CEIL, FIX.

if verLessThan('matlab','8.4')
    if nargin>1
        N = 10^round(varargin{1});
        rez = round(X*N)/N;
    else
        rez = round(X);
    end
else
    rez = round(X,varargin{1});
end

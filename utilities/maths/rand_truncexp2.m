function X = rand_truncexp2 (x0)
% Generate random number from a truncated exponential distribution
%
%   >> X = rand_truncexp (x0)
%
% Input:
% ------
%   x0          Truncation array: random numbers are chosen in the range (0,x0) for
%              the normalised distribution A*exp(-x)  where A=1/(1-exp(-x0))
%               The size of x0 defines the size of the returned random array
%               Must have all(x0(:)>=0) (Inf is allowed)
%
% Output:
% -------
%   X           Array of random numbers
%
%
% See also rand_truncexp, which generates random points for a scalar x0


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


if any(x0(:))<0 || any(isnan(x0(:)))
    error('The limit(s) of the truncated exponential(s) must be in range 0 to +Inf')
end

isx0inf=isinf(x0);
isx0small=(x0<0.01);

ninf=sum(isx0inf(:));
nsmall=sum(isx0small(:));
nmed=numel(x0)-ninf-nsmall;

if nmed==numel(x0)
    % All the points are in the intermediate regime
    X=-log(1-(1-exp(-x0)).*rand(size(x0)));
    
elseif ninf==numel(x0)
    % All the points are in the infinite regime
    X=-log(rand(size(x0)));
    
elseif nsmall==numel(x0)
    % All the points are in the small range limit
    X = rand_truncexp2_small(x0);
    
else
    % There are points in two, or all three, of the regimes
    X = NaN(size(x0));
    
    % Truncate exponential away from limiting cases of x0<<1 & x0==Inf
    if nmed>0
        isx0med=~(isx0inf|isx0small);
        if isrowvector(x0)
            X(isx0med)=-log(1-(1-exp(-x0(isx0med))).*rand(1,nmed));
        else
            X(isx0med)=-log(1-(1-exp(-x0(isx0med))).*rand(nmed,1));
        end
    end
    
    % Full range of exponential: [0,Inf]
    if ninf>0
        X(isx0inf)=-log(rand(ninf,1));
    end
    
    % Case when x0 is small: the intermediate algorithm below loses significant digits
    if nsmall>0
        X(isx0small) = rand_truncexp2_small(x0(isx0small));
    end
    
end

%--------------------------------------------------------------------------------------------------
function X = rand_truncexp2_small (x0)
% All the points are in the small range limit
sz=size(x0);
X = x0.*rand(sz);
y = rand(sz);
reject = (y>exp(-X));
if sum(reject(:))>0
    X(reject)=rand_truncexp2_small(x0(reject)); % recursively replace rejected points
end

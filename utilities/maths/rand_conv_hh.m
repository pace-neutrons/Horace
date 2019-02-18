function X = rand_conv_hh (w1, w2, varargin)
% Random numbers from convolution of two hat functions centred at x=0
%
%   >> y = rand_conv_hh (w1, w2)
%   >> y = rand_conv_hh (w1, w2, n)
%   >> y = rand_conv_hh (w1, w2, sz)
%   >> y = rand_conv_hh (w1, w2, sz1, sz2, ...)
%
% The distribution is (for w2>w1; reverse w1 and w2 if w1>w2):
%
%             ____|____ height = 1/w2
%            /    |    \
%           /     |    |\
% _________/______|____|_\___________ x
%                 0    |  (w2+w1)/2
%                      (w2-w1)/2
%
% Input:
% ------
%   w1, w2      Full width of two hat functions. Absolute value used
%               for negative values. 
%
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Works even if one or both of w1 and w2 are zero


if w1==0 && w2==0
    % Delta function at the origin
    X = zeros(varargin{:});
elseif w1==0
    % Hat function in w2
    X = abs(w2)*(rand(varargin{:})-0.5);
elseif w2==0
    % Hat function in w1
    X = abs(w1)*(rand(varargin{:})-0.5);
elseif abs(w1)==abs(w2)
    % Triangle function
    X = abs(w1)*rand_triangle(varargin{:});
else
    % General case of both w1 and w2 non zero
    if abs(w2)>abs(w1)
        r = abs(w1/w2);
        wbig = abs(w2);
    else
        r = abs(w2/w1);
        wbig = abs(w1);
    end
    A = rand(varargin{:})-0.5;
    sgn = wbig*sign(A); % retain sign of A
    A = abs(A);         % 0<=A<=0.5
    % Fill up as if A<=Acrit
    X = A;
    % Now refill those X where A>Acrit
    Acrit = (1-r)/2;
    big = (A>Acrit);
    X(big) = (Acrit^2 + (2*r)*A(big))./ ((1+r)/2 + sqrt(r*abs(1-2*A(big))));
    X = sgn.*X;
end

function area = area_conv_hh (x, w1, w2)
% Integrated area of convolution of two hat functions from -Inf
%
%   >> area = area_conv_hh (x, w1, w2)
%
%   w1, w2  Full width of two hat functions. Absolute value used
%           for negative values


area = zeros(size(x));
if w1==0 && w2==0
    % Delta function at the origin
    area(x>0) = 1;
elseif w1==0
    % Hat function in w2
    range = (abs(x)<abs(w2)/2);
    area(range) = (x(range)+abs(w2)/2)/w2;
    area(x>=abs(w2)/2) = 1;
elseif w2==0
    % Hat function in w2
    range = (abs(x)<abs(w1)/2);
    area(range) = (x(range)+abs(w1)/2)/w1;
    area(x>=abs(w1)/2) = 1;
else
    if abs(w2)>abs(w1)
        wbig = abs(w2);
        wsmall = abs(w1);
    else
        wbig = abs(w1);
        wsmall = abs(w2);
    end
    r = wsmall/wbig;
    eps = 0.5*(wbig+wsmall) - abs(x);
    % Outside convolution:
    area(eps<=0) = 0;
    % In slope region:
    eps_norm = eps/wsmall;
    range = (eps>0 & eps_norm<1);
    area(range) = (0.5*r)*(eps_norm(range)).^2;
    % In flat region
    range = (eps>0 & ~(eps_norm<1));
    area(range) = (0.5*r) + (1/wbig)*(eps(range) - wsmall);
    
    % Invert area for x>0:
    range = (x>0);
    area(range) = 1 - area(range);
end

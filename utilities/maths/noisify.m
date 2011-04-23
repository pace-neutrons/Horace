function [yout,eout] = noisify (y,e,varargin)
% Adds noise to y values and associated error bars. The arrays y, e must
% have same size.
%
% Syntax:
%   >> [yout,eout] = noisify (y,e)
%   >> [yout,eout] = noisify (y,e,factor)
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum y value); default factor is 0.1
%
%   >> [yout,eout] = noisify (y,e,'poisson')
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value y.
%

if nargin==3 && isa_size(varargin{1},'vector','char')
    if strcmpi(varargin{1},'poisson')
        yout=zeros(size(y));
        for i=1:prod(size(y))
            yout(i)=randpoisson(abs(y(i)));
        end
        eout=sqrt(e.^2+abs(y));  % the inpuy y is the man (and variance) of the Poisson distribution
    else
        error('Unrecognised random sampling distribution')
    end
else
    if nargin==3
        if isa_size(varargin{1},[1,1],'numeric')
            fac = varargin{1};
        else
            error('Noise as fraction of peak signal must be real scalar')
        end
    else
        fac = 0.1;
    end
    ymax = max(abs(reshape(y,1,prod(size(y)))));    % find maximum magnitude of y for arbitrary dimensions
    dy=(fac*ymax)*randn(size(y));
    yout=y+dy;
    eout=sqrt(e.^2+(fac*ymax)^2);
end

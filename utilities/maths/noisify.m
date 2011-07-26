function [yout,eout] = noisify (y,e,varargin)
% Adds noise to y values and associated error bars. The arrays y, e must
% have same size.
%
% Syntax:
%   >> yout = noisify (y)
%   >> [yout,eout] = noisify (y)
%   >> [yout,eout] = noisify (y,e)
%           Add noise with Gaussian distribution, with standard deviation
%           = 0.1*(maximum y value)
%
%   >> [yout,eout] = noisify (y,e,factor)
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum y value)
%
%   >> [yout,eout] = noisify (y,e,'poisson')
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value y.
%
%   If no input errors, e, just set e=[]

if nargin==3 && ischar(varargin{1})
    if isstringmatchi(varargin{1},'poisson')
        yout=zeros(size(y));
        for i=1:numel(y)
            yout(i)=randpoisson(abs(y(i)));
        end
        eout=abs(y);  % the inpuy y is the mean and variance of the Poisson distribution
    else
        error('Unrecognised random sampling distribution')
    end
else
    if nargin==3
        if isnumeric(varargin{1}) && isscalar(varargin{1})
            fac = varargin{1};
        else
            error('Noise as fraction of peak signal must be real scalar')
        end
    else
        fac = 0.1;
    end
    ymax = max(abs(y(:)));          % find maximum magnitude of y for arbitrary dimensions
    dy=(fac*ymax)*randn(size(y));   % st. dev. of randn is sigma=1
    yout=y+dy;
    eout=ones(size(y))*(fac*ymax)^2;
end

if exist('e','var') && isempty(e)
    if isequal(size(e),size(eout))
        eout=sqrt(eout+e.^2);
    else
        error('Input array of error bars must have same size as input y array')
    end
else
    eout=sqrt(eout);
end

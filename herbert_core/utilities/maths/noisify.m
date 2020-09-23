function [yout,eout] = noisify (y,e,varargin)
% Adds noise to y values and associated error bars. The arrays y, e must
% have same size. y is the signal and e is its variance (not standard
% deviation)
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
%   >> [yout, eout] = noisify(y,e,factor,maxval)
%           Add noise with Gaussian distribution, calculating the standard
%           deviation by an externally provided maximum y value.
%           Typically this will be the overall maximum value if the
%           data is processed page by page and the maximum must be
%           extracted before this processing.
%           Setting factor<0.0 will use the default value 0.1.
%
%   If no input errors, e, just set e=[]

if nargin==3 && ischar(varargin{1})
    if is_stringmatchi(varargin{1},'poisson')
        yout=zeros(size(y));
        for i=1:numel(y)
            yout(i)=randpoisson(abs(y(i)));
        end
        eout=abs(y);  % the input y is the mean and variance of the Poisson distribution
    else
        error('Unrecognised random sampling distribution')
    end
else % 3rd arg did not exist or was not a distribution name
    default_fac = 0.1;
    if nargin>=3 % 3 args for fac or 4 args for fac and maxval
        if isnumeric(varargin{1}) && isscalar(varargin{1})
            fac = varargin{1};
            if fac < 0.0 % default option if 4th arg is needed
                fac = default_fac;
            end
        else
            error('Noise as fraction of peak signal must be real scalar')
        end
    else
        fac = default_fac;
    end
    if nargin==4 % means the maxval arg has been used
        ymax = varargin{2};             % use max value previously extracted
    else
        ymax = max(abs(y(:)));          % find maximum magnitude of y for arbitrary dimensions
    end
    dy=(fac*ymax)*randn(size(y));   % st. dev. of randn is sigma=1
    yout=y+dy;
    eout=ones(size(y))*(fac*ymax)^2;
end

% this code now outputs a variance to be consistent between the use of eout
% in the Poisson distribution section, the input definition for e and this
% output.
%
% this code now adds e (an input *variance* rather than std deviation) to
% eout if it exists rather than if it does not.
if exist('e','var') && ~isempty(e)
    if isequal(size(e),size(eout))
        eout=eout+e;
    else
        error('Input array of error bars must have same size as input y array')
    end
end

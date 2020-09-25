function [yout,eout] = noisify (y,e,varargin)
% Adds noise to y values and associated error bars. The arrays y, e must
% have same size. y is the signal and e is its variance.
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
%   >> [yout, eout] = noisify(y,e,[factor,]'maxval',maxval)
%           Add noise with Gaussian distribution, calculating the standard
%           deviation by an externally provided maximum y value.
%           The max value is preceded by a keyword string 'maxval'.
%           Typically this value will be the overall maximum value if the
%           data is processed page by page and the maximum must be
%           extracted before this processing.
%           Omitting factor will use the default value 0.1.
%
%   If no input errors, e, just set e=[]

% Use Poisson distribution and ignore other arguments
if nargin==3 && ischar(varargin{1}) && is_stringmatchi(varargin{1},'poisson')
        yout=zeros(size(y));
        for i=1:numel(y)
            yout(i)=randpoisson(abs(y(i)));
        end
        eout=abs(y);  % the input y is the mean and variance of the Poisson distribution
        return % RETURN here as the poisson route is independent of the other argument options
end

% If not return, use normal distribution with or without an input maximum signal:
default_fac = 0.1;
ymax = [];
fac = default_fac;
if nargin>=3
    % Check for maxval keyword and set ymax, else calc ymax locally below
    pos = find(strcmp(varargin,'maxval')==1);
    if ~isempty(pos) && pos<size(varargin,2)
        ymax = varargin{pos+1};
    else
        error('Could not find maxval value arg with maxval specified')
    end
    % Check for input of fac as 3rd arg, set to default otherwise
    if isempty(pos) || pos ~= 1
        if isnumeric(varargin{1}) && isscalar(varargin{1})
            fac = varargin{1};
        else
            error('Noise as fraction of peak signal must be real scalar')
        end
    else
        fac = default_fac;
    end
end

% Check for any other distribution in arg #3
if nargin>=3 && ischar(varargin{1}) && ~is_stringmatchi(varargin{1},'maxval')
    error('Unrecognised random sampling distribution')
end

% if ymax was not set by an argument, set from max of |y|
if isempty(ymax)
    ymax = max(abs(y(:)));
end
    
% make noise dy and add to y for output; make error bar for noise    
dy=(fac*ymax)*randn(size(y));   % st. dev. of randn is sigma=1
yout=y+dy;
eout=ones(size(y))*(fac*ymax)^2;

% this code now outputs a variance to be consistent between the use of eout
% in the Poisson distribution section, the input definition for e and this
% output.
%
% adds e (the input variance) to eout if it exists 
% (it may not,see @sqw/nosify)
if exist('e','var') && ~isempty(e)
    if isequal(size(e),size(eout))
        eout=eout+e;
    else
        error('Input array of error bars must have same size as input y array')
    end
end

function [yout,eout] = noisify(y,e,varargin)
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
%   >> [yout, eout] = noisify(y,e,[factor,]'maximum_value',maxval)
%           Add noise with Gaussian distribution, calculating the standard
%           deviation by an externally provided maximum y value.
%           The max value is preceded by a keyword string 'maximum_value'.
%           Typically this value will be the overall maximum value if the
%           data is processed page by page and the maximum must be
%           extracted before this processing.
%           Omitting factor will use the default value 0.1.
%
%   If no input errors, e, just set e=[]. Note that eout will be created
%   regardless of whether e is present, so the first overload output is
%   probably incomplete.

% deal with optional arguments
is_poisson = false;
fac = 0.1;
if nargin>=2 % avoids the case where the only paramemter is y; for >=2 e will not be optional
    [fac, is_poisson, ymax] = parse_args(y, e, fac, is_poisson, varargin{:});
end

% Use Poisson distribution and ignore other arguments
if is_poisson
    yout=zeros(size(y));
    for i=1:numel(y)
        yout(i)=randpoisson(abs(y(i)));
    end
    eout=abs(y);  % the input y is the mean and variance of the Poisson distribution
else
    % if ymax was not set by an argument, set from max of |y|
    if ymax == get_maximum_signal_value('default')
        ymax = get_maximum_signal_value(y);
    end

    % make noise dy and add to y for output; make error bar for noise    
    dy=(fac*ymax)*randn(size(y));   % st. dev. of randn is sigma=1
    yout=y+dy;
    eout=ones(size(y))*(fac*ymax)^2;
end

% adds e (the input variance) to eout if it exists 
% (it may not,see @sqw/nosify)
if exist('e','var') && ~isempty(e)
    if isequal(size(e),size(eout))
        eout=eout+e;
    else
        error('HERBERT:noisify', 'Input array of error bars must have same size as input y array')
    end
end
end

function [fac, is_poisson, ymax] = parse_args(y, e, fac, is_poisson, varargin)
    p = inputParser;
    addRequired(p, 'y', @isnumeric);   % y compulsory
    addRequired(p, 'e', @isnumeric);   % e compulsory if any of remaining optional/parameter arguments present
    numeric_or_poisson = @(x) isnumeric(x) || strcmpi(x,'poisson');
    addOptional(p, 'dist_or_factor', fac, numeric_or_poisson);  % fac (numeric) or distribution ('poisson') optional, default to fac=0.1
    addParameter(p,'maximum_value', get_maximum_signal_value('default'), @isnumeric);  % ymax, as parameter 'maximum_value'. Default to internally set negative value.
    parse(p,y,e,varargin{:});

    % pick up signal max value as either default or input
    ymax = p.Results.maximum_value;

    % vary if 'poisson' or fac present
    if isnumeric(p.Results.dist_or_factor)
        fac = p.Results.dist_or_factor;
    elseif strcmpi(p.Results.dist_or_factor, 'poisson')
        is_poisson = true;
    else
        error('HERBERT:noisify', '3rd argument cannot be interpreted as a Gaussian factor or legal probability distribution')
    end
end

function ymax = get_maximum_signal_value(y)
    USE_LOCAL_MAX = -inf; % should ensure that no actual y values can be confused with this
    if ischar(y) && strcmpi(y,'default')
        ymax = USE_LOCAL_MAX
    else
        ymax = max(abs(y(:)))
    end
end

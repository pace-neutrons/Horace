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
%   >> [yout, eout] = noisify(...{as above}..., 'random_number_function', rnd)
%            Developer option only. Choose rnd as an alternative to the
%            normal Horance choice of randn as the random number
%            distribution. Only for testing. More notes below at the call.
%
%   If no input errors, e, just set e=[]. Note that eout will be created
%   regardless of whether e is present, so the first overload output is
%   probably incomplete.

    % deal with optional arguments
    fac = 0.1;
    is_poisson = false;
    ymax_calculated = false;
    randfunc = @randn;
    if nargin>=2 % avoids the case where the only paramemter is y; for >=2 e will not be optional
        [fac, is_poisson, ymax, randfunc] = parse_args(y, e, fac, varargin{:});
        ymax_calculated = true;
    end

    % Use Poisson distribution and ignore other arguments
    if is_poisson
        yout=zeros(size(y));
        for i=1:numel(y)
            yout(i)=randpoisson(abs(y(i)));
        end
        eout=abs(y);  % the input y is the mean and variance of the Poisson distribution
    else
        if ~ymax_calculated
            ymax = max(abs(y(:)));
        end
        % make noise dy and add to y for output; make error bar for noise.  
        % randfunc generates the random numbers producing the noise;
        % its standard and default implementation is randn - gaussian of std.dev=1
        % but other choices may be appropriate including a non-random
        % sequence to check functionality. Not using randn may cause
        % unexpected behaviour from the user point of view
        dy=(fac*ymax)*randfunc(size(y));
        yout=y+dy;
        eout=ones(size(y))*(fac*ymax)^2;
    end

    % adds e (the input variance) to eout if it exists 
    % (it may not,see @sqw/noisify)
    if exist('e', 'var') && ~isempty(e)
        if isequal(size(e),size(eout))
            eout=eout+e;
        else
            error('HERBERT:noisify', 'Input array of error bars must have same size as input y array')
        end
    end
end

function [fac, is_poisson, ymax, randfun] = parse_args(y, e, fac, varargin)
    USE_LOCAL_MAX = -inf;
    p = inputParser;
    addRequired(p, 'y', @isnumeric);   % y compulsory
    addRequired(p, 'e', @isnumeric);   % e compulsory if any of remaining optional/parameter arguments present
    numeric_or_poisson = @(x) isnumeric(x) || strcmpi(x,'poisson');
    addOptional(p, 'dist_or_factor', fac, numeric_or_poisson);  % fac (numeric) or distribution ('poisson') optional, default to fac=0.1
    addParameter(p,'maximum_value', USE_LOCAL_MAX, @isnumeric);  % ymax, as parameter 'maximum_value'. Default to internally set negative value.
    check_function_handle = @(x) isa(x,'function_handle');
    addParameter(p,'random_number_function', @randn, check_function_handle); 
    parse(p,y,e,varargin{:});

    % vary if 'poisson' or fac present
    is_poisson = false;
    if isnumeric(p.Results.dist_or_factor)
        fac = p.Results.dist_or_factor;
    elseif strcmpi(p.Results.dist_or_factor, 'poisson')
        is_poisson = true;
    else
        error('HERBERT:noisify', '3rd argument cannot be interpreted as a Gaussian factor or legal probability distribution')
    end
    
    randfun = p.Results.random_number_function;
    
    % pick up signal max value as either default or input
    ymax = p.Results.maximum_value;
    if ~is_poisson && ymax == USE_LOCAL_MAX
        ymax = max(abs(y(:)));
    end 
end

function wout = smooth (win, varargin)
% Smooths an IX_dataset_1d
%
%   >> wout = smooth (win, width, shape)
%
% Input:
% ------
%   win     Input IX_dataset_1d or array of IX_dataset_1d objects
%   width   Scalar that sets the extent of the smoothing - the interpretation
%          depends on the shape function below.
%   shape   Shape of smoothing function (can be abbreviated to minimum unambiguous length):
%               'hat'           Hat function
%                                   - width gives FWHH along each dimension in pixels
%                                   - width = 1,3,5,...;  n=0 or 1 => no smoothing
%               'gaussian'      Gaussian; width gives FWHH along each dimension in pixels
%                                   - elements where more than 2% of peak intensity
%                                     are retained
%               'lorentzian'    Lorentzian; width gives FWHH along each dimension in pixels
%                                   - elements where more than 2% of peak intensity
%                                     are retained
%
% Output:
% -------
%   wout    Smoothed IX_dataset_1d or array of IX_dataset_1d objects

% Original author: T.G.Perring
%
% Note that the smoothing works on the numerical values of the signal, and ignores
% whether or not it is distribution or not.

% List available functions and set defaults.
shapes = {'hat'; 'gaussian';'lorentzian'};       % internally available functions for convolution
width_default = 3;
shape_default = 'hat';

% Check width parameter
if nargin>=2
    width = varargin{1};
else
    width = width_default;
end
if ~(isnumeric(width) && isscalar(width))
    error ('Argument ''width'' must be a scalar or vector with length equal to the dimensions of the dataset')
end

% Check shape parameter
if nargin>=3
    shape = varargin{2};
else
    shape = shape_default;
end
if ~isempty(shape) && is_string(shape)
    ishape = stringmatchi (shape,shapes);
    if numel(ishape)>1
        error ('Ambiguous convolution function name')
    elseif isempty(ishape)
        error (['Function ''',shape,''' is not recognised as an available option'])
    end
else
    error ('Argument ''shape'' must be a character string')
end

% Construct normalised convolution table
if ishape==1    % hat
    c = ones([max(1,2*floor(width/2)+1),1]);
elseif ishape==2    % Gaussian
    if width>0
        f = 0.02;   % convolution matrix will extend to the 2% level of Gaussian
        fac = sqrt(log(1/f)/(4*log(2)));    % magnitude f occurs at multiple fac of FWHH
        n = floor(fac*max(0,width));        % if width < 0, assume width=0
        c = exp(-(4*log(2))*((-n:n)/width).^2)';
    else
        c = 1;
    end
elseif ishape==3    % Lorentzian
    if width>0
        gamma = width/2;
        f = 0.02;   % convolution matrix will extend to the 2% level of Lorentzian
        fac = sqrt((1-f)/f);            % magnitude f occurs at multiple fac of gamma
        n = floor(fac*max(0,width));    % if width < 0, assume width=0
        c = (gamma/pi)./((-n:n).^2 + gamma.^2)';
    else
        c = 1;
    end
end
c=c/sum(c);

% Smooth data structure
wout=win;

m=warning('off','MATLAB:divideByZero');     % turn off divide by zero messages, saving present state
for i=1:numel(win)
    try
        index = isfinite(win(i).signal);            % elements with finite signal
        weight = convn(double(index),c,'same');     % weight function including only points where there is data
        % Explicitly ensure zero signal and error at non-finite signal for the convolution algorithm
        signal=win(i).signal; signal(~index)=0;
        signal = convn(signal,c,'same')./weight;    % points with no data (i.e. signal = 0) do not contribute to convolution
        err=win(i).error; err(~index)=0;
        err = sqrt(convn(err.^2,c.^2,'same')./(weight.^2));
        % Restore signal to those points with non-finite data
        signal(~index) = win(i).signal(~index);
        err(~index) = win(i).error(~index);
        clear weight            % save memory
        % Fill output object
        wout(i).signal = signal;
        wout(i).error = err;
    catch
        warning(m.state,'MATLAB:divideByZero');     % return to previous divide by zero message state
        rethrow(lasterror)
    end
end
warning(m.state,'MATLAB:divideByZero');     % return to previous divide by zero message state

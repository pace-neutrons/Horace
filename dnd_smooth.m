function d = dnd_smooth (din, varargin)
% Smooths a 1,2,3 or 4 dimensional dataset
%
%Syntax:
%   >> d = dnd_smooth (din, width, shape)
%
% Input:
% ------
%   din     Input dataset structure
%   width   Vector that sets the extent of the smoothing along each dimension.
%          The interpretation of width depends on the argument 'shape' described
%          below.
%           If width is scalar, then the value is applied to all dimensions
%
%           e.g. if din is a 3-dimensional dataset, valid arguments for width might be:
%                width = [2,4,5]    % 2, 3, 5 along the 1st, 2nd and 3rd dimensions
%                width = 4.5        % 4.5 applied to all dimensions
%           Invalid choices for 3-dimensions are
%                width = [2,3]      % invalid number of dimensions
%
%   shape   Shape of smoothing function
%               'hat'           hat function
%                                   - width gives FWHH along each dimension
%                                   - width = 1,3,5,...;  n=0 or 1 => no smoothing
%               'gaussian'      Gaussian; width gives FWHH along each dimension
%                                   - elements where more than 2% of peak intensity
%                                     are retained
%
% Output:
% -------
%   dout    Smoothed data structure

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% List available functions and set defaults. If more functions are to be
% added as smoothing options, then place in the Horace private directory
shapes = {'hat'; 'gaussian'};       % available functions for convolution
shape_handle = {@hat; @gaussian};   % corresponding function handles
width_default = 3;
shape_default = 'hat';
ishape = 1;

% Check input parameters
ndim = length(din.pax);   % no. dimensions of the data

if nargin==1
    nargs = 0;
elseif nargin==2 & iscell(varargin{1}) % interpret as having been passed a varargin (as cell array is not a valid type to be passed to cut_data)
    args = varargin{1};
    nargs= length(args);
else
    args = varargin;
    nargs= length(args);
end

if nargs==0
    width = width_default*ones(1,ndim);
    shape = shape_default;
end
    
if nargs>1
    % Check size of width
    width = args{1};
    if ~(isa_size(width,[1,ndim],'double') | isa_size(width,[1,1],'double'))
        error ('ERROR: argument ''width'' must be a scalar or vector with length equal to the dimensions of the dataset')
    elseif isa_size(width,[1,1],'double')
        width = width*ones(1,ndim); % if input is scalar, expand to dimension of dataset
    end
    if nargs==1
        shape = shape_default;
    else
        shape = args{2}
    end
end

% check shape
if isa_size(shape,'row','char')
    ishape = string_find (shape,shapes);
    if ishape<0
        error ('ERROR: Ambiguous convolution function name')
    elseif ishape==0
        error (['ERROR: Function ''',shape,''' is not recognised as an available option'])
    end
else
    error ('ERROR: argument ''shape'' must be a character string')
end

% Catch trivial case of zero dimensional dataset
if ndim==0
    d = din;
    return
end

% Create convolution array
c = shape_handle{ishape}(width);    % use function handles to create matrix - can add further functions above wihout altering remaining code

% Smooth data structure
m=warning('off','MATLAB:divideByZero');     % turn off divide by zero messages, saving present state

signal = din.s ./ din.n;
err = din.e ./ (din.n.^2);

index = din.n~=0;   % elements with non-zero counts
signal(~index) = 0; % in principle not needed,as signal should be zero, but apply in case dataset constructed badly
err(~index) = 0;    % likewise

weight = convn(double(index),c,'same');     % weight function including only points where there is data
signal = convn(signal,c,'same')./weight;    % points with no data (i.e. signal = 0) do not contribute to convolution
err = convn(err,c,'same')./weight;

warning(m.state,'MATLAB:divideByZero');     % return to previous divide by zero message state

signal(~index) = 0;     % restore zero signal to those bins with no data
err(~index) = 0;
clear weight            % save memory (may be critical for 4D datasets)
if ndim==4
    nout = int16(ones(size(signal)));
else
    nout = ones(size(signal));
end
nout(~index) = 0;

% Create output structure
d = din;
d.s = signal;
d.e = err;
d.n = nout;

function wout = noisify (w,varargin)
% Adds random noise to an IX_dataset_1d or array of IX_dataset_1d
%
% Syntax:
%   >> wout = noisify (w)
%           Add noise with Gaussian distribution, with standard deviation
%           = 0.1*(maximum y value)
%
%   >> wout = noisify (w,factor)
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum y value)
%
%   >> wout = noisify (w,'poisson')
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value y.
%
wout=w;
for i=1:numel(w)
    [wout(i).signal,wout(i).error]=noisify(w(i).signal,w(i).error,varargin{:});
end

function wout = smooth (win, varargin)
% Smooths a one dimensional dataset
%
% Syntax:
%   >> wout = smooth (win, width, shape)
%
% Input:
% ------
%   win     Input dataset structure
%   width   Vector that sets the extent of the smoothing.
%           The interpretation of width depends on the argument 'shape' described
%          below.
%
%   shape   Shape of smoothing function
%               'hat'           hat function
%                                   - width gives FWHH
%                                   - width = 1,3,5,...;  n=0 or 1 => no smoothing
%               'gaussian'      Gaussian
%                                   - width gives FWHH
%                                   - elements where more than 2% of peak intensity
%                                     are retained
%
% Output:
% -------
%   wout    Smoothed data structure
%
% The input dataset is converted to a libisis IXTdataset_1d and then
% operated upon. It is then converted back. 

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

wout = dnd_data_op(win, @smooth, 'd1d' , 1 , varargin{:});
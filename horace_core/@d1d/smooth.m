function wout = smooth (win,varargin)
% Smooths a one dimensional dataset given smoothing parameters in number of pixels
%
% Syntax:
%   >> wout = smooth (win, width, shape)
%
% Input:
% ------
%   win     Input dataset structure
%   width   Sets the extent of the smoothing along each dimension.
%          The interpretation of width depends on the argument 'shape' described
%          below.
%
%   shape   [Optional] Shape of smoothing function [Default: 'hat']
%               'hat'           hat function
%                                   - width gives FWHH along each dimension in pixels
%                                   - width = 1,3,5,...;  n=0 or 1 => no smoothing
%               'gaussian'      Gaussian
%                                   - width gives FWHH along each dimension in pixels
%                                   - elements where more than 2% of peak intensity
%                                     are retained
%
% Output:
% -------
%   wout    Smoothed data structure


% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(smooth(sqw(win),varargin{:}));


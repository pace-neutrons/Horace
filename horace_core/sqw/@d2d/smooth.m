function wout = smooth (win,varargin)
% Smooths a two dimensional dataset given smoothing parameters in number of pixels
%
% Syntax:
%   >> wout = smooth (win, width, shape)
%
% Input:
% ------
%   win     Input dataset structure
%   width   Vector that sets the extent of the smoothing along each dimension.
%          The interpretation of width depends on the argument 'shape' described
%          below.
%           If width is scalar, then the value is applied to all dimensions
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
%               'resolution'    Correlated Gaussian (suitable for e.g. powder data)
%
% Output:
% -------
%   wout    Smoothed data structure


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(smooth(sqw_old(win),varargin{:}));


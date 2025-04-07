function wout = smooth(win, varargin)
% Smooths a 1,2,3 or 4 dimensional dataset.
%
%Syntax:
%   >> dout =  smooth(din, width, shape)
%
% Input:
% ------
%   din     Input DnD object

%   width   Vector that sets the extent of the smoothing along each dimension.
%           The interpretation of width depends on the argument 'shape' described
%           below.
%           If width is scalar, then the value is applied to all dimensions
%
%           e.g. if din is a 3-dimensional dataset, valid arguments for width might be:
%                width = [2,4,5]    % 2, 3, 5 along the 1st, 2nd and 3rd dimensions
%                width = 4.5        % 4.5 applied to all dimensions
%           Invalid choices for 3-dimensions are
%                width = [2,3]      % invalid number of dimensions
%
%   shape   Shape of smoothing function
%               'hat'           Hat function
%                                   - width gives FWHH along each dimension
%                                   - width = 1,3,5,...;  n=0 or 1 => no smoothing
%               'gaussian'      Gaussian; width gives FWHH along each dimension in pixels
%                                   - elements with more than 2% of peak intensity
%                                     are retained
%
%               'resolution'    Correlated Gaussian - 2D only (suitable for e.g. powder data)
%
% Output:
% -------
%   dout    Smoothed data structure

wout = arrayfun(@(x)smooth_dnd_(x,false,varargin{:}),win);

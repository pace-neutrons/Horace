function wout_dnd = smooth(win, varargin)
% Smooth method - gateway function for smoothing attached dnd object.
%
% N.B. drops pixel data from input sqw and returns array of dnds
%
% Input:
% ------
%   win     SQW to smooth
%
%   xunit   If true, unit of measure is length of a unit along each axis
%           If false, unit of measure is pixels
%
%   width   Vector that sets the extent of the smoothing along each dimension.
%           The interpretation of width depends on the argument 'shape' described
%           below.
%
%           If width is scalar, then the value is applied to all dimensions
%
%           e.g. if win.data is a d3d, valid arguments for width might be:
%                width = [2,4,5]    % 2, 4, 5 along the 1st, 2nd and 3rd dimensions
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
%
% Output:
% -------
%   wout_dnd    Smoothed data structure (now a dnd)
%
% Original author: T.G.Perring
%

% return cellarray of corresponding dnd objects
wout_dnd = dnd(win,'-cell');

% apply dnd smooth method to dnd conversion of input win
wout_dnd = cellfun(@(x) smooth(x, varargin{:}), wout_dnd);

end

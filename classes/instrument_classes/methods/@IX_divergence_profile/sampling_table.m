function xtab=sampling_table(obj,varargin)
% Create lookup table from which to create random sampling of divergence profile
%
%   >> xtab=sampling_table(obj)         % table with default number of points
%   >> xtab=sampling_table(obj,npnt)    % table has specified number of points
%
% Differs from sampling_table2 in that the points are assumed to correspond to
% equally spaced intervals of the cumulative probability distribution between
% 0 and 1.
%
% The utility function rand_cumpdf can be used to generate random points from
% the original probability distribution function:
%   >> X = rand_cumpdf (xtab,...)
%
% Input:
% -------
%   obj     IX_divergence_profile object
%   npnt    The number of points in the lookup table. Must be at least 4.
%          Default: npnt=500
%
% Output:
% -------
%   xtab    Values of independent variable of the pdf at equally spaced
%          values of the cumulative pdf (column vector) between 0 and 1.

% Original author: T.G.Perring
%
% $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)


if ~isscalar(obj), error('Function only takes a scalar object'), end

xtab=sampling_table(obj.angle,obj.profile,varargin{:});

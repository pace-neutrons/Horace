function X = rand (obj, varargin)
% Random points in detector(s) in a detector bank
%
%   >> X = rand (obj, wvec)
%   >> X = rand (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_detector_bank object
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   X           Array of random points in the detector coordinate frame(s).
%               The output is a stack of column 3-vectors, with the size of 
%               the stacking array being whichever of ind or wvec is an
%               array. A leading singleton dimension is squeezed away.
%
%               EAMPLES
%                   size(wvec) == [2,5]     ==> size(X) == [3,2,5]
%                   size(wvec) == [1,5]     ==> size(X) == [3,5]
%                   size(wvec) == [1,1,5]   ==> size(X) == [3,1,5]
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec.
%
%               A single random point X = [x,y,z]' is in the frame
%                   x   In range -R to R, where R is the inner radius of the tube,
%                       and the x axis is the projection of the neutron direction
%                       of travel perpendicular to the tube axis in the plane of
%                       the tube axis and direction of travel
%                   y   In range -R to R, where y is perpendicular to the
%                       x-axis and the tube axis.
%                   z   Along the direction of the tube axis


% Original author: T.G.Perring


X = func_eval (obj, @rand, varargin{:});

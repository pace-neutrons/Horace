function [x,y] = random_points (obj, wvec, sintheta, varargin)
% Return an array of random points in a 3He cylindrical detector
%
% Scalar wvec and sintheta:
%   >> [x,y] = random_points (obj, wvec)
%   >> [x,y] = random_points (obj, wvec, sintheta)
%   >> [x,y] = random_points (obj, wvec, sintheta, n)
%   >> [x,y] = random_points (obj, wvec, sintheta, sz)
%   >> [x,y] = random_points (obj, wvec, sintheta, sz1, sz2,...)
%
% Array wvec, sintheta, or both
%   >> [x,y] = random_points (obj, wvec)
%   >> [x,y] = random_points (obj, wvec, sintheta)
%
%
% Input:
% -------
%   obj         IX_He3tube object
%   wvec        Wavevector of absorbed neutrons (Ang^-1). (Scalar or array)
%   sintheta    Sine of the angle between the cylinder axis and
%              the direction of travel of the neutron i.e. sintheta=1 when
%              the neutron hits the detector perpendicular to the tube
%              axis. (Scalar or array)
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
%   Note: either or both of wvec and sintheta can be arrays, but if both
%   are arrays then they must have the same size and shape.
%
% Output:
% -------
%   x           Array of x coordinates in range -R to R, where R is the
%              inner radius of the tube, and the x axis is the projection
%              of the neutron direction of travel perpendicular to the
%              tube axis in the plane of the tube axis and direction of travel
%   y           Array of y coordinates, where y is perpendicular to the
%              x-axis and the tube axis.


if nargin==2, sintheta = 1; end

alf = macro_xs_dia (obj, wvec) ./ sintheta;
inner_rad = obj.inner_rad;

% Get random x,y in reduced units
if isscalar(alf)
    [x,y] = rand_xy (alf, varargin{:});  
elseif nargin<4     % array of alf, so cannot have size arguments
    [x,y] = rand_xy2 (alf, varargin{:});  
else
    error('Check input arguments')
end

% Convert to true units
% (Note that we do not need to multiply by sintheta to project perpendicular
% to the tube axis, as this projection is implicit when multiply by
% just inner_rad)
x = inner_rad * (2*x - sqrt(1-y.^2));
y = inner_rad * y;

%--------------------------------------------------------------------------
function [x,y] = rand_xy(alf, varargin)
x = rand_truncexp (alf, varargin{:}) / alf;
y = 2*rand(varargin{:}) - 1;
reject = (x.^2 >= 1-y.^2);
n = sum(reject(:));
if n>0
    [x(reject),y(reject)]=rand_xy(alf,[n,1]);
end

%--------------------------------------------------------------------------
function [x,y] = rand_xy2(alf)
x = rand_truncexp2 (alf) ./ alf;
y = 2*rand(size(alf)) - 1;
reject = (x.^2 >= 1-y.^2);
if sum(reject(:))>0
    [x(reject),y(reject)]=rand_xy2(alf(reject));
end

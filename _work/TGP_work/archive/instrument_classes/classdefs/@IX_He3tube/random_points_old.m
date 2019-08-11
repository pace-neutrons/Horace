function [x,y] = random_points (obj, wvec, sintheta, varargin)
% Return an array of random points in a 3He cylindrical detector
%
%   >> [x,y] = random_points (obj, wvec, sintheta, n)
%   >> [x,y] = random_points (obj, wvec, sintheta, sz)
%   >> [x,y] = random_points (obj, wvec, sintheta, sz1, sz2,...)
%
% Input:
% -------
%   obj         IX_He3tube object
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar.
%   sintheta    Sine of the angle between the cylinder axis and
%              the direction of travel of the neutron i.e. sintheta=1 when
%              the neutron hits the detector perpendicular to the tube
%              axis. Scalar.
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   x           Array of x coordinates in range -R to R, where R is the
%              inner radius of the tube, and th x axis is the projection 
%              of the neutron direction of travel perpendicular to the 
%              tube axis
%   y           Array of y coordinates, where y is perpendicular to the
%              x-axis and the tube axis.


alf = macro_xs_dia (obj, wvec) / sintheta;
inner_rad = obj.inner_rad;

% Get random x,y in reduced units
[x,y] = rand_xy (alf, varargin{:});

% Convert to true units
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

function X = rand (obj, varargin)
% Return an array of random points in a 3He cylindrical detector
%
% Scalar wvec and sintheta:
%   >> X = rand (obj, wvec)
%   >> X = rand (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_He3tube object
%
%   ind         Indicies of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%
% If both ind and wvec are arrays, then they must have the same number of elements
%
%
% Output:
% -------
%   X           Array of random points.
%               The size of the array is [3,size(ind)]. with any singleton
%              dimensions in sz squeezed away
%               A single random point X = [x,y,z]' are in the frame
%                   x   In range -R to R, where R is the inner radius of the tube,
%                       and the x axis is the projection of the neutron direction
%                       of travel perpendicular to the tube axis in the plane of
%                       the tube axis and direction of travel
%                   y   In range -R to R, where y is perpendicular to the
%                       x-axis and the tube axis.
%                   z   Along the direction of the tube


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


[ind, wvec] = parse_ind_and_wvec_ (obj, varargin{:});
alf = macro_xs_dia (obj, ind, wvec);

% Reduced units
[x,y] = rand_xy2 (alf);  

% Convert to true units
% (Note that we do not need to multiply by sintheta to project perpendicular
% to the tube axis, as this projection is implicit when multiply by
% just inner_rad)
if ~isscalar(ind)
    inner_rad = reshape(obj.inner_rad(ind), size(alf));
    cotantheta = reshape(obj.costheta_(ind)./obj.sintheta_(ind),size(alf));
    height = reshape(obj.height_(ind),size(alf));
else
    inner_rad = obj.inner_rad;
    cotantheta = obj.costheta_/obj.sintheta_;
    height = obj.height_;
end

x = inner_rad .* (2*x - sqrt(1-y.^2));
y = inner_rad .* y;

% Along tube axis. Note that we need to get the projection of the attenuation
% along the z-axis
z = cotantheta.*x + height.*(rand(size(alf))-0.5);

% Repackage in standard shape
X = squeeze(reshape([x(:)';y(:)';z(:)'],[3,size(alf)]));


%--------------------------------------------------------------------------
function [x,y] = rand_xy2(alf)
x = rand_truncexp2 (alf) ./ alf;
y = 2*rand(size(alf)) - 1;
reject = (x.^2 >= 1-y.^2);
if sum(reject(:))>0
    [x(reject),y(reject)]=rand_xy2(alf(reject));
end


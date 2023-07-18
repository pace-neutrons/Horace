function [ok, ipix] = get_nearest_pixels (win, xp)
% Find the nearest pixel to each point of an array along the plot axes
%
%   >> [ok, ipix] = get_nearest_pixels (win, xp)
%
% The algorithm determines which bin the point is in, and then finds the
% nearest pixel in that bin. If a point is in a bin without pixels, or lies
% outside the sqw object, then it is ignored
%
% Input:
% ------
%   win     A single sqw object
%
%   xp      Point or points for which to determine the nearest pixel;
%          array size  [n, np], where np is the number of plot axes and
%          n the number of points
%
% Output:
% -------
%   ok      Logical column vector length equal to the number of points
%          where
%           - 1 indicates the point has a nearest pixel in the bin in
%            which the point sits
%           - 0 indicates the point lies in a bin without any contributing
%            pixels, or the point lies outside the range of the sqw dataset
%
%   ipix    Column vector with the indicies of the nearest pixel to each
%          for which ok is true; that is for those points given by xp(ok,:)
%
%           The nearest pixel is defined as that which has minimum distance
%          in terms of step size along each axis from the point defined by
%          xp along the plot axes and median coordinate of the pixels along
%          the integration axes.


if numel(win)>1
    error('HORACE:get_nearest_pixels:invalid_argument',...
        'Only a single instance of an sqw object can be passed.')
end

nd = numel(win.data.pax);
sz = size(win.data.npix);
np = size(xp,1);
if ~ismatrix(xp)
    error('HORACE:get_nearest_pixels:invalid_argument',...
        'Coordinate array must be a row vector or two-dimensional array.')
elseif size(xp, 2) ~= nd
    error('HORACE:get_nearest_pixels:invalid_argument',...
        'Number of coordinates in the point does not match the dimensions of the sqw object.')
end

% Catch case of no query points on input
% ----------------------------------------
if np == 0
    ok = false(0,1);
    ipix = zeros(0,1);
    return
end

% One or more points given
% --------------------------
% Get some 'pointers' to particular properties of the sqw object, for convenience
iax = win.data.iax;
pax = win.data.pax;
npix = win.data.npix(:);

% Find the bin corresponding to each point
ix = win.data.axes.bin_points(xp);
ok = ~any(isnan(ix), 2);
ix = ix(ok, :);
ix = num2cell(ix, 1);

ind = sub2ind(sz, ix{:});


keep = (npix(ind)>0);
ok(ok) = keep;
xp_ok = xp(ok,:);
ind = ind(keep);

% Determine the nearest pixel to each point
% -----------------------------------------
% Catch case of no points in the data
if ~any(ok)
    ipix = zeros(0,1);
    return
end

% Get coordinates of points along each projection axis
step = win.data.axes.get_bin_step()';
ustep = step(pax)';
xpstep = xp_ok ./ repmat(ustep,size(xp_ok,1),1);

ipix = zeros(numel(ind),1);
nend = cumsum(npix);
nbeg = nend - npix + 1;

ucent = zeros(1,4);
for i=1:numel(ind)
    % Projections for pixels in the bin
    curr_pix = win.pix.get_pix_in_ranges(nbeg(ind(i)), npix(ind(i)));

    % Get components along projection axes of the pixels in the sqw object
    uprojstep_bin = (win.data.proj.transform_pix_to_img(curr_pix) ./ step)';

    % Point in steps: median coordinates along integration axes
    ucent(iax) = median(uprojstep_bin(:,iax),1);
    ucent(pax) = xpstep(i,:);

    % Distance of all pixels to point:
    dist = vecnorm(uprojstep_bin - ucent, 2, 2);

    [~,ipix(i)] = min(dist);
end

ipix = nbeg(ind) + ipix - 1;    % to get index in the full pixels array

end

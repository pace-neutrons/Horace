function [xp, ipix, ok] = get_nearest_pixels (win, xp_in)
% Get the the indicies of the nearest pixels to an array of points along the plot axes
%
%   >> [xp, ipix, ok] = get_nearest_pixels (win, xp_in)
%
% Input:
% ------
%   win     sqw object
%   xp_in   Row vector length np, or n x np array, where np is the number of 
%          plot axes, and n the number of points
%
% Output:
% -------
%   xp      Row vector length np, or n x np array, where n is now the 
%          number of retained points, that is, ones which lie in the range
%          of the data and which lie in bins that have at least one pixel
%   ipix    Column vector, length n, with the corresponding indicies of the
%          nearest pixel to each point.
%           The nearest pixel is defined as that which has minimum distance
%          in terms of step size along each axis from the point defined by
%          xp along the plot axes and median coordinate of the pixels along
%          the integration axes.
%   ok      Column vector of length n, which acts as a flag for retained
%           points. xp = xp_in(ok,:);

nd = numel(win.data.pax);
sz = size(win.data.npix);
np = size(xp_in,1);
if size(xp_in,2)~=nd
    error('Number of coordinates in the point does not match dimensions of sqw object')
end

iax = win.data.iax;
pax = win.data.pax;
p = win.data.p;
npix = win.data.npix(:);

% Find the bin corresponding to each point
ix = cell(1,nd);
ok = true(np,1);
for i=1:nd
    [~,ix{i}] = histc(xp_in(:,i),p{i});
    ix{i} = min (ix{i},numel(p{i})-1);  % catch if on final bin boundatry
    ok = ok & ix{i}>0;
end

% Check points are where there is data
for i=1:nd
    ix{i} = ix{i}(ok);
end
ind = sub2ind (sz, ix{:});
keep = (npix(ind)>0);
ok(ok) = keep;
xp = xp_in(ok,:);
ind = ind(keep);

% Determine the nearest pixel to each point 
% -----------------------------------------
% Catch case of no points in the data
if ~any(ok)
    ipix = zeros(0,1);
    return
end

% Get coordinates of points along each projection axis
ustep = zeros(1,nd);
for i=1:nd
    ustep(i) = (p{i}(end)-p{i}(1))/(numel(p{i})-1);
end
xpstep = xp ./ repmat(ustep,size(xp,1),1);

% Get components along projection axes of the pixels in the sqw object
ucell = calculate_uproj_pixels (win, 'step');   % in units of steps
uprojstep = cell2mat(ucell);

ipix = zeros(numel(ind),1);
nend = cumsum(npix);
nbeg = nend - npix + 1;
ucent = zeros(1,4);
for i=1:numel(ind)
    % Projections for pixels in the bin
    uprojstep_bin = uprojstep(nbeg(ind(i)):nend(ind(i)),:); 
    % Point in steps: median coordinates along integration axes
    ucent(iax) = median(uprojstep_bin(:,iax),1);    
    ucent(pax) = xpstep(i,:);
    % Distance of all pixels to point:
    dist = uprojstep_bin - repmat(ucent,npix(ind(i)),1);
    [~,ipix(i)] = min(sum(dist.^2,2));
end

ipix = nbeg(ind) + ipix - 1;    % to get index in the full pixels array

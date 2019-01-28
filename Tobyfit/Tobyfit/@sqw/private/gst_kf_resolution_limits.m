function [minX,maxX,delX] = gst_kf_resolution_limits(win,lookup,frac)
% Determine the minimum corner and maximum corner of the total resolution
% ellipsoid projection extents along the four projection axes, plus the
% maximum extents of any one resolution ellipsoid.
% From this we can setup the neighborhood search cells, with 
%   N = ceil( (maxX-minX)./delX ) + 1
% cells along each axis and prod(N) total cells.

if nargin < 3 || ~isnumeric(frac)
    frac=0.5; % half-height probability by default
end

if iscell(win)
    win = cell2mat_obj(win);
end

% minX = inf(6,1);  % smallest extent along each axis
% maxX =-inf(6,1);  % biggest extent along each axis
% delX = zeros(6,1);% biggest individual resolution projection along each axis
% 
% for i=1:numel(win)
%     % Pull together the complete list of (ki_x,ki_y,ki_z,kf_x,kf_y,kf_z) pixel locations
%     vki = lookup.vki{i};
%     vkf = lookup.vkf{i};
%     X = cat(1,vki,vkf); % (6,npix) matrix
% 
%     C = lookup.cov_kikf{i};
%     H = resolution_halfwidths(C,frac); % (6,npix)
%     
%     this_minX = min(X-H,[],2);
%     this_maxX = max(X+H,[],2);
%     this_delX = max(H,[],2);
%         
%     minX = min(minX,this_minX); % elementwise comparison and selection
%     maxX = max(maxX,this_maxX);
%     delX = max(delX,this_delX);
% end
% % Only keep the kf part
% minX = minX(4:6);
% maxX = maxX(4:6);
% delX = delX(4:6);

minX = inf(3,1);  % smallest extent along each axis
maxX =-inf(3,1);  % biggest extent along each axis
delX = zeros(3,1);% biggest individual resolution projection along each axis
for i=1:numel(win)
    X= lookup.vkf{i}; % (3,npix) matrix
    C = lookup.cov_kikf{i}(4:6,4:6,:); % pull-out just the kf covariance
    H = resolution_halfwidths(C,frac); % (6,npix)
    this_minX = min(X-H,[],2);
    this_maxX = max(X+H,[],2);
    this_delX = max(H,[],2);
    minX = min(minX,this_minX); % elementwise comparison and selection
    maxX = max(maxX,this_maxX);
    delX = max(delX,this_delX);
end


end
function [M,QE] = resolution_mats (w)
% Return the resolution function expressed as a (4,4) matrix, M, 
% centred at x0=(Qx0,Qy0,Qz0,E0) where 
% exp( -(x-x0)' * M * (x-x0) ) is the probability at a neutron with x would
% be picked up by a detector at x0.

% G. S. Tucker

% Check sqw object
npixtot = sum(w.data.npix(:));

% Check if special case of single detector, no pixels; otherwise must have pixels
if npixtot==0 && (iscell(w.header) || numel(w.detpar.x2)~=1)
    error('No pixels in the sqw object - cannot compute a resolution function')
end

% Pull together the complete list of (Qx,Qy,Qz,En) points contained in 
% the SQW structure:
QE =calculate_qw_pixels(w); % Cell of Arrays
% QE =average_bin_data(w,QE);
nbins = numel(QE{1});
QE = cellfun(@(x)(reshape(x,nbins,1)), QE, 'uniformoutput', false); % Cell of Vectors
QE = cat(2, QE{:} ); % nbins by 4 matrix

% % Filtering out bins with no contributing pixels to avoid considering the 
% % resolution extent of bins we don't use when fitting.
% haspix = w.data.npix(:) > 0;
% QE = QE(haspix,:);
% 
% % To use get_nearest_pixels we need to know which columns of
% % average_QE_per_bin were used to specify the cut. 
% % Thankfully, this is kept in the SQW object for us as w.data.pax
% [xp_ok, ipix, ok] = get_nearest_pixels (w, QE(:,w.data.pax) );
% % Some bins may have been removed by get_nearest_pixels -- use the same
% % logical vector it uses to remove them here too:
% QE = QE(ok,:);
% % For a sanity check, make sure we've removed the right bins:
% if ~all( reshape( QE(:,w.data.pax), [], 1) == reshape( xp_ok, [], 1) )
%     error('Something has gone wrong with get_nearest_pixels')
% end

ipix = 1:nbins;

%%%% THE FIRST OUTPUT OF tobyfit_DGfermi_resfun_coariance is in the
%%%% PROJECTION AXES of w. 
% % With the pixels identified, we can calculate the covariance matricies
% covariance_matricies = tobyfit_DGfermi_resfun_covariance(w, ipix);
covariance_matricies = tobyfit_DGfermi_resfun_covariance(w); % grab all pixels covariance matricies
% These are the inverse of M for each (Q,E) point, expressed in Gaussian
% widths. 
M = zeros(size(covariance_matricies));
for i=1:numel(ipix)
    M(:,:,i) = inv(covariance_matricies(:,:,i));
end

end
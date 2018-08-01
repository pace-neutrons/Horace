function pix_block = build_pix_block_for_testing(n_pixels,n_bins,n_files)
% build pixels block for testing pixels cash

pix_block = zeros(9,n_pixels);
pix_block(1,:) = floor(rand(n_pixels,1)*n_bins)+1;
pix_block(2,:) = floor(rand(n_pixels,1)*n_files)+1;

[~,ind] = sort(pix_block(1,:));
pix_block = pix_block(:,ind);
pix_block(3,:) = 1:n_pixels;

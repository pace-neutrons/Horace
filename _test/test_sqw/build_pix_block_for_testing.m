function [pix_block,file_blocks] = build_pix_block_for_testing(n_pixels,n_bins,n_files)
% build pixels block for testing pixels cache and combine algorithm.
%
% Inputs:
% n_pixels -- number of pixels in the pix block
% n_bins   -- number of bins these pixels should be randomly distributed
%             over
% n_files  -- number of files, these pixels are randomly distributed over
%
% Output:
% pix_block   [9xn_pixels] fake array, containing
% column Number:
%    1         the number of the bin a pixel is located in
%    2         the number of file the pixel belongs to
%    3         tag (number) of a pixel, allowing to identify this pixel.
%    4-9       zeros.
% the data are sorted by bins i.e. first bin pixels are located first, 
% second bin follow after, etc.
%
% file_blocks -- cellarray of n_files extracts from pix_block, where each
%                each block contains only pixels, belonging to a "file"


pix_block = zeros(9,n_pixels);
pix_block(1,:) = floor(rand(n_pixels,1)*n_bins)+1;
pix_block(2,:) = floor(rand(n_pixels,1)*n_files)+1;

[~,ind] = sort(pix_block(1,:));
pix_block = pix_block(:,ind);
pix_block(3,:) = 1:n_pixels;

file_blocks = cell(n_files,1);
for i=1:n_files
    in_file = pix_block(2,:)==i;
    file_blocks{i} = pix_block(:,in_file);
end


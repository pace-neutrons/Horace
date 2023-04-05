function pix_out = distribute(obj, starts, lengths)
% Function to split (for parallel distribution) a pix object between multiple processes.
%
% Input
% ---------
%   obj         PixelData object
%
%   starts      Absolute indices of the starts of pixel ranges [Nx1 or 1xN array].
%
%   lengths     The sizes of the blocks to read                [Nx1 or 1xN array].
%
% Output
% ---------
%
%   pix_out     cell array of pixels divided for parallel
%

    pix_out = arrayfun(@(a, b) obj.get_pix_in_ranges(a,b), starts+1, lengths, 'UniformOutput', false);
end

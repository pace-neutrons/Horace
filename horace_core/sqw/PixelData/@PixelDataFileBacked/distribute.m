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

    nWorkers = numel(starts);
    pix_out = cell(nWorkers, 1);

    for i = 1:nWorkers
        pix_out{i} = PixelDataFileBacked(obj);
        pix_out{i}.offset_ = pix_out{i}.offset_ + ...
            starts(i) * obj.DEFAULT_NUM_PIX_FIELDS*4;
        pix_out{i}.num_pixels_ = lengths(i);
        pix_out{i}.f_accessor_ = memmapfile(pix_out{i}.full_filename, ...
                                            'Format', pix_out{i}.get_memmap_format(), ...
                                            'Repeat', 1, ...
                                            'Writable', false, ...
                                            'Offset', pix_out{i}.offset_);
    end
end

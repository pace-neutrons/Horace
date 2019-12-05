function [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = ...
    nbin_for_pixels_(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size)
% calculate number of bins to read enough pixels to fill pixels
% buffer and recalculate the number of pixes to read from every
% contributing file.
% Inputs:
% npix_per_bins -- 2D array containing the section of numbers of
%                  pixels per bin per file
% npix_in_bins  -- cumulative sum of pixels in bins of all files
% bin_start     -- first bin to analyze from the npix_section
%                 and npix_in_bins
% pix_buf_size -- the size of pixels buffer intended for
%                 writing
% Outputs:
% npix_2_read  --  2D array, containing the number of pixels
%                  in bins to read per file.
% npix_processed --total number of pixels to process during
%                  folowing read operation. Usually equal to
%                  pix_buf_size if there are enough pixels
%                  left.
% npix_per_bins  -- reduced 2D array containing the section of
%                   numbers of pixels per bin per file left to
%                   process in following IO operations.
% npix_in_bins  --  reduced cumulative sum of pixels in bins
%                   of all files left to process in following
%                   IO operations.
% last_fit_bin  -- the last bin number to process for  the pixels
%                  to fit pix buffer
%
% See: test_sqw/test_nsqw2sqw_internal_methods for the details
% of the method functionality
%
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%

% Calculate number of pixels to be read from all the files
n_files = size(npix_per_bins,1);
fit_the_buffer = npix_in_bins <= pix_buf_size;
if ~fit_the_buffer(1) % a single cell is bigger then pix_buffer
    % we are not constrained strongly by the pix buffer size.
    % Would double buffer sort the problem?
    if npix_in_bins(1) <= 2*pix_buf_size
        npix_2_read = npix_per_bins(:,1);
        npix_per_bins= npix_per_bins(:,2:end);
        npix_processed = npix_in_bins(1)+npix_processed;
        npix_in_bins   = npix_in_bins(2:end)-npix_processed;
        last_fit_bin = 1;        
    else %let's read parts of the pixels for single bin.
        npix_2_read = npix_per_bins(:,1);
        not_fit_the_buffer = npix_2_read > pix_buf_size;
        if not_fit_the_buffer(1) % even the first bin is too big to fit the buffer
            last_after_fit = 1;
        else
            last_after_fit = find(not_fit_the_buffer,1);
        end
        this_npix2_read = sum(npix_2_read(~not_fit_the_buffer));
        pix_buf_left = pix_buf_size-this_npix2_read;
        if pix_buf_left  > 0
            not_fit_the_buffer(last_after_fit) = false;
            npix_2_read(last_after_fit) = pix_buf_left;
            this_npix2_read = this_npix2_read + pix_buf_left;
        end
        npix_2_read(not_fit_the_buffer) = 0;
        
        npix_per_bins(:,1)= npix_per_bins(:,1)-npix_2_read;
        npix_processed = npix_processed + this_npix2_read;
        npix_in_bins(1)= npix_in_bins(1)- this_npix2_read;
        last_fit_bin  = 0;
    end

elseif fit_the_buffer(end)
    % everything fits the buffer
    last_fit_bin = numel(npix_in_bins);
    npix_2_read = npix_per_bins;
    npix_processed = npix_in_bins(end)+npix_processed;
    npix_in_bins= [];
    npix_per_bins=zeros(n_files,0);
else % partial buffer fit. Constrain number of bins to fill the buffer
    % ignore extra buffer capacity.
    npix_2_read = npix_per_bins(:,fit_the_buffer);
    npix_per_bins= npix_per_bins(:,~fit_the_buffer);
    last_fit_bin = find(~fit_the_buffer,1)-1;
    npix_processed_now = npix_in_bins(last_fit_bin);
    npix_in_bins   = npix_in_bins(~fit_the_buffer)-npix_processed_now;
    npix_processed = npix_processed+npix_processed_now;
end



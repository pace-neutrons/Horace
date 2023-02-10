function wout = do_sqw_eval_file_backed_(wout, sqwfunc, pars, outfile)
%==============================================================================
% Perform sqw_eval over file backed pixels.
% see function "do_sqw_eval_in_memory" local function in "sqw_eval_pix"
% for the basic functionality without the filebacked overhead.
%
% To avoid looping over pixels more than once, this function writes the
% output file using the dnd data of the input object, then writes pixels,
% then comes back and overwrites the image data with the newly calculated
% image.
%
% Several actions are performed in the pixel loop:
%  1. Calculate transform of pixel chunk coordinates (via calculate_qw_pixels)
%  2. Perform given function on pixel chunk
%  3. Write pixel chunk to output file
%  4. Calculate pixel chunk's signal sums for each image bin
%
% The signal sums are divided by npix after looping over pixels, this gives
% us the recomputed bin data for the output file. This data can then
% overwrite the placeholder image data we wrote at the start of the
% function. These actions replicate the behaviour of `recompute_bin_data`
% whilst avoiding an extra loop over pixels.
%
%==============================================================================
%
%Re #928 this function should be fixed. It does not work any more (and did not work before the changes anyway)

pg_size = wout.pix.base_page_size;
pix = wout.pix;
npix = wout.data.npix;

% divide npix into chunks of the base page size
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), pg_size);

% write dnd data to output file as per header description
% this will be overwritten later with the recalculated image
ldr = write_sqw_no_pix_or_footers_(wout, outfile);
ldr_clob = onCleanup(@() ldr.delete());

img_signal = zeros(1, numel(npix));
for chunk_num = 1:numel(npix_chunks)
    qw = calculate_qw_pixels(wout);
    sig_chunk = sqwfunc(qw{:}, pars{:});

    ldr = write_pix_chunk_with_signal_(ldr, pix, sig_chunk);

    img_signal = increment_signal_sums_( ...
        img_signal, sig_chunk, npix_chunks{chunk_num}, idxs(:, chunk_num) ...
    );

    if pix.has_more()
        % Do not save cached changes to pixels.
        % We avoid copying pixels by just editing the signal/variance of
        % the current page of the input pixels, then saving that page to
        % the output file. We don't want to retain changes made to the
        % input PixelData object, so we discard edits to the cache when we
        % load the next page of pixels.
        pix = pix.advance();
    else
        % Make sure we discard the changes made to the final page's cache
        pix = pix.move_to_page(1, 'nosave', true);
        break;
    end
end

% We're finished writing pixels, so write the file footers
ldr.put_footers();

% Now go back and overwrite the old image in the file with new data
[img_signal, img_error] = get_image_bin_averages_(img_signal, npix);
ldr.put_image(img_signal, img_error);

end % of function do_sqw_file_backed

%------------------------------------------------------------------------------
function ldr = write_sqw_no_pix_or_footers_(sqw_obj, outfile)
    % Write the given SQW object to the given file.
    % The pixels of the SQW object will be derived from the image signal array
    % and npix array, saving in chunks so they do not need to be held in memory.
    %
    ldr = sqw_formats_factory.instance().get_pref_access(sqw_obj);
    ldr = ldr.init(sqw_obj, outfile);
    ldr.put_sqw('-nopix');
end

%------------------------------------------------------------------------------
function f_accessor = write_pix_chunk_with_signal_(f_accessor, pix, signal)
    % Update the given PixelData object's signal and write the data to the file
    % managed by the given file accessor.
    pix.signal = signal;
    pix.variance = zeros(1, numel(signal));
    f_accessor.put_bytes(pix.data);
end

%------------------------------------------------------------------------------
function img_signal = increment_signal_sums_(img_signal, pix_signal, npix, idx)
    accum_indices = make_column(repelem(1:numel(npix), npix));
    pix_signal = make_row(pix_signal);
    bin_sums = accumarray(accum_indices, pix_signal, [numel(npix), 1]);
    img_signal(idx(1):idx(2)) = img_signal(idx(1):idx(2)) + bin_sums';
end

%------------------------------------------------------------------------------
function [s, e] = get_image_bin_averages_(bin_sums, npix)
    s = reshape(bin_sums(:)./npix(:), size(npix));
    s(npix == 0) = 0;
    e = zeros(size(s));
end

%==============================================================================

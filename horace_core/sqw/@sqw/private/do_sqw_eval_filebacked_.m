function wout = do_sqw_eval_filebacked_(wout, sqwfunc, pars, outfile)
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

pg_size = get(hor_config, 'mem_chunk_size');
write_as_sqw = ~isempty(outfile);

npix = wout.data.npix;

% divide npix into chunks of the page size
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), pg_size);

% write dnd data to output file as per header description
% this will be overwritten later with the recalculated image
if write_as_sqw
    ldr = write_sqw_no_pix_or_footers_(wout, outfile);
    ldr_clob = onCleanup(@() ldr.delete());
else
    wout.pix = wout.pix.get_new_handle();
end

img_signal = zeros(1, numel(npix));


s_ind = wout.pix.check_pixel_fields('signal');
v_ind = wout.pix.check_pixel_fields('variance');

for i = 1:wout.pix.num_pages
    [wout.pix, data] = wout.pix.load_page(i);
    npix_chunk = npix_chunks{i};
    idx_chunk = idxs(:, i);

    qw = calculate_qw_pixels(wout);
    sig_chunk = sqwfunc(qw{:}, pars{:});

    data(s_ind, :) = sig_chunk;
    data(v_ind, :) = 0;

    if write_as_sqw
        ldr.put_bytes(data);
    else
        wout.pix.format_dump_data(data);
    end

    img_signal = increment_signal_sums_(img_signal, sig_chunk, npix_chunk, idx_chunk);
end

% We're finished writing pixels, so write the file footers
if write_as_sqw
    ldr.put_footers();
    % Now go back and overwrite the old image in the file with new data
    [img_signal, img_error] = get_image_bin_averages_(img_signal, npix);
    ldr.put_image(img_signal, img_error);
    wout = sqw(outfile);
else
    wout.pix = wout.pix.finalise();
end

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

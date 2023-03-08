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

if isempty(outfile)
    if isempty(wout.full_filename)
        wout.full_filename = 'in_mem';
    end
    wout.file_holder_ = TmpFileHandler(wout.full_filename);
    outfile = wout.file_holder_.file_name;
end

npix = wout.data.npix;

% divide npix into chunks of the page size
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), pg_size);

% Write the given SQW object to the given file.
% The pixels of the SQW object will be derived from the image signal array
% and npix array, saving in chunks so they do not need to be held in memory.
ldr = sqw_formats_factory.instance().get_pref_access(wout);
ldr = ldr.init(wout, outfile);
ldr.put_sqw('-nopix');

wout.pix = wout.pix.get_new_handle(ldr);

ldr_clob = onCleanup(@() ldr.delete());

img_signal = zeros(1, numel(npix));

s_ind = wout.pix.check_pixel_fields('signal');
v_ind = wout.pix.check_pixel_fields('variance');

wout.pix.data_range = PixelDataBase.EMPTY_RANGE;

for i = 1:wout.pix.num_pages
    [wout.pix, data] = wout.pix.load_page(i);
    npix_chunk = npix_chunks{i};
    idx_chunk = idxs(:, i);

    qw = calculate_qw_pixels(wout);
    sig_chunk = sqwfunc(qw{:}, pars{:});

    data(s_ind, :) = sig_chunk;
    data(v_ind, :) = 0;

    wout.pix.format_dump_data(data);

    img_signal = increment_signal_sums_(img_signal, sig_chunk, ...
                                        npix_chunk, idx_chunk);
end

% We're finished writing pixels
wout.pix = wout.pix.finalise();

[img_signal, img_error] = get_image_bin_averages_(img_signal, npix);
ldr.put_image(img_signal, img_error);
wout.data = ldr.get_data('-nopix');

end % of function do_sqw_file_backed

function img_signal = increment_signal_sums_(img_signal, pix_signal, npix, idx)
    accum_indices = make_column(repelem(1:numel(npix), npix));
    pix_signal = make_row(pix_signal);
    bin_sums = accumarray(accum_indices, pix_signal, [numel(npix), 1]);
    img_signal(idx(1):idx(2)) = img_signal(idx(1):idx(2)) + bin_sums';
end

function [s, e] = get_image_bin_averages_(bin_sums, npix)
    s = reshape(bin_sums(:)./npix(:), size(npix));
    s(npix == 0) = 0;
    e = zeros(size(s));
end

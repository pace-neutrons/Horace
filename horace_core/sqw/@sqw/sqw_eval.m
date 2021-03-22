function wout = sqw_eval(win, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function
%
%   >> wout = sqw_eval(win, sqwfunc, p)
%   >> wout = sqw_eval(___, '-all')
%   >> wout = sqw_eval(___, 'all', true)
%   >> wout = sqw_eval(___, '-average')
%   >> wout = sqw_eval(___, 'average', true)
%   >> sqw_eval(___, 'outfile', outfile)
%   >> wout = sqw_eval(___, 'outfile', outfile)
%   >> sqw_eval(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_eval(__, 'filebacked', true)
%
% Input:
% ------
%   win        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q, w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh, qk, ql, en, p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A, js, gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated spectral weight
%
%               More general form is:
%                   weight = sqwfunc (qh, qk, ql, en, p, c1, c2, ..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1, c2, ...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars       Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A, js, gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
% Keyword Arguments:
% ------------------
%   outfile    If present, the outputs will be written to the file of the given
%              name/path.
%              If numel(win) > 1, outfile must either be omitted or be a cell
%              array of file paths with equal number of elements as win.
%
%   all        Requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%              Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
%   average    Requests that the calculated sqw be computed for the
%              average values of h, k, l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%              Applies only to the case of sqw object with pixel information
%             - it is ignored if dnd type object.
%
%   filebacked  If true, the result of the function will be saved to file and
%               the output will be a file path. If no `outfile` is specified,
%               a unique path within `tempdir()` will be generated.
%               Default is false.
%
% Note: all optional string input parameters can be truncated up to minimal
%       difference between them e.g. routine would accept 'al' and
%       'av', 'ave', 'aver' etc....
%
%
% Output:
% -------
%   wout        If `filebacked` is false, an sqw object or array of sqw objects.
%               If `filebacked` is true, a file path or cell array of file paths.
%               Output argument must be specified if `outfile` not given.
%
[sqwfunc, pars, opts] = parse_arguments(win, sqwfunc, pars, varargin{:});
if isempty(opts.outfile) || opts.filebacked
    nargoutchk(1, 1);
end

wout = copy(win);
if ~iscell(pars)
    pars = {pars};  % package parameters as a cell for convenience
end

for i = 1:numel(win)

    if is_sqw_type(win(i))   % determine if sqw or dnd type
        pix_file_backed = ...
            wout(i).data.pix.base_page_size < wout(i).data.pix.num_pixels;
        if pix_file_backed
            if opts.average
                wout(i) = do_sqw_eval_average_filebacked_( ...
                    wout(i), sqwfunc, pars, opts.outfile{i} ...
                );
            else
                wout(i) = do_sqw_eval_file_backed_( ...
                    wout(i), sqwfunc, pars, opts.outfile{i} ...
                );
            end
        else
            wout(i) = do_sqw_eval_in_memory_(wout(i), sqwfunc, pars, opts.average);
            if ~isempty(opts.outfile) && ~isempty(opts.outfile{i})
                save(wout(i), opts.outfile{i});
            end
        end

    else  % dnd-type object
        qw = calculate_qw_bins(win(i));
        if ~opts.all                    % only evaluate at the bins actually containing data
            ok = (win(i).data.npix ~= 0);   % should be faster than isfinite(1./win.data.npix), as we know that npix is zero or finite
            for idim = 1:4
                qw{idim} = qw{idim}(ok);  % pick out only the points where there is data
            end
            wout(i).data.s(ok) = sqwfunc(qw{:}, pars{:});
        else
            wout(i).data.s = reshape(sqwfunc(qw{:}, pars{:}), size(win(i).data.s));
        end
        wout(i).data.e = zeros(size(win(i).data.e));
    end
end

if opts.filebacked
    % If filebacked, always return file paths not objects. This stops us from
    % leaking file-backed objects
    if numel(opts.outfile) > 1
        wout = opts.outfile;
    else
        wout = opts.outfile{1};
    end
end

end


% -----------------------------------------------------------------------------
function [sqwfunc, pars, opts] = parse_arguments(win, sqwfunc, pars, varargin)
    % Parse arguments for sqw_eval
    flags = {'-all', '-average', '-filebacked'};
    [~, ~, all_flag, ave_flag, filebacked_flag, args] = parse_char_options(varargin, flags);

    parser = inputParser();
    parser.addRequired('sqwfunc', @(x) isa(x, 'function_handle'));
    parser.addRequired('pars');
    parser.addParameter('average', ave_flag, @islognumscalar);
    parser.addParameter('all', all_flag, @islognumscalar);
    parser.addParameter('filebacked', filebacked_flag, @islognumscalar);
    parser.addParameter('outfile', {}, @(x) iscellstr(x) || ischar(x) || isstring(x));
    parser.parse(sqwfunc, pars, args{:});
    opts = parser.Results;

    if ~iscell(opts.outfile)
        opts.outfile = {opts.outfile};
    end

    outfiles_empty = all(cellfun(@(x) isempty(x), opts.outfile));
    if ~outfiles_empty && (numel(win) ~= numel(opts.outfile))
        error( ...
        'HORACE:SQW:invalid_arguments', ...
        ['Number of outfiles specified must match number of input objects.\n' ...
         'Found ''%i'' outfile(s), but ''%i'' sqw object(s).'], ...
        numel(opts.outfile), numel(win) ...
    );
    end

    if outfiles_empty && opts.filebacked
        opts.outfile = gen_unique_file_paths( ...
            numel(win), 'horace_sqw_eval', tmp_dir(), 'sqw' ...
        );
    end
end


function wout = do_sqw_eval_in_memory_(wout, sqwfunc, pars, average)
    % Perform sqw_eval on an sqw object with all its pixels in memory
    %
    qw_pix_coords = calculate_qw_pixels(wout);
    if average
        % Get average h, k, l, e for the bin, compute sqw for that average,
        % and fill pixels with the average signal for the bin that contains
        % them
        qw_ave = average_bin_data(wout, qw_pix_coords);
        qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
        new_signal = sqwfunc(qw_ave{:}, pars{:});
        new_signal = repelem(new_signal, wout.data.npix(:));
    else
        new_signal = sqwfunc(qw_pix_coords{:}, pars{:});
    end

    wout.data.pix.signal = new_signal(:)';
    wout.data.pix.variance = zeros(1, numel(new_signal));
    wout = recompute_bin_data(wout);
end


function sqw_obj = do_sqw_eval_average_filebacked_(sqw_obj, sqwfunc, pars, outfile)
    % Execute the given function 'sqwfunc' on the average coordinates (in
    % r, l, u) for each image bin
    pix = sqw_obj.data.pix;
    npix = sqw_obj.data.npix;

    % Split npix array up, this allows us to pass the npix chunks into
    % 'average_bin_data', for which we need whole bins.
    [npix_chunks, idxs, pix_bin_ends] = split_vector_max_sum(npix(:), pix.base_page_size);
    pix_bin_starts = pix_bin_ends - npix(:) + 1;
    for j = 1:numel(npix_chunks)
        npix_chunk = npix_chunks{j};
        pix_start_idx = pix_bin_starts(idxs(1, j));
        pix_end_idx = pix_bin_ends(idxs(2, j));

        % Get pixels that belong to the bins in the current npix chunk
        pix_chunk = pix.get_pix_in_ranges(pix_start_idx, pix_end_idx);

        % Calculate qh, qk, ql, and en for the pixels (qw_pix is cell array)
        qw_pix = get_qw_pixels_(sqw_obj, pix_chunk);

        % Average the qw pixel data over each bin defined by the npix chunk
        qw_ave = average_qw_pix_(sqw_obj, qw_pix, npix_chunk);

        % Perform input function over the averaged image data
        ave_signal = sqwfunc(qw_ave{:}, pars{:});

        % Assign each pixel's signal to bin average, variance set to zero
        pix = set_pixel_data_(pix, ave_signal, npix_chunk, pix_start_idx, pix_end_idx);
    end
    sqw_obj = recompute_bin_data(sqw_obj);
    save(sqw_obj, outfile);
end


function qw_pix = get_qw_pixels_(sqw_obj, pix)
    sqw_obj.data.pix = pix;
    qw_pix = calculate_qw_pixels(sqw_obj);
end


function qw_ave = average_qw_pix_(sqw_obj, pix, npix)
    sqw_obj.data.npix = npix;
    qw_ave = average_bin_data(sqw_obj, pix);
    qw_ave = cellfun(@(x) x(:), qw_ave, 'UniformOutput', false);
end


function pix = set_pixel_data_(pix, ave_signal, npix_chunk, start_idx, end_idx)
    sig_var = zeros(2, end_idx - start_idx + 1);
    sig_var(1, :) = repelem(ave_signal, npix_chunk);
    pix.set_data({'signal', 'variance'}, sig_var, start_idx:end_idx);
end


function ldr = write_sqw_no_pix_or_footers_(sqw_obj, outfile)
    % Write the given SQW object to the given file.
    % The pixels of the SQW object will be derived from the image signal array
    % and npix array, saving in chunks so they do not need to be held in memory.
    %
    ldr = sqw_formats_factory.instance().get_pref_access(sqw_obj);
    ldr = ldr.init(sqw_obj, outfile);
    ldr.put_sqw('-nopix');
end


function wout = do_sqw_eval_file_backed_(wout, sqwfunc, pars, outfile)
    % Perform sqw_eval over file backed pixels.
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
    pg_size = wout.data.pix.base_page_size;
    pix = wout.data.pix;
    npix = wout.data.npix;

    [npix_chunks, idxs] = split_vector_fixed_sum(npix(:), pg_size);

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
            pix.advance('nosave', true);
        else
            % Make sure we discard the changes made to the final page's cache
            pix.move_to_page(1, 'nosave', true);
            break;
        end
    end
    % We're finished writing pixels, so write the file footers
    ldr.put_footers();

    % Now go back and overwrite the old image in the file with new data
    [img_signal, img_error] = get_image_bin_averages_(img_signal, npix);
    ldr.put_image(img_signal, img_error);
end


function f_accessor = write_pix_chunk_with_signal_(f_accessor, pix, signal)
    % Update the given PixelData object's signal and write the data to the file
    % managed by the given file accessor.
    pix.signal = signal;
    pix.variance = zeros(1, numel(signal));
    f_accessor.put_bytes(pix.data);
end


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

function wout = parallel_sqw_eval(func, w, nWorkers, args)
    if ~iscell(w)
        w = {w};
    end

    loop_data = mfclass.distribute_fit_data(w, nWorkers, false);

    common_data = struct('func', func, ...
                         'args', {args}, ...
                         'merge_data', []);

    jd = JobDispatcher.instance();
    [res, n_failed] = jd.start_job('ParallelSQWEval', common_data, loop_data, true, nWorkers);
    if n_failed
        jd.display_fail_job_results(res, n_failed, 1);
        error('HORACE:parallel_sqw_eval:job_failed', ...
              'Failure in parallel job');
    end

    wout = cellfun(@copy, w, 'UniformOutput', false);
    res

    if iscell(res{1})
        extract = @(x, i) x{i}.pix;
    else
        extract = @(x, i) x(i).pix;
    end

    % Recombine data
    for i = 1:numel(wout)
        pix = cellfun(extract, res, repmat({i}, size(res)), 'UniformOutput', false);
        wout{i}.pix = wout{i}.pix.cat(pix{:});
        [wout{i}.data.s, wout{i}.data.e] = wout{i}.pix.compute_bin_data(wout{i}.data.npix);
        for i = 1:numel(pix) % Clear temp files preserved by function
            delete(pix{i}.full_filename);
        end
    end

    if isscalar(wout)
        wout = wout{1};
    end
end

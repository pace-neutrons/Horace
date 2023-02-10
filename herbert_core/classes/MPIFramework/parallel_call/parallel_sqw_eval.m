function wout = parallel_sqw_eval(func, w, nWorkers, args)
    if ~iscell(w)
        w = {w};
    end

    for i=1:numel(w)
        % Pixwise op, don't need merge data
        data = distribute(w{i}, nWorkers, true);

        for j=1:nWorkers
            loop_data{j}.w{i} = data(j);
        end

    end

    common_data = struct('func', {func}, ...
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
        extract = @(x) x{i}.pix.data;
    else
        extract = @(x) x(i).pix.data;
    end

    % Recombine data
    for i = 1:numel(wout)
        pix = cellfun(extract, res, 'UniformOutput', false);
        wout{i}.pix.data = horzcat(pix{:});
        [wout{i}.data.s, wout{i}.data.e] = wout{i}.pix.compute_bin_data(wout{i}.data.npix);
    end

    if isscalar(wout)
        wout = wout{1};
    end
end

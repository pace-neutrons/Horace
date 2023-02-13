function wout = parallel_sqw_eval(func, w, call_func, nWorkers, args)
    if ~iscell(w)
        w = {w};
    end

    tmp = functions(call_func);
    if startsWith(tmp.function, 'tobyfit')
        loop_data = ...
            mfclass.distribute_fit_data(w, nWorkers, false, ...
                                        arrayfun(@(x)(x.plist{3}), args{2}, 'UniformOutput', false));
    else
        loop_data = mfclass.distribute_fit_data(w, nWorkers, false);
    end

    common_data = struct('func', func, ...
                         'args', {{call_func args}}, ...
                         'merge_data', []);

    jd = JobDispatcher('ParallelSQWEval');
    [res, nFailed] = jd.start_job('ParallelSQWEval', common_data, loop_data, true, nWorkers);
    if nFailed
        jd.display_fail_job_results(res, nFailed, nWorkers);
        error('HERBERT:parallel_sqw_eval:runtime_error', ...
              'Parallel execution of SQW eval failed');
    end


    wout = cellfun(@copy, w, 'UniformOutput', false);

    if iscell(res{1})
        extract = @(x, i) x{i}.pix.data;
    else
        extract = @(x, i) x(i).pix.data;
    end

    % Recombine data
    for i = 1:numel(wout)
        pix = cellfun(extract, res, repmat({i}, size(res)), 'UniformOutput', false);
        wout{i}.pix.data = horzcat(pix{:});
        [wout{i}.data.s, wout{i}.data.e] = wout{i}.pix.compute_bin_data(wout{i}.data.npix);
    end

    if isscalar(wout)
        wout = wout{1};
    end
end

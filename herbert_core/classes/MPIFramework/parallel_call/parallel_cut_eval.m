function wout = parallel_cut_eval(nWorkers, args);

    w = args{1};
    if ~iscell(w)
        w = {w};
    end
    args = args(2:end);

    switch class(w{1})
      case {'cell'}
        if iscellstr()
            w = cellfun(@sqw, w{1});
        end
      case {'char', 'string'}
        w{1} = sqw(w{1});
      case {'d1d', 'd2d', 'd3d', 'd4d', 'sqw'}
        ; %Do nothing
      otherwise
        error('HERBERT:parallel_cut:invalid_argument', ...
              'Cannot perform parallel cut on object of class %s', class(w{1}))
    end

    w
    loop_data = cellfun(@(x) distribute(x, nWorkers, false), w, 'UniformOutput', false);
    loop_data{1}

    common_data = struct('args', {args});

    jd = JobDispatcher('ParallelCut');
    [res, nFailed] = jd.start_job('ParallelCut', common_data, loop_data, true, nWorkers);
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

end

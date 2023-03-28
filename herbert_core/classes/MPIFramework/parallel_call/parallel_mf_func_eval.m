function wout = parallel_mf_func_eval(func, nWorkers, args)

    w = args{1};
    args = args(2:end);

    has_fgnd = ~isempty(args{2}{1});

    if has_fgnd
        call_func = args{2}{1};
        finfo = functions(call_func);
    end
    pin = args{4};

    has_bgnd = ~isempty(args{3}{1});
    if has_bgnd
        bcall_func = args{3}{1};
        bfinfo = functions(bcall_func);
    end
    bpin = args{5};

    if ~iscell(w)
        w = {w};
    end

    switch class(w{1})
      case 'struct'
        loop_data = cellfun(@(x)distribute(x, nWorkers, false), w);
      case {'IX_Dataset_1D', 'IX_Dataset_2D', 'IX_Dataset_3D'}
        loop_data = cellfun(@(x)distribute(x, nWorkers, false), w);
      case {'d1d', 'd2d', 'd3d', 'd4d'}
        loop_data = cellfun(@(x)distribute(x, nWorkers, false), w);
      case 'sqw'
        if has_fgnd && startsWith(finfo.function, 'tobyfit')
            loop_data = ...
                mfclass.distribute_fit_data(w, nWorkers, false, ...
                                            arrayfun(@(x)(x.plist{3}), pin, 'UniformOutput', false));
        elseif has_bgnd && startsWith(bfinfo.function, 'tobyfit')
            error('HERBERT:parallel_mf_func_eval:invalid_argument', ...
                  'Parallel tobyfit with tobyfit as background function not supported');
        else
            loop_data = mfclass.distribute_fit_data(w, nWorkers, false);
        end

      otherwise
        error('HERBERT:parallel_mf_sqw_eval:invalid_argument', ...
              'Cannot perform parallel eval on object of class %s', class(w{1}))
    end

    common_data = struct('func', func, ...
                         'args', {args}, ...
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


end

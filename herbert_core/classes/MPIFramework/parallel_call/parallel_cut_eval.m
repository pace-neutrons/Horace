function wout = parallel_cut_eval(nWorkers, args)

    w = args{1};
    args = args(2:end);

    if istext(args{end})
        outfile = args{end};
        args = args{1:end-1};
    else
        outfile = [];
    end

    tmp_files = cell(nWorkers, 1);
    filenames = cell(nWorkers, 1);

    for i = 1:nWorkers
        switch class(w)
          case {'cell'}
            if iscellstr(w)
                tmp_files{i} = cellfun(@TmpFileHandler, w);
                w = cellfun(@sqw, w, 'UniformOutput', false');
            elseif all(cellfun(@(x) isa(x, 'sqw'), w))
                tmp_files{i} = cellfun(@(x) TmpFileHandler(x.full_filename), w);
            else
                error('HERBERT:parallel_cut:invalid_argument', ...
                      'Cannot perform parallel cut on object of class %s', class(w))

            end
          case {'char', 'string'}
            tmp_files{i} = TmpFileHandler(w);
            w = {sqw(w)};
          case {'sqw'} % 'd1d', 'd2d', 'd3d', 'd4d',
            tmp_files{i} = TmpFileHandler(w.full_filename);
            w = {w};
          otherwise
            error('HERBERT:parallel_cut:invalid_argument', ...
                  'Cannot perform parallel cut on object of class %s', class(w))
        end
        filenames{i} = arrayfun(@(x) x.file_name, tmp_files{i}, 'UniformOutput', false);
    end

    ws = cellfun(@(x) distribute(x, nWorkers, false), w, 'UniformOutput', false);

    loop_data = struct('tmp_files', filenames, 'w', {cell(numel(w), 1)});
    for worker = 1:nWorkers
        for nw = 1:numel(w)
            loop_data(worker).w{nw} = ws{nw}(worker);
        end
    end

    loop_data = mat2cell(loop_data, ones(nWorkers, 1));
    common_data = struct('args', {args});

    jd = JobDispatcher('ParallelCut');
    [res, nFailed] = jd.start_job('ParallelCut', common_data, loop_data, true, nWorkers);
    if nFailed
        jd.display_fail_job_results(res, nFailed, nWorkers);
        error('HERBERT:parallel_sqw_eval:runtime_error', ...
              'Parallel execution of SQW eval failed');
    end

    if isempty(outfile)
        tmp_outfile = TmpFileHandler(w{1}.full_filename);
        outfile = tmp_outfile.file_name;
        write_nsqw_to_sqw([filenames{:}], outfile, '-parallel','-allow_equal_headers');
        wout = sqw(outfile);

        if wout.pix.is_filebacked % Preserve pix
            tmp_outfile.file_name = '';
            clear tmp_outfile;
        end
    else
        write_nsqw_to_sqw([filenames{:}], outfile, '-parallel','-allow_equal_headers');
        wout = [];
    end

end

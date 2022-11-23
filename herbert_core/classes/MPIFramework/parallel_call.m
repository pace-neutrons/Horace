function varargout = parallel_call(func, args, varargin)

    [nWorkers] = get(parallel_config, 'parallel_workers_number');

    func_info = functions(func);

    switch func_info.function
      case {'sqw_eval', 'multifit_func_eval'}
        w = args{1};

        if ~iscell(w)
            w = cell(w);
        end

        args = args(2:end);

        for i=1:numel(w)
            [data, md] = distribute(w{i}, nWorkers, true);

            for j = 1:numel(md)
                merge_data(i,j).nelem = md(j).nelem;
                merge_data(i,j).nomerge = md(j).nomerge;
                merge_data(i,j).range = md(j).range;
                merge_data(i,j).pix_range = md(j).pix_range;
            end

            for j=1:nWorkers
                loop_data{j}.w{i} = data(j);
            end

        end

        common_data = struct('func', {func}, ...
                             'args', {args}, ...
                             'merge_data', {merge_data});

        jd = JobDispatcher('ParallelSQWEval');
        res = jd.start_job('ParallelSQWEval', common_data, loop_data, true, nWorkers);

        % Recombine data
        wout = cellfun(@sqw, w, 'UniformOutput', false);
        for i = 1:numel(wout)
            pix = cellfun(@(x) x{i}.pix.data, res, 'UniformOutput', false);
            wout{i}.pix.data = horzcat(pix{:});
            [wout{i}.data.s, wout{i}.data.e] = wout{i}.pix.compute_bin_data(wout{i}.data.npix);
        end

        varargout{1} = wout;

      otherwise
        error('HERBERT:parallel_call:invalid_argument', ...
              'Unsupported parallel function (%s)', func_info.name)
    end
end

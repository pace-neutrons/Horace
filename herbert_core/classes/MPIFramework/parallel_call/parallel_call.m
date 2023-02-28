function varargout = parallel_call(func, args, varargin)

    nWorkers = get(parallel_config, 'parallel_workers_number');

    func_info = functions(func);

    switch func_info.function
      case 'sqw_eval'

        varargout{1} = parallel_sqw_eval(func, nWorkers, args);

      case 'multifit_func_eval'

        varargout{1} = parallel_mf_func_eval(func, nWorkers, args);

      otherwise
        error('HERBERT:parallel_call:invalid_argument', ...
              'Unsupported parallel function (%s)', func_info.name)
    end
end

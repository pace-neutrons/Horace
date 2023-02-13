function varargout = parallel_call(func, args, varargin)

    nWorkers = get(parallel_config, 'parallel_workers_number');

    func_info = functions(func);

    switch func_info.function
      case 'sqw_eval'

        w = args{1};
        call_func = args{2};
        args = args(2:end);

        varargout{1} = parallel_sqw_eval(func, w, call_func, nWorkers, args);

      case 'multifit_func_eval'

        % mf_func_eval signature:
        %multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        %    f_pass_caller, bf_pass_caller, pfin, p_info, output_type)
        w = args{1};
        call_func = args{3}{1};
        args = args(2:end);

        varargout{1} = parallel_mf_func_eval(func, w, call_func, nWorkers, args);

      otherwise
        error('HERBERT:parallel_call:invalid_argument', ...
              'Unsupported parallel function (%s)', func_info.name)
    end
end

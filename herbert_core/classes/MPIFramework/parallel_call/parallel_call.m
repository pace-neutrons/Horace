function varargout = parallel_call(func, args, varargin)

    nWorkers = get(parallel_config, 'parallel_workers_number');

    func_info = functions(func);

    switch func_info.function
      case 'sqw_eval'

        varargout{1} = parallel_sqw_eval(func, nWorkers, args);

      case 'multifit_func_eval'

        % mf_func_eval signature:
        %multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        %    f_pass_caller, bf_pass_caller, pfin, p_info, output_type)

        varargout{1} = parallel_mf_func_eval(func, nWorkers, args);

      case 'cut'

        varargout{1} = parallel_cut_eval(nWorkers, args);

      case 'fit'

        if numel(args) ~= 1 || ~isa(args{1}, 'mfclass')
            error('HERBERT:parallel_call:invalid_argument', ...
                  'Attempted to call "fit" with non-mfclass argument')
        end

        hc = hpc_config;
        pm = hc.parallel_multifit;

        hc.parallel_multifit = true;
        [data_out, fit_data] = varargin{1}.fit();
        hc.parallel_multifit = pm;

        varargout{1} = data_out;
        varargout{2} = fit_data;

      otherwise
        error('HERBERT:parallel_call:invalid_argument', ...
              'Unsupported parallel function (%s)', func_info.name)
    end
end

function wout = parallel_mf_func_eval(func, w, call_func, nWorkers, args)

switch class(w{1})
%   case 'struct'
%
%   case {'IX_Dataset_1D', 'IX_Dataset_2D', 'IX_Dataset_3D'}
%   case {'d1d', 'd2d', 'd3d', 'd4d'}

  case 'sqw'
    wout = parallel_sqw_eval(func, w, call_func, nWorkers, args);
    if ~iscell(wout)
        wout = {wout};
    end
  otherwise
    error('HERBERT:parallel_mf_sqw_eval:invalid_argument', ...
          'Cannot perform parallel eval on object of class %s', class(w{1}))
end


end

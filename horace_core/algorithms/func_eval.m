function wout = func_eval(source, varargin)
% Evaluate a function at the plotting bin centres of sqw/dnd objects or files
% Syntax:
%   >> wout = func_eval(win, func_handle, pars)
%   >> wout = func_eval(win, func_handle, pars, 'outfile', outfile_path)
%   >> wout = func_eval(win, func_handle, pars, ['all'])
%   >> wout = func_eval(file_path, func_handle, pars)
%   >> wout = func_eval({file_path, win}, func_handle, pars)
%
% If function is called on sqw-type object (i.e. has pixels), the pixels'
% signal is also modified and evaluated
%
% For more info see help sqw/func_eval
%
sqw_dnd_obj = load_sqw_dnd(source);

if nargout > 0
    wout = func_eval(sqw_dnd_obj, varargin{:});
else
    func_eval(sqw_dnd_obj, varargin{:});
end

end  % function

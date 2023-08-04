function fun = fun_parse (fun_in, size_fun)
% Make a cell array of function handles
%
%   >> fun = fun_parse (fun_in, size_fun)
%
% Input:
% ------
%   fun_in  Cell array of handles to functions.
%           Some or all elements of the cell array can be [].
%          Empty elements will be later interpreted as not having a
%          function to evaluate for the corresponding data set.
%
% size_fun  Required size of the output array of function handles
%
% Output:
% -------
%   fun    Cell array of function handles. Missing functions are represented
%          by [].
%           if local: fun is a cell array with size given by size_w
%           if not:   fun is a scalar cell array (and contains a function handle)
%           If there was an error, then fun={}


% Original author: T.G.Perring

fun = is_valid_function_handles(fun_in);

if numel(fun) > 0
    if prod(size_fun) > 0

        if isscalar(fun) && prod(size_fun) > 1
            fun=repmat(fun, size_fun);

        elseif numel(fun) == prod(size_fun)

            if ndims(fun) ~= numel(size_fun) || any(size(fun) ~= size_fun)
                fun=reshape(fun, size_fun);  % get to same shape as data array
            end

        else
            error('HORACE:fun_parse:invalid_argument', ...
                  'Function handle argument must be scalar or have same number of elements as number to be set');
        end

    elseif ~isscalar(fun) || ~isequal(fun{1}, [])
        % Case of fun=[] is ok if prod(size_fun) == 0
        error('HORACE:fun_parse:invalid_argument', ...
              'Function handle(s) given but none required');
    end

elseif prod(size_fun) > 0
    error('HORACE:fun_parse:invalid_argument', ...
          'Function handle argument is empty but function handle(s) are expected');
end

end

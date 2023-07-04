function fun = is_valid_function_handles (fun_in)
% Determine if an argument is a function handle or a cell array of function handles
%
%   >> fun = is_valid_function_handles (fun_in)
%
% Input:
% ------
%   fun_in  Handles to functions:
%            - a single function handle e.g. @sin or [] (which means
%              'no function handle' but still is a valid entry for a single
%              function)
%            - cell array of function handles or []. This also includes the
%              case of {} i.e. no functions at all.
%           Some or all elements of the cell array can be empty.
%          Empty elements will be later interpreted as not having a
%          function to evaluate for the corresponding data set.
%
% Output:
% -------
%   fun     Cell array of function handles. Missing functions are represented
%          by []. Even if there is just one function handle, it is placed in
%          a cell array.
%           If an error was raised, fun={}
%
%
% Note:
%   - Non-scalar arrays of function handles are not permitted in matlab.


% Original author: T.G.Perring

if iscell(fun_in)
    fun = fun_in;
    for i=1:numel(fun)
        if isempty(fun{i})
            fun{i} = [];      % make standard form
        elseif ~isa(fun{i},'function_handle')
            error('HORACE:is_valid_function_handles', ...
                  'Elements of a function handle cell array argument must be function handles or empty');
        end
    end

elseif isa(fun_in,'function_handle')
    fun = {fun_in};   % make a cell array of length unity

elseif isempty(fun_in)
    fun = {[]};       % make standard form

else
    error('HORACE:is_valid_function_handles', ...
          'Argument must be a function handle or cell array of function handles');
end

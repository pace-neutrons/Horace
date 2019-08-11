function [ok,mess,fun] = is_valid_function_handles (fun_in)
% Determine if an argument is a function handle or a cell array of function handles
%
%   >> [ok,mess,fun] = is_valid_function_handles (fun_in)
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
%   ok      Status flag: =true if all OK; =false if not
%   mess    Error message: empty if OK, non-empty otherwise
%   fun     Cell array of function handles. Missing functions are represented
%          by []. Even if there is just one function handle, it is placed in
%          a cell array.
%           If an error was raised, fun={}
%
%
% Note:
%   - Non-scalar arrays of function handles are not permitted in matlab.


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


ok=true;
mess='';
    
if iscell(fun_in)
    fun=fun_in;
    for i=1:numel(fun)
        if isempty(fun{i})
            fun{i}=[];      % make standard form
        elseif ~isa(fun{i},'function_handle')
            ok=false;
            mess='Elements of a function handle cell array argument must be function handles or empty';
            fun={};
            break
        end
    end
    
elseif isa(fun_in,'function_handle')
    fun={fun_in};   % make a cell array of length unity
    
elseif isempty(fun_in)
    fun={[]};       % make standard form

else
    ok=false;
    mess='Argument must be a function handle or cell array of function handles';
    fun={};

end

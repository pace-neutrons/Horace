function [ok,mess,func] = function_handles_valid (func_in)
% Determine if an argument is a function handle or a cell array of function handles
%
%   >> [ok,mess,func] = function_handles_valid (func_in)
%
% Input:
% ------
%   func_in Handles to functions:
%            - a single function handle
%            - cell array of function handles
%           Some, but not all, elements of the cell array can be empty.
%          Empty elements will be later interpreted as not having a
%          function to evaluate for the corresponding data set.
%
% Output:
% -------
%   ok      Status flag: =true if all OK; =false if not
%   mess    Error message: empty if OK, non-empty otherwise
%   func    Cell array of function handles. Missing functions are represented
%          by empty elements (anything for which isempty(func{i})==true).
%          Even if there is just one function handle, it is placed in a cell array.
%
%
% Note:
%   - Non-scalar arrays of function handles are not permitted in matlab.
%   - Not all the elements of a cell array can be empty, because then there
%    is no clue that the argument could possibly correspond to a function.
%    if the user wants multifit to not have any functions for the foreground
%    or background, then the absence of the corresponding argument will be
%    noted in multifit.
%   - In any case, if all functions were missing, then the same effect could
%    be achieved for background functions by not giving a function argument
%    at all; in the case of foreground functions, we insist that there is one.

ok=true;
mess='';

if isscalar(func_in) && ( isa(func_in,'function_handle') || isa(func_in,'sw') || isa(sqwfunc,'spinw') )
    func={func_in};     % cell array of length unity
    
elseif iscell(func_in) && ~isempty(func_in)
    n_empty = 0;
    for i=1:numel(func_in)
        if isempty(func_in{i})
            n_empty = n_empty+1;
        elseif ~isa(func_in{i},'function_handle') && ~isa(func_in{i},'sw') && ~isa(sqwfunc,'spinw')
            ok=false;
            mess='Elements of a function handle cell array argument must be function handles or empty';
            func={};
            return
        end
    end
    if n_empty==numel(func_in)
        ok=false;
        mess='At least one element of a function handle cell array argument must be a function handle';
        func={};
        return
    end
    func=func_in;

else
    ok=false;
    mess='Argument must be a function handle or cell array of function handles';
    func={};
    
end

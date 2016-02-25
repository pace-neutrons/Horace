function func = bfun(obj, in_fun)
% Field containing the background fit function(s).
%
% Valid inputs are:
%   - A single function handle (automatically sets 'global_foreground')
%   - Cell array of function handles (automatically sets 'local_foreground')
%
% In the case of datasets which are objects, the fit functions must be
% methods of the class of the objects, or must be valid functions which can
% be wrapped by a specified wrapper method of that class.
% The wrapper function, and validator may be defined in options to multifit,

% If not called as a callback
if nargin==1
    obj.ffun
    return
end

% Calls private functions to check the function(s) are ok
[ok,mess,func]=function_handles_valid(in_fun);
if ~ok
    error('Input is not a valid function');
end
[ok,mess,w] = repackage_input_datasets(obj.data);
[ok,mess,func] = function_handles_parse(func,size(w),obj.background_is_local);
if ~ok
    error(mess);
end

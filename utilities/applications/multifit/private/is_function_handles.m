function ok = is_function_handles (x)
% Determine if an argument is a function handle or a cell array of function handles
% Some, but not all, elements of the cell array can be empty. Empty elements will be later
% interpreted as not having a background function.

ok=false;
if iscell(x)
    n_empty=0;
    for i=1:numel(x)
        if isempty(x{i})
            n_empty = n_empty+1;
        elseif ~isa(x{i},'function_handle')
            return
        end
    end
    if numel(x)==n_empty, return, end     % every element was empty
    ok=true;
elseif isscalar(x) && isa(x,'function_handle')
    ok=true;
else
    ok=false;
end

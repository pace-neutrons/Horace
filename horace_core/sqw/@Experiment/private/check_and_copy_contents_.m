function [obj,n_new] = check_and_copy_contents_(obj,other_cont,field_name)
% compy specified non-empty contents from another object and return number
% of copied elements.

this_contents = obj.(field_name);
if all(isempty(this_contents))
    obj.(field_name) = other_cont;
    n_new = sum(~isempty(other_cont));
else
    n_new = 0;
    for i=1:numel(other_cont)
        if ~isempty(other_cont(i))
            this_contents(end+1) = other_cont(i);
            n_new = n_new+1;
        end
    end
    if n_new>0
        obj.(field_name) = this_contents;
    end
end


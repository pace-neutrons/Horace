function ok=islognum(val)
% Determine if a variable is a non-empty array of logicals, or numeric 0 or 1
if ~isempty(val) && (islogical(val) || (isnumeric(val) && all(val(:)==0|val(:)==1)))
    ok=true;
else
    ok=false;
end

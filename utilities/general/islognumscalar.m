function ok=islognumscalar(val)
% Determine if a value is a (non-empty) scalar logical, or is numeric 0 or 1
if isscalar(val) && (islogical(val) || (isnumeric(val) && (val==0 ||val==1)))
    ok=true;
else
    ok=false;
end

function is  = eq_(obj,other)
% compare two rundata objects or rundata object and rundata structure
s1 = obj.to_bare_struct('-rec');
flds = fieldnames(s1);
if isa(other,'rundata')
    s2 = other.to_bare_struct('-rec');
else
    s2 = other;
end
is = compare_struct(s1,s2,flds);

function is_eq = compare_struct(s1,s2,flds1)
%
is_eq = true;
if ~isstruct(s2)
    is_eq = false;
    return
end
flds2 = fieldnames(s2);
if numel(flds2)~=numel(flds1)
    is_eq = false;
    return;
end
if ~all(ismember(flds1,flds2))
    is_eq = false;
    return;
end

for i=1:numel(flds1)
    val1 = s1.(flds1{i});
    val2 = s2.(flds1{i});
    if isstruct(val1)
        fn = fieldnames(val1);
        is_eq = compare_struct(val1,val2,fn);
    else
        is_eq = val1 == val2 | isnan(val1) | isnan(val2);
        is_eq = all(is_eq(:));
    end
    if ~is_eq
        return;
    end
end

function ok = iscellnum(s)
% True for cell array of numerics (empty, scalar, or array)

if isa(s,'cell'),
    res = cellfun('isclass',s,'double');
    ok = all(res(:));
else
    ok = false;
end

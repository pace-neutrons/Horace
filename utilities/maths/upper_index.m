function m_ans = upper_index (arr, val)
%	Given monotonically increasing array ARR the function returns the largest index M
%     ARR(M) =< VAL
%
%	If no such M (i.e. ARR(1) > VAL) then M=0
%
% Syntax:
%   >> m_ans = upper_index (arr, val)
%

n = length(arr);

% return if array has zero length:
if (n == 0)
    m_ans = 0;
    return
end

% find extremal cases:
if (arr(n) <= val)
    m_ans = n;
    return
elseif (arr(1) > val)
    m_ans = 0;
    return
end

% binary chop to find solution
ml = 1;
mh = n;
mm = floor((ml+mh+0.001)/2);
while mm ~= ml
    if (arr(mm) > val)
        mh = mm;
    else
        ml = mm;
    end
    mm = floor((ml+mh+0.001)/2);
end
m_ans = ml;
return

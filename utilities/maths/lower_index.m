function m_ans = lower_index (arr,val)
%	Given monotonically increasing array ARR the function returns the smallest index M
%    ARR(M) >= VAL
%
%	If no such M (i.e. ARR(M) < VAL) then M=length(arr) + 1
%
% Syntax:
%   >> m_ans = lower_index (arr,val)
%
n = length(arr);
% return if array has zero length:
if (n == 0)
    m_ans = n+1;
    return
end

% find extremal cases:
if (arr(1) >= val)
    m_ans = 1;
    return
elseif (arr(n) < val)
    m_ans = n+1;
    return
end

% binary chop to find solution
ml = 1;
mh = n;
mm = floor((ml+mh+0.001)/2);
while mm ~= ml
    if (arr(mm) < val)
        ml = mm;
    else
        mh = mm;
    end
    mm = floor((ml+mh+0.001)/2);
end
m_ans = mh;
return

function m_ans = upper_index (arr, val)
% Return the largest index m such that arr(m)<=val given a strictly monotonically increasing array arr
%
%   >> m = upper_index (arr,val)
%
% If val<arr(1) then m=0
% val can be a scalar or an array

% Actually, the use of histc appears to give the correct result even if not *strictly* monotonic

n=numel(arr);
m=numel(val);

% Return if array has zero length:
if n==0
    m_ans=zeros(size(val));
    return
end

% Use matlab intrinsic function to get result if large enough array of test values
if m<16 || n==1 || 31*m*log(n)<n+2500
    m_ans=zeros(size(val));
    for i=1:m
        % find extremal cases, otherwise binary chop to find solution
        if (arr(n) <= val(i))
            m_ans(i) = n;
        elseif (arr(1) > val(i))
            m_ans(i) = 0;
        else
            ml = 1;
            mh = n;
            mm = floor((ml+mh+0.001)/2);
            while mm ~= ml
                if (arr(mm) > val(i))
                    mh = mm;
                else
                    ml = mm;
                end
                mm = floor((ml+mh+0.001)/2);
            end
            m_ans(i) = ml;
        end
    end
    
else
    [dummy,m_ans]=histc(val,arr(:)');
    m_ans(val>arr(end))=n;
    
end

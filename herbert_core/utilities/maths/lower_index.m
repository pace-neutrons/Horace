function m_ans = lower_index (arr,val)
% Return the smallest index m such that val=<arr(m) given a monotonically increasing array arr
%
%   >> m = lower_index (arr,val)
%
% If arr(end)<val then m=numel(arr)+1
% val can be a scalar or an array
% m has the same shape as val

% Actually, the use of histc appears to give the correct result even if not *strictly* monotonic

n=numel(arr);
m=numel(val);

% Return if array has zero length:
if n==0
    m_ans=ones(size(val));
    return
end

% Use matlab intrinsic function to get result if large enough array of test values
if m<70 || n==1 || 3.9*m*log(n)<n+1300
    m_ans=zeros(size(val));
    for i=1:m
        % find extremal cases, otherwise binary chop to find solution
        if (arr(1) >= val(i))
            m_ans(i) = 1;
        elseif (arr(n) < val(i))
            m_ans(i) = n+1;
        else
            ml = 1;
            mh = n;
            mm = floor((ml+mh+0.001)/2);
            while mm ~= ml
                if (arr(mm) < val(i))
                    ml = mm;
                else
                    mh = mm;
                end
                mm = floor((ml+mh+0.001)/2);
            end
            m_ans(i) = mh;
        end
    end
    
else
    [dummy,m_ans]=histc(-val,-fliplr(arr(:)'));
    m_ans(val<arr(1))=n;
    m_ans=(n+1)-m_ans;

end

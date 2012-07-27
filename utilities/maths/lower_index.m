function m_ans = lower_index (arr,val)
% Return the smallest index m such that val=<arr(m) given a strictly monotonically increasing array arr
%
%   >> m = lower_index (arr,val)
%
% If arr(end)<val then m=numel(arr)+1

n=numel(arr);

% Return if array has zero length:
if n==0
    m_ans=ones(size(val));
    return
end

% Use matlab intrinsic function to get result
[dummy,m_ans]=histc(-val,-fliplr(arr(:)'));
m_ans(val<arr(1))=n;
m_ans=(n+1)-m_ans;


% %------------------------------------------------------------------------------
% % Old code for archival reasons
% n = length(arr);
% % return if array has zero length:
% if (n == 0)
%     m_ans = n+1;
%     return
% end
% 
% % find extremal cases:
% if (arr(1) >= val)
%     m_ans = 1;
%     return
% elseif (arr(n) < val)
%     m_ans = n+1;
%     return
% end
% 
% % binary chop to find solution
% ml = 1;
% mh = n;
% mm = floor((ml+mh+0.001)/2);
% while mm ~= ml
%     if (arr(mm) < val)
%         ml = mm;
%     else
%         mh = mm;
%     end
%     mm = floor((ml+mh+0.001)/2);
% end
% m_ans = mh;
% return
% %------------------------------------------------------------------------------

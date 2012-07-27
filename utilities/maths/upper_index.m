function m_ans = upper_index (arr, val)
% Return the largest index m such that arr(m)<=val given a strictly monotonically increasing array arr
%
%   >> m = upper_index (arr,val)
%
% If val<arr(1) then m=0

% Actually, the use of histc appears to give the correct result even if not *strictly* monotonic

n = numel(arr);

% Return if array has zero length:
if n==0
    m_ans=zeros(size(val));
    return
end

% Use matlab intrinsic function to get result
[dummy,m_ans]=histc(val,arr(:)');
m_ans(val>arr(end))=n;


% %------------------------------------------------------------------------------
% % Old code for archival reasons
% n = length(arr);
% 
% % return if array has zero length:
% if (n == 0)
%     m_ans = 0;
%     return
% end
% 
% % find extremal cases:
% if (arr(n) <= val)
%     m_ans = n;
%     return
% elseif (arr(1) > val)
%     m_ans = 0;
%     return
% end
% 
% % binary chop to find solution
% ml = 1;
% mh = n;
% mm = floor((ml+mh+0.001)/2);
% while mm ~= ml
%     if (arr(mm) > val)
%         mh = mm;
%     else
%         ml = mm;
%     end
%     mm = floor((ml+mh+0.001)/2);
% end
% m_ans = ml;
% return
% %------------------------------------------------------------------------------

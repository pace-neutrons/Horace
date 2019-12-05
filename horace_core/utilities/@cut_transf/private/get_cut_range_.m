function range = get_cut_range_(obj)
% Retrieve full cut range in the form of cellarray,
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%

range = cell(1,4);
range{1} = obj.qh_range;
range{2} = obj.qk_range;
range{3} = obj.ql_range;
range{4} = obj.de_range;;
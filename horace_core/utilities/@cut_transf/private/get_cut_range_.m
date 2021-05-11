function range = get_cut_range_(obj)
% Retrieve full cut range in the form of cellarray,
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)
%

range = cell(1,4);
range{1} = obj.qh_range;
range{2} = obj.qk_range;
range{3} = obj.ql_range;
range{4} = obj.de_range;

end


function  val = do_convert_to_double(val)
% convert all numerical types of the structure into double
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%


if iscell(val)
    for i=1:numel(val)
        val{i} = dnd_file_interface.do_convert_to_double(val{i});
    end
elseif isstruct(val)
    fn = fieldnames(val);
    for i=1:numel(fn)
        val.(fn{i}) = dnd_file_interface.do_convert_to_double(val.(fn{i}));
    end
elseif isnumeric(val)
    val = double(val);
end


function  val = do_convert_to_double(val)
% convert all numerical types of the structure into double
%
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
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


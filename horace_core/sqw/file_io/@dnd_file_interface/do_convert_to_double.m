function  val = do_convert_to_double(val)
% convert all numerical types of the structure into double
%
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
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



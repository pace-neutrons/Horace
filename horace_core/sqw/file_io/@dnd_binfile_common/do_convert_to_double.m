function  val = do_convert_to_double(val)
% convert all numerical types of the structure into double
%

if iscell(val)
    for i=1:numel(val)
        val{i} = dnd_binfile_common.do_convert_to_double(val{i});
    end
elseif isstruct(val)
    fn = fieldnames(val);
    for i=1:numel(fn)
        val.(fn{i}) = dnd_binfile_common.do_convert_to_double(val.(fn{i}));
    end
elseif isnumeric(val)
    val = double(val);
end



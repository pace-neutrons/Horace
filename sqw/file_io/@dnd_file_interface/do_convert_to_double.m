function  val = do_convert_to_double(val)
% convert all numerical types of the structure into double
%
%
% $Revision: 1302 $ ($Date: 2016-10-26 18:31:29 +0100 (Wed, 26 Oct 2016) $)
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


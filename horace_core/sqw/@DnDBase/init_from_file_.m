function obj = init_from_file_(obj, in_filename)
% Parse DnD from file and intialise the class
%
% An error is raised if the data file is identified not a correctly
% dimensioned DnD object

ldr = sqw_formats_factory.instance().get_loader(in_filename);
if ~strcmpi(ldr.data_type, 'b+') % not a valid dnd-type structure
    error([upper(class(obj)), ':' class(obj)], ...
        'Data file does not contain valid dnd-type object');
end
if ldr.num_dim ~= obj.NUM_DIMS
    error([upper(class(obj)), ':' class(obj)], ...
        ['Data file does not contain ' num2str(obj.NUM_DIMS) 'd dnd-type object']);
end

[~, ~, ~, dnd_data] = ldr.get_dnd('-legacy');
obj = obj.init_from_loader_struct_(dnd_data);
end

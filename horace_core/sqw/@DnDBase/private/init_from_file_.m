function obj = init_from_file_(obj, in_filename)
% Parse DnD from file and intialise the class
%
% An error is raised if the data file is identified not a correctly
% dimensioned DnD or SQW object

ldr = sqw_formats_factory.instance().get_loader(in_filename);

isa_dnd_file = strcmpi(ldr.data_type, 'b+');
isa_sqw_file = strcmpi(ldr.data_type, 'a');

if ~(isa_sqw_file || isa_dnd_file)
    error([upper(class(obj)), ':' class(obj)], ...
        'Data file does not contain valid sqw- or dnd-type object');
end
if ldr.num_dim ~= obj.NUM_DIMS
    error([upper(class(obj)), ':' class(obj)], ...
        ['Data file does not contain ' num2str(obj.NUM_DIMS) 'd dnd-type object']);
end

ds = ldr.get_data('-nopix');
if isstruct(ds)
    ds = data_sqw_dnd(ds);
else
    ds.pix = PixelData();
    ds.img_db_range = PixelData.EMPTY_RANGE_;
end
obj.data = ds;

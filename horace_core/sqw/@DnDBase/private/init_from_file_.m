function obj = init_from_file_(obj, in_filename)
% Parse DnD from file and intialise the class
%
% An error is raised if the data file is identified not a correctly
% dimensioned DnD or SQW object

ldr = sqw_formats_factory.instance().get_loader(in_filename);

isa_dnd_file = strcmpi(ldr.data_type, 'b+');
isa_sqw_file = strcmpi(ldr.data_type, 'a');

if ~(isa_sqw_file || isa_dnd_file)
    error('HORACE:DnDBase:invalid_argument', ...
        'Data file %s does not contain valid sqw- or dnd-type object', ...
        in_filename);
end
if ldr.num_dim ~= obj.NUM_DIMS
    error('HORACE:DnDBase:invalid_argument', ...
        'Data file: %s does not contain %d-dim dnd-type object', ...
        in_filename,obj.NUM_DIMS);
end

ds = ldr.get_data('-nopix');
if isstruct(ds)
    ds = data_sqw_dnd(ds);
else
    ds.pix = PixelData();
end
obj.data = ds;

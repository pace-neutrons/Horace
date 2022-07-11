function data_struct = init_arrays_(data_struct,sz)

data_fields = {'s','e','npix'};
for i = 1:numel(data_fields)
    data_struct.(data_fields{i}) = zeros(sz);
end
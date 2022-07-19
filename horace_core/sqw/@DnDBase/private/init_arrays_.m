function data_struct = init_arrays_(data_struct,sz)

data_fields = {'s','e','npix'};
for i = 1:numel(data_fields)-1
    data_struct.(data_fields{i}) = zeros(sz);
end
data_struct.npix = ones(sz);
function data = get_random_data_in_range(cols, rows, data_range)
% GET_RANDOM_DATA_IN_RANGE: Create an [cols x rows] array of random numbers:
%           min=data_range(1) < value < max=data_range(2)
%
data = data_range(1) + (data_range(2) - data_range(1)).*rand(cols, rows);

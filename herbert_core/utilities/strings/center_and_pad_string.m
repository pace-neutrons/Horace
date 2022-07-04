function padded_str = center_and_pad_string(central_str, pad_str, pad_to_length)
% Center the given string whilst padding to the given length
%
to_append = repmat(pad_str, 1, floor((pad_to_length - numel(central_str))/2));
to_prepend = repmat(pad_str, 1, ceil((pad_to_length - numel(central_str))/2));
padded_str = sprintf('%s%s%s', to_append, central_str, to_prepend);

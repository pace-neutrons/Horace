function [pix_fields, abs_pix_indices] = parse_set_fields_args_(obj, pix_fields, data, abs_pix_indices)
% process inputs for set_raw_fields function
%

if isempty(pix_fields) || ~(iscellstr(pix_fields) || istext(pix_fields))
    error('HORACE:PixelDataBase:invalid_argument', ...
          'pix_fields must be nonempty text or cellstr');
end

if ~isnumeric(data)
    error('HORACE:PixelDataBase:invalid_argument', ...
          'data must be numeric array');
end

if exist('abs_pix_indices', 'var')
    if ~isindex(abs_pix_indices)
        error('HORACE:PixelDataBase:invalid_argument', ...
              'abs_pix_indices must be logical or numeric array of pixels to modify');
    end

    if islogical(abs_pix_indices)
        abs_pix_indices = logical_to_normal_index_(obj, abs_pix_indices);
    end

    if any(abs_pix_indices > obj.num_pixels)
        error('HORACE:PixelDataBase:invalid_argument', ...
              'Invalid indices in abs_pix_indices');
    end
else
    abs_pix_indices = obj.NO_INPUT_INDICES;
end

pix_fields = cellstr(pix_fields);
pix_fields = obj.check_pixel_fields(pix_fields);

if size(data, 1) ~= numel(pix_fields)
    error('HORACE:PixelDataBase:invalid_argument', ...
          ['Number of fields in ''pix_fields'' must be equal to number ' ...
           'of columns in ''data''.\nn_pix_fields: %i, n_data_columns: %i.'], ...
          numel(pix_fields), size(data, 1) ...
         );
end

if ~isequal(abs_pix_indices, obj.NO_INPUT_INDICES) && size(data, 2) ~= numel(abs_pix_indices)
    error('HORACE:PixelDataBase:invalid_argument', ...
          ['Number of indices in ''abs_pix_indices'' must be equal to ' ...
           'number of rows in ''data''.\nn_pix: %i, n_data_rows: %i.'], ...
          numel(abs_pix_indices), size(data, 2) ...
         );
end

end

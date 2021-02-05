function data_out = get_data(obj, pix_fields, varargin)
% GET_DATA Retrieve data for a field, or fields, for the given pixel indices in
% the full pixel block. If no pixel indices are given, the full range of pixels
% is returned.
%
% This method provides a convenient way of retrieving multiple fields
% of data from the pixel block. When retrieving multiple fields, the
% columns of data will be ordered corresponding to the order the fields
% appear in the inputted cell array.
%
%   >> sig_and_err = pix.get_data({'signal', 'variance'})
%        retrieves the signal and variance over the whole range of pixels
%
%   >> run_det_id_range = pix.get_data({'run_idx', 'detector_idx'}, 15640:19244);
%        retrieves the run and detector IDs for pixels 15640 to 19244
%
% Input:
% ------
%   pix_fields       The name of a field, or a cell array of field names
%   abs_pix_indices  The pixel indices to retrieve, if not given, get full range
%
NO_INPUT_INDICES = -1;

[pix_fields, abs_pix_indices] = parse_args(obj, pix_fields, varargin{:});
field_indices = cell2mat(obj.FIELD_INDEX_MAP_.values(pix_fields));

if obj.is_file_backed_()

    base_pg_size = obj.base_page_size;
    if abs_pix_indices == -1
        first_required_page = 1;
        data_out = zeros(numel(pix_fields), obj.num_pixels);
    else
        first_required_page = ceil(min(abs_pix_indices)/base_pg_size);
        data_out = zeros(numel(pix_fields), numel(abs_pix_indices));
    end

    obj.move_to_page(first_required_page);

    data_out = assign_page_values(...
            obj, data_out, abs_pix_indices, field_indices, base_pg_size);
    while obj.has_more()
        obj.advance();
        data_out = assign_page_values(...
                obj, data_out, abs_pix_indices, field_indices, base_pg_size);
    end

else

    if abs_pix_indices == NO_INPUT_INDICES
        % No pixel indices given, return them all
        data_out = obj.data(field_indices, :);
    else
        data_out = obj.data(field_indices, abs_pix_indices);
    end

end

end  % function


% -----------------------------------------------------------------------------
function data_out = assign_page_values(...
        obj, data_out, abs_pix_indices, field_indices, base_pg_size ...
    )
    NO_INPUT_INDICES = -1;

    start_idx = (obj.page_number_ - 1)*base_pg_size + 1;
    end_idx = min(obj.page_number_*base_pg_size, obj.num_pixels);
    if abs_pix_indices == NO_INPUT_INDICES
        data_out(:, start_idx:end_idx) = obj.data(field_indices, 1:end);
    else
        [pg_idxs, global_idxs] = ...
            get_pg_idx_from_absolute_(obj, abs_pix_indices, obj.page_number_);
        data_out(:, global_idxs) = obj.data(field_indices, pg_idxs);
    end
end


function [pix_fields, abs_pix_indices] = parse_args(obj, varargin)
    NO_INPUT_INDICES = -1;

    parser = inputParser();
    parser.addRequired('pix_fields', @(x) ischar(x) || iscell(x));
    parser.addOptional('abs_pix_indices', NO_INPUT_INDICES, ...
                       @is_positive_int_vector_or_logical_vector);
    parser.parse(varargin{:});

    pix_fields = parser.Results.pix_fields;
    abs_pix_indices = parser.Results.abs_pix_indices;

    pix_fields = validate_pix_fields(obj, pix_fields);

    if abs_pix_indices ~= NO_INPUT_INDICES
        if islogical(abs_pix_indices)
            if numel(abs_pix_indices) > obj.num_pixels
                if any(abs_pix_indices(obj.num_pixels + 1:end))
                    error('PIXELDATA:get_data', ...
                          ['The logical indices contain a true value ' ...
                           'outside of the array bounds.']);
                else
                    abs_pix_indices = abs_pix_indices(1:obj.num_pixels);
                end
            end
            abs_pix_indices = find(abs_pix_indices);
        end

        max_idx = max(abs_pix_indices);
        if max_idx > obj.num_pixels
            error('PIXELDATA:get_data', ...
                  ['Pixel index out of range. Index must not exceed %i, ' ...
                   'found %i'], obj.num_pixels, max_idx);
        end
    end
end


function is = is_positive_int_vector_or_logical_vector(vec)
    is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end


function pix_fields = validate_pix_fields(obj, pix_fields)
    if ~isa(pix_fields, 'cell')
        pix_fields = {pix_fields};
    end

    for i = 1:numel(pix_fields)
        field = pix_fields{i};
        if ~obj.FIELD_INDEX_MAP_.isKey({field})
            valid_fields = obj.FIELD_INDEX_MAP_.keys();
            error('PIXELDATA:get_data', ...
                  ['Given field ''%s'' is not a valid pixel field.\n' ...
                   'Valid fields are: [''%s'']'], ...
                  strip(evalc('disp(field)')), strjoin(valid_fields, ''', '''));
        end
    end
end

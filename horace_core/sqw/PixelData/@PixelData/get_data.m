function data = get_data(obj, pix_fields, varargin)
% Retrive data for a field, or fields, for the given pixel indices in
% the current page. If no pixel indices are given, all pixels in the
% current page are returned.
%
% This method provides a convinient way of retrieving multiple fields
% of data from the pixel block. When retrieving multiple fields, the
% columns of data will be ordered corresponding to the order the fields
% appear in the inputted cell array.
%
%   >> sig_and_err = pix.get_data({'signal', 'variance'})
%        retrives the signal and variance over the whole range of pixels
%
%   >> run_det_id_range = pix.get_data({'run_idx', 'detector_idx'}, 4:10);
%        retrives the run and detector IDs for pixels 4 to 10
%
% Input:
% ------
%   pix_fields       The name of a field, or a cell array of field names
%   abs_pix_indices  The pixel indices to retrieve, if not given, get full range
%
[pix_fields, abs_pix_indices] = parse_args(obj, pix_fields, varargin{:});

field_indices = cell2mat(obj.FIELD_INDEX_MAP_.values(pix_fields));

if abs_pix_indices == -1
    % No pixel indices given, return them all
    data = obj.data(field_indices, :);
else
    data = obj.data(field_indices, abs_pix_indices);
end

end  % function


% -----------------------------------------------------------------------------
function [pix_fields, abs_pix_indices] = parse_args(obj, varargin)
    parser = inputParser();
    parser.addRequired('pix_fields', @(x) ischar(x) || iscell(x));
    parser.addOptional('abs_pix_indices', -1, @is_positive_int_vector_or_logical_vector);
    parser.parse(varargin{:});

    pix_fields = parser.Results.pix_fields;
    abs_pix_indices = parser.Results.abs_pix_indices;

    pix_fields = validate_pix_fields(obj, pix_fields);
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


function is = is_positive_int_vector_or_logical_vector(vec)
    is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end

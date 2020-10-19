function data = get_data(obj, fields, pix_indices)
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
%   fields      The name of a field, or a cell array of field names
%   pix_indices The pixel indices to retrieve, if not given, get full range
%
if ~isa(fields, 'cell')
    fields = {fields};
end
obj = obj.load_current_page_if_data_empty_();
try
    field_indices = cell2mat(obj.FIELD_INDEX_MAP_.values(fields));
catch ME
    switch ME.identifier
    case 'MATLAB:Containers:Map:NoKey'
        error('PIXELDATA:get_data', ...
                'Invalid field requested in PixelData.get_data().')
    otherwise
        rethrow(ME)
    end
end

if nargin < 3
    % No pixel indices given, return them all
    data = obj.data(field_indices, :);
else
    data = obj.data(field_indices, pix_indices);
end

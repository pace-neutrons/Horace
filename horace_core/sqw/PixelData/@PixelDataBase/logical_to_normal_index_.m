function normal_indices = logical_to_normal_index_(obj, logical_indices)
%LOGICAL_TO_NORMAL_INDEX_ Convert the given logical indices to normal indices
%
% If there are any 'true' values outside the range of pixels
% (e.g. logical_indices(obj.num_pixels + 1) == true), an error with ID
% 'HORACE:PIXELDATA:badsubscript' will be thrown. 'false' values outside the
% range of pixels are ignored.
%
% Input:
% ------
% logical_indices   An array of logicals
%
% Outputs:
% --------
% normal_indices    A vector of "normal" indices i.e. positive integers.
%
% Examples:
% ---------
%
%   >> logical_to_normal_index_(pix, [0, 1, 1, 0, 0, 1, 0, 1])
%        ans =
%            [2, 3, 6, 8]
%
if numel(logical_indices) > obj.num_pixels
    if any(logical_indices(obj.num_pixels + 1:end))
        error('HORACE:PixelDataBase:invalid_argument', ...
              'The logical indices contain a true value outside of the array bounds.');
    end
    logical_indices = logical_indices(1:obj.num_pixels);
end

normal_indices = find(logical_indices);


end

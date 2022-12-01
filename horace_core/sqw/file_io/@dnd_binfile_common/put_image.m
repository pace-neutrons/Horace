function obj = put_image(obj, s, e)
%PUT_IMAGE_SIGNAL Write the image signal and error to file
%
% The input array's sizes must match the sizes of the signal and error arrays
% in the object or file this loader was initialized from.
%
% Input:
% ------
% s     The image signal. Must be a numeric array. The number of elements in
%       the array must match the number of elements in the image signal of the
%       object or file used to initialize this loader.
% e     The image error. This must be numeric array and have the same number of
%       elements as s.
%
BYTES_IN_SINGLE = 4;

check_obj_initiated_properly_(obj);

validateattributes(s, {'numeric'}, {}, 'put_image', 's');
validateattributes(e, {'numeric'}, {}, 'put_image', 'e');

if numel(s) ~= numel(e)
    error( ...
        'HORACE:dnd_binfile_common:invalid_argument', ...
        'Input image signal and error have different numbers of elements.' ...
    );
end

bytes_in_image_array = numel(s)*BYTES_IN_SINGLE;
bytes_in_file_image_array = obj.e_pos_ - obj.s_pos_;

if bytes_in_image_array ~= bytes_in_file_image_array
    error( ...
        'HORACE:dnd_binfile_common:invalid_argument', ...
        ['Image signal size in file does not match the size of the input.\n' ...
         '''%i'' elements in file, ''%i'' elements in input array.'], ...
        bytes_in_file_image_array/BYTES_IN_SINGLE, numel(bytes_in_image_array) ...
    );
end

obj.put_image_no_validate_(s, e);

function obj = put_image(obj, s, e)
%PUT_IMAGE_SIGNAL Write the image signal and error to file
%
% Input:
% ------
% s     The image signal. Must be a numeric array.
% e     The image error. This must be numeric array and have the same number of
%       elements as s.
%
BYTES_IN_SINGLE = 4;

check_obj_initiated_properly_(obj);

validateattributes(s, {'numeric'}, {}, 'put_image', 's');
validateattributes(e, {'numeric'}, {}, 'put_image', 'e');

if numel(s) ~= numel(e)
    error( ...
        'HORACE:DND_BINFILE_COMMON:length_mismatch', ...
        'Input image signal and error have different numbers of elements.' ...
    );
end

bytes_to_write = numel(s)*BYTES_IN_SINGLE;
bytes_in_file = obj.e_pos_ - obj.s_pos_;

if bytes_to_write ~= bytes_in_file
    error( ...
        'HORACE:DND_BINFILE_COMMON:invalid_length', ...
        ['Image signal size in file does not match the size of the input.\n' ...
         '''%i'' elements in file, ''%i'' elements in input array.'], ...
        bytes_in_file/BYTES_IN_SINGLE, numel(bytes_to_write) ...
    );
end

obj.put_image_no_validate_(s, e);

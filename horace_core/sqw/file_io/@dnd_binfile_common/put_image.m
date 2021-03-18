function obj = put_image(obj, s, e)
%PUT_IMAGE_SIGNAL Write the image signal to file
%
BYTES_IN_SINGLE = 4;

validateattributes(s, {'numeric'}, {}, 1);
validateattributes(e, {'numeric'}, {}, 2);

if numel(s) ~= numel(e)
    error( ...
        'HORACE:dnd_binfile_common:length_mismatch', ...
        'Input image signal and error have different numbers of elements' ...
    );
end

bytes_to_write = numel(s)*BYTES_IN_SINGLE;
bytes_in_file = obj.e_pos_ - obj.s_pos_;

if bytes_to_write ~= bytes_in_file
    error( ...
        'HORACE:dnd_binfile_common:invalid_length', ...
        ['Image signal size in file does not match the size of the input.\n' ...
         '''%i'' elements in file, ''%i'' elements in input array.'], ...
        bytes_in_file/BYTES_IN_SINGLE, numel(bytes_to_write) ...
    );
end

fseek(obj.file_id_, obj.s_pos_, 'bof');
check_error_report_fail_(obj, 'Error moving to the beginning of the signal record');

fwrite(obj.file_id_, s, 'float32');
check_error_report_fail_(obj, 'Error writing signal record');

fseek(obj.file_id_, obj.e_pos_, 'bof');
check_error_report_fail_(obj, 'Error moving to the beginning of the error record');

fwrite(obj.file_id_, e, 'float32');
check_error_report_fail_(obj, 'Error writing error record');

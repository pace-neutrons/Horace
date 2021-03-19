function obj = put_image_no_validate_(obj, s, e, s_pos)
%PUT_IMAGE_NO_VALIDATE Write the image signal & error
%
% This function performs no checks that the loader has been initialized
% correctly and the loader's file is open. The calling function should
%
if nargin < 4
    s_pos = obj.s_pos_;
end

fseek(obj.file_id_, s_pos, 'bof');
check_error_report_fail_(obj, 'Error moving to the beginning of the signal record');

fwrite(obj.file_id_, s, 'float32');
check_error_report_fail_(obj, 'Error writing signal record');

fseek(obj.file_id_, obj.e_pos_, 'bof');
check_error_report_fail_(obj, 'Error moving to the beginning of the error record');

fwrite(obj.file_id_, e, 'float32');
check_error_report_fail_(obj, 'Error writing error record');

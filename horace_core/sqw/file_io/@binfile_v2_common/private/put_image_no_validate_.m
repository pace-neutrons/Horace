function obj = put_image_no_validate_(obj, s, e, s_pos)
%PUT_IMAGE_NO_VALIDATE Write the image signal and error to file
%
% This function performs no checks that the loader has been initialized
% correctly and that the loader's file is open. It also does not verify that
% the input image and error have the same number of elements.
% The calling function should perform these checks to avoid corrupted files.
%
% Input:
% ------
% s      The image signal. Must be a numeric array.
% e      The image error. This must be a numeric array and have the same number
%        of elements as s.
% s_pos  The position in the file of the start of the signal array (which is
%        the start of the image data). This value may be different from
%        `obj.s_pos_` if the file format is being upgraded. This argument is
%        optional, `obj.s_pos_` is the default.
%
if nargin < 4
    s_pos = obj.s_pos_;
end

try
    do_fseek(obj.file_id_, s_pos, 'bof');
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Error moving to the beginning of the signal record');
    throw(exc.addCause(ME))
end


fwrite(obj.file_id_, single(s), 'float32');
check_error_report_fail_(obj, 'Error writing signal record');

try
    do_fseek(obj.file_id_, obj.e_pos_, 'bof');
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Error moving to the beginning of the error record');
    throw(exc.addCause(ME))
end

fwrite(obj.file_id_, single(e), 'float32');
check_error_report_fail_(obj, 'Error writing error record');

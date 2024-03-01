function print_range_warning_(obj,infile_name,is_old_file_format)
% print the warning informing user that the source file
% contains invalid data range and file format should be
% upgraded.
% Input:
% op_name     -- the name of operation which performs calculations
% infile_name -- the name of the file-source of filebacked sqw
%                object, which does not contain correct data
%                range
% is_old_file_format
%             -- true or false specifying the reason why the
%                file does not have correct range and message,
%                suggesting best way to upgrade.
%        true -- the file does not have correct range due to
%                old file format
%        false-- the file does not contain correct data range
%                because it has been realigned
op_name = obj.op_name;
[~,fn,fe] = fileparts(infile_name);
if is_old_file_format
    upgrade_message = obj.gen_old_file_message(infile_name);
else
    upgrade_message = obj.gen_misaligned_file_message(infile_name);
end
fprintf(2,[ '\n', ...
    '*** Source SQW file %s does not contain correct pixel data ranges.\n', ...
    '*** Operation %s calculates and stores it in the temporary file together with results of the operation.\n', ...
    '*** Averages are calculated on requests by algorithms which use them\n', ...
    '    and this may take substantial time for large files\n', ...
    '*** Upgrade your original sqw object to contain these averages\n' ...
    '    and not to recalculate them each time the averages are requested\n', ...
    '*** Or quick-save this resulting file-backed temporary SQW object for further usage.\n', ...
    '%s' ], ...
    [fn,fe],op_name,upgrade_message);

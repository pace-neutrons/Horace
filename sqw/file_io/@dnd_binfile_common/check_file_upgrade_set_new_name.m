function    [obj,ness] = check_file_upgrade_set_new_name(obj,new_filename,new_data_struct)
% set new file name to save sqw data in and verify if upgrade to new file format is possible
%

ness = false;
[fp,fn,fext] = fileparts(new_filename);
check_upgrade = false;
if obj.file_id_ > 0
    check_upgrade = true;
end
if ~exist('new_data_struct','var')
    check_upgrade = false;
end


[real_fp,real_fn,real_ex] = fileparts(fopen(obj.file_id_));

if obj.file_id_ > 0
    stat= fclose(obj.file_id_);
    if stat == -1
        error('SQW_BINFILE_COMMON:io_error',...
            'Unable to close exsiting file: %s before storing new data into it',...
            fullfile(real_fp,[real_fn,real_ex]));
        
    end
end

if check_upgrade
    [fp,fn,ness] = check_upgrade_necessary(obj,fp,fn,fext,real_fp,real_fn,real_ex,new_data_struct);
else
    fn = [fn,fext];
end
%
obj.filename_ = fn;
if ~isempty(fp)
    obj.filepath_ = fp;
end


function   [fp,fn,ok] = check_upgrade_necessary(obj,fp,fn,fext,real_fp,real_fn,real_ex,new_data_struct)
% check if name of new and old file coinside, and if yes, verify if old
% file can be easily upgraded with new data

if ~(strcmp(fn,real_fn) && strcmp(fext,real_ex) && strcmp(fp,real_fp))
    fp = [fp,filesep]; % old filename and new filename are different.
    fn = [fn,fext];    % no upgrade is necessary
    ok = false;
    return;
end

% old and new fnames are the same
if obj.pix_pos_ ~= new_data_struct.pix_pos_
    error('SQW_BINFILE_COMMON:invalid_argument',...
        'Can not upgrade existing file as pixel positions are different. Save data into different sqw file');
end
fp = [fp,filesep]; % old filename and new filename are the same.
fn = [fn,fext];    % but upgrade can and should be done 
ok = true;






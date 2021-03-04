function [success,folder_path,mess]=try_to_create_folder(location,folder_name,ext)
% The function tries to creates folder in specified directory, checking for
% it existence first. If folder exists, the routine checks that this folder is
% accessible for writing.
%
% Inputs:
% location       -- the topmost location, where the folder should be created
% folder_name    -- the name of the folder to create
% ext            -- if present, part of the name to add to test folder
%                   created to verify wrtie access to the base folder.
%
% Returns:
% success     -- true if the folder is created and available for writing or
%                exists and is available for writing.
% folder_path -- the path to the created folder.
% mess        -- empty if success or reason for the issue if it was not.
%
folder_path = [location,filesep,folder_name];
if nargin<3
    ext = '';
end

ic = 0;
if ~is_folder(folder_path)
    [success, mess] = mkdir(folder_path);
    while ~(is_folder(folder_path) || ic<3)
        [success, mess] = mkdir(folder_path);
        ic = ic + 1;
        pause(0.1);
    end
else
    old_rng_state = rng('shuffle', 'simdTwister');
    cleanup = onCleanup(@() rng(old_rng_state));
    test_path = fullfile(folder_path,['folder_twa_',ext,char(randi(25,1,10) + 64)]);
    [success, mess] = mkdir(test_path);
    if success
        if is_folder(test_path)
            [statrm,msg] = rmdir(test_path);
            if ~statrm
                warning('MAKE_CONFIG_FOLDER:runtime_error',...
                    ' Can not remove test folder %s; message: %s',test_path,msg);
            end
        end
    end
end


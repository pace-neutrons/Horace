function make_folder_(folder_name,root_name)
% Createe the folder specified as input and throw appropriate error if this
% is impossible.

if ~exist(folder_name,'dir')
    [ok, mess] = mkdir(folder_name);
    if ~ok
        error('FILEBASED_MESSAGES:runtime_error',...
            'Can not create message exchange folder within %s\n  Error message: %s',...
            root_name,mess);
    end
else
    test_folder = fullfile(folder_name,char(floor(25*rand(1,10)) + 65));
    clob = onCleanup(@()rmdir(test_folder,'s'));
    [ok, mess] = mkdir(test_folder);
    if ~ok
        error('FILEBASED_MESSAGES:runtime_error',...
            'Folder %s exists but is not write-enabled\n  Error message: %s',...
            folder_name,mess);
    end
    
end


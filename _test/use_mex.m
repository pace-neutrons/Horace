function use_mex(ok)
% Set use of mex files or matlab equivalents for testing purposes.
% Assumes herbert_init has been run
% Should be robust to changes in organisation of files in Herbert

persistent save_ok

rootpath = fileparts(which('herbert_init'));
start_dir=pwd;

% Make no changes if already pointing to correct location of function
if ok==save_ok
    return
end

try
    cd(rootpath)
    herbert_off
    if ok
        herbert_init
    else
        herbert_init('matlab')
    end
    cd(start_dir)
    if ok
        disp('Mex files will be used')
    else
        disp('Matlab files will be used')
    end
    save_ok=ok;
catch
    cd(start_dir)
end

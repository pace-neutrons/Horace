function [ok,mess] = check_matfile_IO (ver_str, save_variables, filepath,varargin)
% Save to or read from mat file
% input
% ver_str        -- the name of the version string e.g. ver0 for old
%                   version ver1 for version 1 etc
% save_variables -- if true, saves sample variables, if false load
%                   them from disk
% filepath       -- the location of source test files on hdd.
%                   If the routine writes to disk, it writes
%                   test files into temporarty directory
% varargin       -- variables to save/load on hdd
mess = '';
ok = true;
for i=1:numel(varargin)
    class_name = class(varargin{i});
    arg_name = inputname(i+3);
    flname = [ver_str,'_',class_name,'_',arg_name,'.mat'];
    if save_variables
        eval([arg_name,' = varargin{i};']);
        try
            save(fullfile(tmp_dir,flname),arg_name);
        catch
            mess=['*** ERROR: Problem writing ',arg_name,' to ',flname];
            ok = false;
        end
    else
        tmp = load(fullfile(filepath,'saved_class_versions_as_mat_files',flname),arg_name);
        if ~isequal(varargin{i},tmp.(arg_name))
            ok = false;
            mess=['*** ERROR: Argument ''',arg_name,''' read from ',flname,' does not match original'];
        end
    end
end

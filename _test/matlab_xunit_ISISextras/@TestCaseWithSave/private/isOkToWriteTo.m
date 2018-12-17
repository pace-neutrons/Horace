function ok = isOkToWriteTo (folder)
% Check if a folder is write protected or not in an OS independent way
%
%   >> ok = isOkToWriteTo (folder)
%
% Input:
% ------
%   folder      Absolute path
%
% Output:
% -------
%   ok          True if OK to write to; false otherwise


test_dir = fullfile(folder,['TestCaseWithSave_',str_random]);
ok = mkdir(test_dir);
if ok
    rmdir(test_dir,'s')
end

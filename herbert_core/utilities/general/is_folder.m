function ok = is_folder(name)
% tests if name is a folder on the file system while NOT searching MATLAB path
%
% On older versions of matlab this is done through ensuring the path is an explicit path
% and using exist. More recent versions simply call the MATLAB built-in isfile.
%
% Input:
% ------
%   name                The name of the file you want to check;
%
% Usage:
% ------
%  >> is_file('/home/user/test');        % True if folder exists
%  >> is_file('test');                   % True if folder exists in current dir
%

     if ~verLessThan('matlab', '9.1') % R2016b
         ok = isfolder(name);
     else
         currpath = fileparts(strtrim(name));
         if isempty(currpath)
             currpath = pwd();
             name = fullfile(currpath, name);
         end

        ok = exist(name, 'dir') == 7;
     end

end

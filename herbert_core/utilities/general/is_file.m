function ok = is_file(name)
% tests if name is a file on the file system while NOT searching MATLAB path
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
%  >> is_file('/home/user/test.m');        % True if file exists
%  >> is_file('test.m');                   % True if file exists in current dir
%

% Remove searching MATLAB path with explicit path
if ~verLessThan('matlab', '9.1') % R2016b
    ok = isfile(name);
else
    currpath = fileparts(name);
    if isempty(currpath)
        currpath = pwd();
        name = fullfile(currpath, name);
    end
    
    ok = exist(name, 'file') == 2;
end
end

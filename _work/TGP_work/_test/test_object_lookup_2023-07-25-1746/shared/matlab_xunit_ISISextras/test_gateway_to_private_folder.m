function varargout = test_gateway_to_private_folder (func_name, varargin)
% Gateway to enable test of functions and methods in class /private folder
%
% This function gives access to functions in the .../@my_class/private
% folder, which otherwise cannot be directly called or debugged. Such a
% function can define a private method or a private function.
%
% To enable such a test for a class called my_class, ensure that the class
% definition file includes the lines:
%
%       :
%   methods(Static)
%       function varargout = test_gateway (func_name, varargin)
%           % Access functions in the /private folder for testing purposes
%           varargout = cell(1, nargout);
%           [varargout{:}] = test_gateway__to_private_folder (func_name, varargin{:});
%       end
%   end
%       :
%
% This enables the following line of code
%
%   >> [b1, b2,...] = my_class.test_gateway ('myfunc', a1, a2, ...)
%
% to evaluate the following function in the class definition private folder:
%
%   >> [b1, b2,...] = myfunc (a1, a2, ...)


% Get working folder and set up return on exit
current_dir = pwd;
cleanup = onCleanup(@()myCleanupFun(current_dir));

% Check that a .m file with the desired name exists in the class private folder
if is_string(func_name) && ~isempty(func_name)
    ST = dbstack(1);
    if ~isempty(ST)
        name = ST(1).name;
        class_name = name(1:regexp(name,'\.')-1);
        class_path = fileparts(which(class_name));
        func_path = fullfile(class_path,'private');
        full_func_name = fullfile(func_path, [func_name, '.m']);
        if ~is_file(full_func_name)
            error(['File does not exist: ',full_func_name])
        end
    else
        error (['This function (', mfilename(), ') is not being called from a function'])
    end
else
    error('Check second argument is the name of a function')
end

% Move to private folder to evaluate the function
cd(func_path);
func_handle = str2func(func_name);
nout = min(nargout, nargout(func_name));

varargout = cell(1,nout);
[varargout{:}] = func_handle(varargin{:});

end

% =========================================================================
function myCleanupFun(folder)
cd (folder)
end

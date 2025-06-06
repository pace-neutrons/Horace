classdef horace_paths
    % Helper class, containing information about the main paths used by Horace.
    % The public class properties hold the following paths:
    %
    % herbert          - path to main Herbert code
    % horace           - path to main Horace code
    % root             - path to folder which contains all Horace code
    % test             - path to folder with all unit tests
    % test_common      - path to test data used by multiple tests
    % test_common_func - path to functions used by multiple tests
    % admin            - path to folder containing main scripts to control
    %                    Horace and Herbert code, mainly used in installation
    %                    and building Horace
    % low_level        - path to folder with C++ code
    % bm               - path to benchmarking code
    % bm_common        - path to benchmarking data
    % bm_common_func   - path to common functions used by all benchmarking tests
    %
    % Useage:
    % -------
    % Get a particular path:
    %   >> root_path = horace_paths().root;     % get root path
    %
    %   Note: the brackets in horace_path() are required
    %
    % Get an instance of the helper class:
    %   >> p = horace_paths;
    %       :
    %   >> root_path  = p.root;     % get root path
    %
    % Note: if one of the paths does not exist, a warning is printed if you
    % display the helper_class i.e. if the semi-colon is omitted:
    % E.G.
    %   >> horace_paths
    %   Warning: Cannot find benchmarking/common_data, possibly failed setup 
    %   > In horace_paths/get.bm_common (line 104) 
    %
    % The syntax has been retained from the original implementation, that used
    % global variables, for backwards compatibility.

    properties(Dependent)
        herbert  % path to main Herbert code
        horace   % path to main Horace code
        root     % path to folder which contains all Horace code
        test     % path to folder with all unit tests
        test_common % path to test data used by multiple tests
        test_common_func % path to functions used by multiple tests
        admin    % path to folder containing main scripts to control Horace and Herbert code
        low_level % path to folder with C++ code
        bm        % path to benchmarking code
        bm_common % path to benchmarking data
        bm_common_func % path to common functions used by all benchmarking tests
    end
    
    properties(Access=protected)
        herbert_path_
        horace_path_
        root_path_
    end


    methods
        function path = get.herbert(obj)
            path = obj.herbert_path_;
        end
        
        function path = get.horace(obj)
            path = obj.horace_path_;
        end
        
        function root_path = get.root(obj)
            root_path =  obj.root_path_;
        end
        
        function path = get.test(obj)
            path = fullfile(obj.root, '_test');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find test path, possible failed setup')
            end
        end
        
        function path = get.test_common(obj)
            path = fullfile(obj.test, 'common_data');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find test/common_data, possibly failed setup')
            end
        end
        
        function path = get.test_common_func(obj)
            path = fullfile(obj.test, 'common_functions');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find test/common_functions, possibly failed setup')
            end
        end
        
        function path = get.admin(obj)
            path = fullfile(obj.root, 'admin');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find admin path, possibly failed setup')
            end
        end
        
        function path = get.low_level(obj)
            path = fullfile(obj.root, '_LowLevelCode');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find low level code path, possibly failed setup')
            end
        end
        
        function path = get.bm(obj)
            path = fullfile(obj.root, '_benchmarking');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find benchmarking path, possible failed setup')
            end
        end
        
        function path = get.bm_common(obj)
            path = fullfile(obj.bm, 'common_data');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find benchmarking/common_data, possibly failed setup')
            end
        end
        
        function path = get.bm_common_func(obj)
            path = fullfile(obj.bm, 'common_functions');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', ...
                    'Cannot find benchmarking/common_functions, possibly failed setup')
            end
        end
        
        %------------------------------------------------------------------
        function obj = horace_paths(varargin)
            % Constructor of horace_paths helper class
            %
            %   >> paths = horace_paths
            %   >> horace_paths.clear()     % clear 
            %
            %
            persistent path_holder;
            
            % Clear persistent variable if requested
            if nargin==1 && istext(varargin{1}) && strcmp(varargin{1},'clear')
                    path_holder = [];
            elseif nargin~=0
                error('HORACE:paths:invalid_argument', 'Unrecognised argument(s)')
            end
            
            % Fill persistent variable if empty
            if isempty(path_holder)
                path_holder = struct();
                path_holder.herbert_path_ = fileparts(which('herbert_init'));
                path_holder.horace_path_  = fileparts(which('horace_init'));
                % Assume root path is the folder above horace_path
                path_holder.root_path_    = fileparts(path_holder.horace_path_);
            end
            obj.herbert_path_ =  path_holder.herbert_path_;
            obj.horace_path_  =  path_holder.horace_path_;
            obj.root_path_    =  path_holder.root_path_;
        end
    end
    
    methods(Static)
        function folder = get_folder(function_or_class)
            % Past versions of horace_paths had this static method, and it is
            % required if one is running horace_on to install such an earlier
            % version of Horace. Therefore, do not remove this static method.
            folder = fileparts(which(function_or_class));
        end
    end
end

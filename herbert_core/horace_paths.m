classdef horace_paths
    % Helper class, containing information abut main path-es used by Horace
    % Its main properties value return the following path-es:
    %
    % herbert          - path to main Herbert code
    % horace           - path to main Horace code
    % root             - path to folder, which contains all Horace code
    % test_common      - path to test data used by multiple tests
    % test_common_func - path to functions used by multiple tests
    % admin            - path to folder, containing main srcipts to control
    %                    Horace& Herbert code, mainly used in installation and
    %                    building Horace
    % test             - path to folder with all init tests
    % low_level        - path to folder with C++ code
    % bm               - path to benchmarking code
    % bm_common        - path to benchmarking data
    % bm_common_func   - math to common function used by all benchmarging tests

    properties(Dependent)
        herbert  % path to main Herbert code
        horace   % path to main Horace code
        root     % path to folder, which contains all Horace code
        test_common % path to test data used by multiple tests
        test_common_func % path to functions used by multiple tests
        admin    % path to folder, containing main srcipts to control Horace& Herbert code
        test     % path to folder with all init tests
        low_level % path to folder with C++ code
        bm        % path to benchmarking code
        bm_common % path to benchmarking data
        bm_common_func % math to common function used by all benchmarging tests
    end
    properties(Access=protected)
        herbert_path_
        horace_path_
        root_path_
    end


    methods
        function herbert_path = get.herbert(obj)
            herbert_path= obj.herbert_path_;
        end
        function horace_path = get.horace(obj)
            horace_path= obj.horace_path_;
        end
        function root_path = get.root(obj)
            root_path =  obj.root_path_;
        end
        %
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
            persistent path_holder;
            if nargin>0
                if istext(varargin{1})&&strcmp(varargin{1},'clear')
                    path_holder = [];
                    return;
                end
            end
            if isempty(path_holder)
                path_holder = struct();
                path_holder.herbert_path_ = horace_paths.get_folder('herbert_init');
                path_holder.horace_path_  = horace_paths.get_folder('horace_init');
                path_holder.root_path_    = fileparts(path_holder.horace_path_);
            end
            obj.herbert_path_ =  path_holder.herbert_path_;
            obj.horace_path_  =  path_holder.horace_path_;
            obj.root_path_    =  path_holder.root_path_;
        end
    end

    methods(Static)
        function folder = get_folder(function_or_class)
            folder = fileparts(which(function_or_class));
        end

        function clear()
            horace_paths('clear');
        end
    end
end

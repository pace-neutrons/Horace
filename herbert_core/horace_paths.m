classdef horace_paths

    properties(Dependent)
        herbert
        horace
        root
        test_common
        test_common_func
        admin
        test
        low_level
        bm
        bm_common
    end

    methods

        function herbert_path = get.herbert(obj)
            global herbert_path
            if ~exist('herbert_path', 'var') || isempty(herbert_path)

                herbert_path = obj.get_folder('herbert_init');
            end
        end

        function horace_path = get.horace(obj)
            global horace_path
            if ~exist('horace_path', 'var') || isempty(horace_path)

                horace_path = obj.get_folder('horace_init');
            end
        end

        function root_path = get.root(obj)
            global root_path
            if ~exist('root_path', 'var') || isempty(root_path)
                root_path = fileparts(obj.get_folder('horace_init'));
            end
        end

        function path = get.admin(obj)
            path = fullfile(obj.root, 'admin');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find admin path, possibly failed setup')
            end
        end

        function path = get.low_level(obj)
            path = fullfile(obj.root, '_LowLevelCode');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find low level code path, possibly failed setup')
            end
        end

        function path = get.test(obj)
            path = fullfile(obj.root, '_test');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find test path, possible failed setup')
            end
        end

        function path = get.test_common(obj)
            path = fullfile(obj.test, 'common_data');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find test/common_data, possibly failed setup')
            end
        end

        function path = get.test_common_func(obj)
            path = fullfile(obj.test, 'common_functions');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find test/common_functions, possibly failed setup')
            end
        end

        function path = get.bm(obj)
            path = fullfile(obj.root, '_benchmarking');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find benchmarking path, possible failed setup')
            end
        end

        function path = get.bm_common(obj)
            path = fullfile(obj.bm, 'common_data');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find benchmarking/common_data, possibly failed setup')
            end
        end

        function path = get.bm_common_func(obj)
            path = fullfile(obj.bm, 'common_functions');
            if ~is_folder(path)
                warning('HORACE:paths:bad_path', 'Cannot find benchmarking/common_functions, possibly failed setup')
            end
        end

    end

    methods(Static)
        function folder = get_folder(function_or_class)
            folder = fileparts(which(function_or_class));
        end

        function clear()
            clear global herbert_path
            clear global horace_path
            clear global root_path
        end
    end

end

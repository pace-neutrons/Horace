classdef horace_paths

    properties(Dependent)
        herbert
        horace
        root
        test_common
        test_common_func
    end

    methods


        function herbert_path = get.herbert(obj)
            global herbert_path
            if isempty(herbert_path)
                herbert_path = get_folder('herbert_init');
            end
        end

        function horace_path = get.horace(obj)
            global horace_path
            if isempty(horace_path)
                horace_path = get_folder('horace_init');
            end
        end

        function root_path = get.root(obj)
            global root_path
            if isempty(horace_path)
                root_path = fileparts(get_folder('horace_init'));
            end
        end

        function path = get.test_common(obj)
            path = fullfile(obj.root, '_test', 'common_data')
        end

        function path = get.test_common_func(obj)
            path = fullfile(obj.root, '_test', 'common_functions')
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

classdef test_paths < TestCase

    properties
        paths
    end

    methods

        function obj=test_paths(name)
            if nargin<1
                name = 'test_paths';
            end
            obj = obj@TestCase(name);
            obj.paths = horace_paths;
        end

        function obj = test_clear(obj)
            % Backup paths
            herbert = obj.paths.herbert;
            horace = obj.paths.horace;
            root = obj.paths.root;
            clobj = onCleanup(@() reset_paths(herbert, horace, root));
            global herbert_path
            global horace_path
            global root_path
            obj.paths.clear();
            assertTrue(~exist('herbert_path', 'var'));
            assertTrue(~exist('horace_path', 'var'));
            assertTrue(~exist('root_path', 'var'));
        end

        function obj = test_clear_recovery(obj)
            % Backup paths
            herbert = obj.paths.herbert;
            horace = obj.paths.horace;
            root = obj.paths.root;
            clobj = onCleanup(@() reset_paths(herbert, horace, root));
            obj.paths.clear();
            assertEqual(obj.paths.herbert, herbert);
            assertEqual(obj.paths.horace, horace);
            assertEqual(obj.paths.root, root);
        end

        function obj = test_roots_same(obj)
            herbert_root = fileparts(obj.paths.herbert);
            horace_root = fileparts(obj.paths.horace);
            assertEqual(herbert_root, horace_root);
            assertEqual(obj.paths.root, horace_root);
        end

        function obj = test_get_folder(obj)
            curr_folder = obj.paths.get_folder('test_paths');
            assertEqual(pwd(), curr_folder);
        end

        function obj = test_test_path(obj)
            assertEqual(obj.paths.test, fileparts(fileparts(mfilename('fullpath'))));
        end

    end

end

function reset_paths(her, hor, root)
    global herbert_path
    global horace_path
    global root_path
    herbert_path = her;
    horace_path = hor;
    root_path = root;
end

classdef test_paths < TestCase
    % Test horace_paths
    properties
        paths
    end
    
    methods
        
        function obj=test_paths(name)
            if nargin<1
                name = 'test_paths';
            end
            obj = obj@TestCase(name);
            obj.paths = horace_paths();
        end
               
        function obj = test_roots_same(obj)
            % Test that the main Horace and Herbert folders are both in the root
            % folder
            herbert_root = fileparts(obj.paths.herbert);
            horace_root = fileparts(obj.paths.horace);
            assertEqual(herbert_root, horace_root);
            assertEqual(obj.paths.root, horace_root);
        end
        
        function obj = test_test_path(obj)
            % Test that the test path is the same as the location of this test
            assertEqual(obj.paths.test, fileparts(fileparts(mfilename('fullpath'))));
        end
        
    end    
end

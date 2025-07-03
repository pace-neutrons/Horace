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
            obj.paths = horace_paths();
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

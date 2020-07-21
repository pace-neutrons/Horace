classdef test_resolve_path_userpath< TestCase
    properties
    end
    methods
        function obj=test_resolve_path_userpath(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_options_resolve_local(~)
            this_test = 'test_resolve_path_userpath.m';
            expected = [mfilename('fullpath'),'.m'];
            
            actual = resolve_path(this_test);
            
            assertEqual(actual, expected);
            
        end
        
        
        function test_options_resolve_substr(~)
            this_test = fileparts(mfilename('fullpath'));
            
            one_up = fileparts(this_test);
            actual = resolve_path([this_test, filesep, '..']);
            
            assertEqual(actual, one_up);
            
        end
        function test_resolve_home_dir(~)
            if ~isunix
                return;                
            end
            
            expected = getuserdir();
            actual = resolve_path('~');
            if ~strcmp(expected,actual) % resolve simulink, referred by expected
                file = java.io.File(expected);
                expected = char(file.getCanonicalPath());
            end
            assertEqual(expected, actual, [' non-equal dirs: ',expected, ' and ', actual]);
        end

        
    end
end


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
        
        function test_options_resolve_substr(~)
            this_test = fileparts(mfilename('fullpath'));
            
            one_up = fileparts(this_test);
            
            assertEqual(resolve_path([this_test,filesep,'..']),one_up);
            
        end
        function test_resolve_home(~)
            if ~isunix
                return;                
            end
            
            home = getuserdir();
            home2 = resolve_path('~');
            
        end

        
    end
end


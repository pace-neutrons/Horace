classdef exposed_object_lookup < object_lookup
    % Class to expose protected methods of object_lookup that in turn access
    % private methods and functions obj object_lookup for the purpose of testing
    
    methods
        function obj = exposed_object_lookup()
            obj@object_lookup()
        end
    end
    
    methods (Static)
        function [ind, ielmts, func, args, split] = parse_eval_method (varargin)
            [ind, ielmts, func, args, split] = test_parse_eval_method ...
                (object_lookup(), varargin{:});
        end
        
        function split = parse_split (varargin)
            split = test_parse_split (object_lookup(), varargin{:});
        end
    end
    
end

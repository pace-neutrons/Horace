classdef testclass_for_test_gateway
    % Class to provide some simple functionality to test the functions
    % that act as gateways to functions in a class definition folder, or
    % files that define functions or methods in the private folder of a
    % class definition folder
    
    properties
        name
        age
    end
    
    methods
        function obj = testclass_for_test_gateway (name, age)
            % testclass_for_test_gateway constructor
            %
            %   >> obj = testclass_for_test_gateway (name, age)
            
            if ischar(name)
                obj.name = name;
            else
                error ('name must be a character array')
            end
            if isnumeric(age)
                obj.age = age;
            else
                error ('age must be numeric')
            end
        end
        
        function [b1, b2, b3] = method_internal_2in_3out (obj, a1, a2)
            b1 = sin(obj.age) + cos(10*a1);
            b2 = cos(3+obj.age) + 10*sin(a2);
            b3 = exp(obj.age + (a1+a2)/10);
        end
    end
    
    %----------------------------------------------------------------------
    % Accessor methods to reach the test functions in the classdef folder
    % and the /private folder, and test method in /private.
    %
    % These have very specific number of input and output arguments. The
    % reason for in general using generic gateway methods below is that
    % they allow for complete flexibility in the number of I/O
    % arguments e.g. when there are optional arguments.
    
    methods
        function [b1, b2] = method_private_1in_2out_accessor (obj, a1)
            % Accessor method to method in /private called
            % method_private_1in_2out
            [b1, b2] = method_private_1in_2out (obj, a1);
        end
    end
       
    methods(Static)
        function [b1, b2] = function_3in_2out_accessor (a1, a2, a3)
            % Accessor method to function (NOT a method) called
            % function_3in_2out
            [b1, b2] = function_3in_2out (a1, a2, a3);
        end
        
        function [b1, b2] = function_private_1in_2out_accessor (a1)
            % Accessor method to function (NOT a method) in /private called
            % function_private_1in_2out
            [b1, b2] = function_private_1in_2out (a1);
        end
        
    end
    
    %======================================================================
    methods(Static)
        function varargout = test_gateway (func_name, varargin)
            % Access functions in the /private folder for testing purposes
            varargout = cell(1, nargout);
            [varargout{:}] = test_gateway_to_private_folder (func_name, varargin{:});
        end
    end
    
    %======================================================================
end

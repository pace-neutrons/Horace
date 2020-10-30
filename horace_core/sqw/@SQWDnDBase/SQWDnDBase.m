classdef (Abstract) SQWDnDBase
    %SQWDnDBase Abstract SQW/DnD object base class
    %   Abstract class defining common API and atrributes of the SQW and 
    %   DnD objects
    
    properties (Abstract) % Public
       AbsProp
    end
    
    properties (Access = ?SQWDnDBase)  % Protected members
        Property1
    end
    
    methods (Abstract)
       abstMethod(obj)
    end
    
    methods  % Public
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
    
    methods (Access = ?SQWDnDBase)  % Protected members
        w = binary_op_manager (w1, w2, binary_op)
        w = unary_op_manager (w1, unary_op)
        
        function obj = untitled(inputArg1,inputArg2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
    end    
end


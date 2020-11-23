classdef (Abstract)  DnDBase < SQWDnDBase
    % DnDBase Abstract base class for n-dimensional DnD object

    properties
        Property1
    end

    methods(Abstract)

    end

    methods
        function obj = DnDBase(varargin)
            obj = obj@SQWDnDBase(varargin{:});

        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end


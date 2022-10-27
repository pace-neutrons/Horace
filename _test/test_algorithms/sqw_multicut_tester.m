classdef sqw_multicut_tester < sqw
    % helper class used to test cut operations on multiple files or
    % multiple sqw objects
    properties

    end

    methods
        function obj = sqw_multicut_tester(varargin)
            obj = obj@sqw(varargin{:});
        end

        function  wout = cut(obj, varargin)
            % overloaded cut
            wout = obj;
        end
    end
end
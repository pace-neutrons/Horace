classdef sqw_tester<sqw
    % the class to test protected methods of sqw class.
    properties
    end

    methods
        function obj = sqw_tester(varargin)
            obj = obj@sqw(varargin{:});
        end

        function [proj, pbin]= get_proj_and_pbin_public(obj)
            % Expose protected method get_proj_and_pbin()
            [proj, pbin] = obj.get_proj_and_pbin();
        end
    end
end
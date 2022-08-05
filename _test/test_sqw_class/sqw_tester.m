classdef sqw_tester<sqw
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
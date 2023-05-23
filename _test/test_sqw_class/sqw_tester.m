classdef sqw_tester < sqw
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

    methods(Static)

        % Sym is last here to avoid conflicting with old API
        function [proj, pbin, opt, sym] = process_and_validate_cut_inputs_public(...
                data, return_cut, varargin)
            [proj, pbin, sym, opt] = ...
                SQWDnDBase.process_and_validate_cut_inputs(data, return_cut, varargin{:});
        end

    end
end

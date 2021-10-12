classdef cut_sqw_tester < sqw
    % The class used for testing cut_sqw input parameters
    
    methods
        function obj = cut_sqw_tester(varargin)
            obj@sqw(varargin{:});
        end
        
        function [proj, pbin, opt] = cut_inputs_tester(obj,varargin)
            % method to expose protected parser for cut parameters
            %
            [proj, pbin, opt] = obj.process_and_validate_cut_inputs(...
                return_cut, ndims, varargin{:});
        end
    end
end


classdef cut_sqw_tester < sqw
    % The class used for testing cut_sqw input parameters
    
    properties
    end
    
    methods
        function obj = cut_sqw_tester(varargin)
            if isa(varargin{1},'sqw')
                inputs = {varargin{1}.to_struct()};
            else
                inputs = varargin;
            end
            obj=obj@sqw(inputs{:});
        end
        
        function [proj, pbin, opt] = cut_inputs_tester(obj,return_cut,ndims,varargin)
            % method to expose protected parser for cut parameters
            %
            [proj, pbin, opt] = obj.process_and_validate_cut_inputs(...
                return_cut, ndims, varargin{:});            
        end
    end
end


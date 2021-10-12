classdef cut_sqw_tester < sqw
    % The class used for testing cut_sqw input parameters
    
    properties
        fake_property;
    end
    
    methods
        function obj = cut_sqw_tester(varargin)
            obj=obj@sqw(varargin{:});
            % bug in Matlab definition?   I need to define something for
            % subclass
            %obj.fake_property= true;
        end
        
        function [proj, pbin, opt] = cut_inputs_tester(obj,return_cut,ndims,varargin)
            % method to expose protected parser for cut parameters
            %
            [proj, pbin, opt] = obj.process_and_validate_cut_inputs(...
                return_cut, ndims, varargin{:});            
        end
    end
end


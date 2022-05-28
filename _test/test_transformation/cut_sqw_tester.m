classdef cut_sqw_tester < sqw
    % The class used for testing cut_sqw input parameters
    
    properties
    end
    
    methods
        function obj = cut_sqw_tester(varargin)
            if nargin == 0
                inputs = {};
            elseif isa(varargin{1},'sqw')
                inputs = varargin{1}.to_struct();
                inputs.serial_name = 'cut_sqw_tester';
                inputs = {inputs};
            else
                inputs = varargin;
            end
            obj=obj@sqw(inputs{:});
        end
        
        function [proj, pbin, opt] = cut_inputs_tester(obj,return_cut,varargin)
            % method to expose protected cut parameters parser for unit
            % tests.
            %
            [proj, pbin, opt] = obj.process_and_validate_cut_inputs(...
                return_cut, varargin{:});
        end
    end
end


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

        function [proj, pbin, opt, sym] = cut_inputs_tester(obj,return_cut,varargin)
            % method to expose protected cut parameters parser for unit
            % tests.
            %
            % Sym as final output to not affect old API
            [proj, pbin, sym, opt] = SQWDnDBase.process_and_validate_cut_inputs(...
                obj.data,return_cut, varargin{:});
        end
    end
end

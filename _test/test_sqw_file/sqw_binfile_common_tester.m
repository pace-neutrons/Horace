classdef sqw_binfile_common_tester < sqw_binfile_common
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
         % initialize the loader, to be ready to read or write the data
        function obj = init(obj,varargin)
            error('SQW_BINFILE_COMMON_TESTER:not_implemented','init not implemented')
        end
        function obj = set_data_type(obj,val)
            obj.data_type_ = val;
        end
        function [bls,varargout] = get_cblock_sizes(obj,varargin)
            [bls,varargout] = obj.calc_cblock_sizes(varargin{:});
        end

        
    end
    
end


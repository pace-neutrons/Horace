classdef sqw_binfile_common_tester < sqw_binfile_common
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [ok,obj]=should_load(obj,version_structure,fid)
            error('SQW_BINFILE_COMMON_TESTER:not_implemented','should_load not implemented')
        end
        % initialize the loader, to be ready to read or write the data
        function obj = init(obj,varargin)
            error('SQW_BINFILE_COMMON_TESTER:not_implemented','init not implemented')
        end
        
    end
    
end


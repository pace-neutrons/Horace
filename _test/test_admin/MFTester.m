classdef MFTester<MessagesFramework
    methods
        function obj=MFTester(varargin)
            obj= obj@MessagesFramework(varargin{:});
        end
        function mess_fname = job_stat_fname(obj,job_id,mess_name)
            mess_fname  = obj.job_stat_fname_(job_id,mess_name);            
        end
        
    end
end
classdef test_progress_slurm< check_progress_common_methods
    % Helper class to test herbert cluster progress
    %
    methods
        %
        function obj=test_progress_slurm(varargin)
            ci = ClusterSlurmStateTester();
            
            obj = obj@check_progress_common_methods(ci,varargin{:});
            if isempty(which('cpp_communicator'))
                obj.test_disabled = true;
                skipTest('test_progress_slurm disabled as CPPcommunicator is not available');
            end
            
        end
        %
    end
end

classdef test_progress_mpiexec< check_progress_common_methods
    % Helper class to test herbert cluster progress
    %
    methods
        %
        function obj=test_progress_mpiexec(varargin)
            ci = ClusterMPIEXECStateTester();
            
            obj = obj@check_progress_common_methods(ci,varargin{:});
            if isempty(which('cpp_communicator'))
                obj.test_disabled = true;
                skipTest('test_progress_mpiexec disabled as CPPcommunicator is not available');
            end
            
        end
        %
    end
end

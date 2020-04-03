classdef test_job_dispatcher_mpiexec < job_dispatcher_common_tests
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_job_dispatcher_mpiexec(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_herbert';
            end
            this = this@job_dispatcher_common_tests(name,'mpiexec_mpi');
        end
        %
        function test_job_fail_restart(obj, varargin)
            % DISABLED on Windows
            if ispc
                warning('test_job_with_logs_3workers disabled on Windows')
                return;
            end
            test_job_fail_restart@job_dispatcher_common_tests(obj, varargin{:})
        end
        function test_job_with_logs_3workers(obj, varargin)
            test_job_with_logs_3workers@job_dispatcher_common_tests(obj, varargin{:})
        end
        
    end
end

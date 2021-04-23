classdef FakeJenkins4Tests < handle
    % The class used to set up and clear fake jenkins to test changes,
    % deployed on Jenkins locally
    
    properties(Dependent)
        is_jenkins ;
    end
    properties(Constant)
        jenkins_var_list = {'JENKINS_URL','JOB_URL',...;
            'JENKINS_HOME','JOB_NAME','WORKSPACE'};
    end
    
    methods
        function clear_jenkins_var(obj)
            % removes Jenkins variables from the workspace
            cellfun(@(var_name)(setenv(var_name)),obj.jenkins_var_list);
        end
        
        function set_up_fake_jenkins(obj,ws_name)
            % set up fake Jenkins configuration, for is_jenkins routine
            % returning true.
            % ws_name -- if present, fake jenkins workspace name (without
            % path)
            if nargin<2
                ws_name = 'fake_jenkins_for_tests';
            end
            fake_inputs = {'http://some_url','http://some_job_url',...
                tmp_dir(),'JOB_NAME_test_jenkins_fm',...
                fullfile(tmp_dir,ws_name)};
            
            cellfun(@(var_name,val)(setenv(var_name,val)),...
                obj.jenkins_var_list,fake_inputs);
        end
        function is = get.is_jenkins(~)
            is = is_jenkins();
        end
    end
end


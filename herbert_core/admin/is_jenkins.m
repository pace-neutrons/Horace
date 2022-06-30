function [is_jenkins_pc,job_name,workspace] = is_jenkins()
% Attempt to determine if the PC we're running on is a Jenkins server.
%   This is detected through environment variables that are always set by
%   Jenkins.
%
% Returns:
% is_jenkins -- true if the program is running on Jenkins
% job_name   -- the value of the Jenkins variable "JOB_NAME",
% workspace  -- the Jenkins workspace directory

    jenkins_env_vars = {'JENKINS_URL', 'JOB_URL', 'JENKINS_HOME', 'JOB_NAME', 'WORKSPACE'};
    job_name = '';
    workspace = '';
    is_jenkins_pc = all(cellfun(@(x)(~isempty(getenv(x))), jenkins_env_vars));
    if is_jenkins_pc
        job_name = getenv('JOB_NAME');
        workspace = getenv('WORKSPACE');
    end
end

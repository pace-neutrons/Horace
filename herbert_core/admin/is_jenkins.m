function [is_jenkins_pc,job_name] = is_jenkins()
% Attempt to determine if the PC we're running on is a Jenkins server.
%   This is detected through environment variables that are always set by
%   Jenkins.
%
% Returns:
% is_jenkins -- true if the progam is running on Jenkins
% job_name   -- the value of the Jenkins variable "JOB_NAME", 
jenkins_env_vars = {'JENKINS_URL', 'JOB_URL', 'JENKINS_HOME'};
job_name ='';

for i = 1:length(jenkins_env_vars)
    if isempty(getenv(jenkins_env_vars{i}))
        is_jenkins_pc = false;
        return;
    end
end
is_jenkins_pc = true;

if nargout > 1
    job_name = getenv('JOB_NAME');
end

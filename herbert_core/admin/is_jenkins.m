function [is_jenkins_pc] = is_jenkins()
% Attempt to determine if the PC we're running on is a Jenkins server.
%   This is detected through environment variables that are always set by
%   Jenkins.

jenkins_env_vars = {'JENKINS_URL', 'JOB_URL', 'JENKINS_HOME'};

for i = 1:length(jenkins_env_vars)
    if isempty(getenv(jenkins_env_vars{i}))
        is_jenkins_pc = false;
        return;
    end
end
is_jenkins_pc = true;

end

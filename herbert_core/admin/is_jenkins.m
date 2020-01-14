function [is_jenkins_pc] = is_jenkins()
% Attempt to determine if the PC we're running on is a Jenkins server.
%   This is detected through environment variables that are always set by
%   Jenkins.

jenkins_env_vars = ['JENKINS_URL', 'JOB_URL', 'JENKINS_HOME'];

[~, out] = system('env');
vars = regexp(strtrim(out), '^(.*)=(.*)$', ...
                'tokens', 'lineanchors', 'dotexceptnewline');
vars = vertcat(vars{:});
keys = vars(:,1);
vals = vars(:,2);
[keys,ord] = sort(keys);
vals = vals(ord);
for i = 1:length(vals)
    key = keys(i);
    val = vals(i);
    fprintf('%s:\n    %s\n', key{1}, val{1});
end

for i = 1:length(jenkins_env_vars)
    env_var = getenv(jenkins_env_vars(i))
    if isempty(getenv(jenkins_env_vars(i)))
        is_jenkins_pc = false;
        return;
    end
end
is_jenkins_pc = true;

end

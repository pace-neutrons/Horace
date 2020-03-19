function [physical, logical] = get_num_cores()
% Get the number of physical and logical cores on the system
%
% Output:
% -------
%   physical      The number of physical cores on this PC
%   logical       The number of logical cores on this PC
%
core_info = evalc('feature(''numcores'')');
match_str = 'MATLAB detected: ([0-9]+) %s cores';

[match, ~] = regexp(core_info, sprintf(match_str, 'physical'), 'tokens', 'match');
physical = str2double(match{1});

[match, ~] = regexp(core_info, sprintf(match_str, 'logical'), 'tokens', 'match');
logical = str2double(match{1});

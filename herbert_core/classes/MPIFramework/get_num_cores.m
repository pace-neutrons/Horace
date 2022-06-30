function [physical_cores, logical_cores] = get_num_cores()
% Get the number of physical and logical cores on the system
%
% Output:
% -------
%   physical_cores      The number of physical cores on this PC
%   logical_cores       The number of logical cores on this PC
%
physical_cores = get_cores('physical');
logical_cores = get_cores('logical');


function num_cores = get_cores(core_type)
    core_info = evalc('feature(''numcores'')');
    match_str = 'MATLAB detected: ([0-9]+) %s cores';
    [match, ~] = regexp(core_info, sprintf(match_str, core_type), 'tokens', ...
                        'match');
    num_cores = str2double(match{1});

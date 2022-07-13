function dump_profile(prof, filename)

% Dump profile dumps a profile to a simply parsable raw text file.
% The interface is designed to mimic that of the MATLAB internal "profsave"
%
% When given a MATLAB profiler statistics structure (as returned from profile('info'),
% it extracts the properties defined in extract (currently constant) and
% dumps them as a MATLAB table (cast to string) to the file "filename"
%
% It also calculates the percentage time, and the percentage self-time for the
% profile.
%
% Usage:
%
%   >> dump_profile(p, 'my_dump');
%
% J. Wilkins April 2022

    extract = {'FunctionName' 'NumCalls' 'TotalTime' 'TotalMemAllocated' 'TotalMemFreed' 'PeakMem'};

    ft = prof.FunctionTable;

    maxTime = max([ft.TotalTime]);

    fn = fieldnames(ft);
    sd = setdiff(fn, extract);
    m = rmfield(ft, sd);

    percent = arrayfun(@(x) 100*x.TotalTime/maxTime, m, 'UniformOutput', false);
    [m.PercentageTime] = percent{:};
    sp_time = arrayfun(@(x) sum([x.Children.TotalTime]), ft);
    self_time = arrayfun(@(x,y) x-y, [ft.TotalTime]', sp_time, 'UniformOutput', false);
    [m.SelfTime] = self_time{:};
    percent = arrayfun(@(x) 100*x.SelfTime/maxTime, m, 'UniformOutput', false);
    [m.SelfPercentageTime] = percent{:};

%     dataStr = evalc('struct2table(m)');
    writetable(struct2table(m),filename);

%     % Remove HTML, braces and header
%     dataStr = regexprep(dataStr, '<.*?>', '');
%     dataStr = regexprep(dataStr, '[{}]', ' ');
%     dataStr = dataStr(24:end);
% 
%     fh = fopen(filename, 'w');
%     fwrite(fh, dataStr);
%     fclose(fh);
end

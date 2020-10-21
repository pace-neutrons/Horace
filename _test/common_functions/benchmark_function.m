function ftimes = benchmark_function(fhandle, niters, nrepititions)
%% BENCHMARK_FUNCTION time the given function handle
% The function will be run `niters` times between the timing points and
% `nrepititions` times will be generated.
%
% Input:
% ------
% fhandle     The function handle to benchmark.
%
% niters      The number of times to run the function between time points.
%
% nrepitions  The number of times to repeat the benchmark, this differs from
%             niters in that each repitition has its own time. In affect, the
%             function `fhandle` is run niters*nrepititions times.
%
% Output:
% -------
% ftimes   A list of the times taken to run the given function.
%          size(ftimes) = [1, nprepetitions].
%
ftimes = zeros(1, nrepititions);
for rep = 1:nrepititions
    tic;
    for iter = 1:niters
        fhandle();
    end
    ftimes(rep) = toc/niters;
end

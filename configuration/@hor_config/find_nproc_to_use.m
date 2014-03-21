function n_processors = find_nproc_to_use(this)


Matlab_Version=matlab_version_num();
% Configure memory
% ----------------
% Should be able to estimate the memory that can be used?


% Configure the number of threads
% -------------------------------
% let's try to identify the number of processors to use in OMP
n_processors = getenv('OMP_NUM_THREADS');
if(isempty(n_processors))
    % *** > this have to be modified in a future to work on UNIX with Matlab higher than 7.10
    n_processors=1;  % not good for linux
else
    n_processors=str2double(n_processors);
end
% Matlab below should know better how many threads to use in calculations
if(Matlab_Version>7.07&&Matlab_Version<7.11) % Matlab supports settings of the threads from command line
    s=warning('off','MATLAB:maxNumCompThreads:Deprecated');
    n_processors = maxNumCompThreads();
    warning(s.state,'MATLAB:maxNumCompThreads:Deprecated');
end
% OMP in C++ does not scale well with higher number of CPU
% or at least has not been tested against it. Lets set it to 4
% *** > but have to modify if changed to extremly large datasets in memory or
%  much bigger amount of calculations in comparison with IO operations,
% *** > optimisation is possible.
if n_processors>8
    n_processors=8;
end

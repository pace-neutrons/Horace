function cache(filename)
% function loads a sqw file in a cache of a parallel file system
% Input:
% filename -- the name of the sqw file to cache
%
% if appropriate file system is present (e.g. ISIS CEPS filesystem on isiscompute),
% the function substantially (almost tenfold) improves access time to
% the sqw file.
%
% function provides wrapper around python program cache.py, which
% is executed in a separate process.
% Its recommended to use this python program without the Matlab wrapper,
% to have full information and control over the caching process.
%
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
%
if ~isunix
    warning('CACHE:invalid_os',...
        'This function is benefitial only when used on an appropriate Unix system. Exiting')
    return;
end
if ~exist(filename,'file')
    error('CACHE:invalid_argument',...
        ' File %s does not exist',filename);
end
script_location = fileparts(mfilename('fullpath'));
disp('******************************************************************************************');
disp(['*** Launching caching script "cache.py" located in the folder: ',script_location]);
disp('*** To benefit from the acceleration, wait for 1-5 minutes until the caching finishes. ***');
disp('*** Run "top" command in a terminal to observe the Python processes, caching the file. ***');
disp('*** Wait for these processes to exit to be sure that the caching process is completed. ***');
disp('*** Its recommended to execute the "cache.py" script directly in a terminal,           ***');
disp('*** to observe the progress of the caching.                                            ***');
disp('******************************************************************************************');

system(sprintf('python %s %s &',fullfile(script_location,'cache.py'),filename),'-echo');
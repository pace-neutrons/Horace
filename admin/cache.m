function cache(filename)
% function loads a sqw file in a cache of a parallel file system
% Input:
% filename -- the name of the sqw file to cache
%
% if appropriate file system is present (e.g. ISIS CEPS filesystem on isiscompute),
% the function substantially (almost tenfold) improves access time to
% the sqw file.
%
% function provides wrapper around python program with the same name, which
% is started in a separate process.
%
%
%
% $Revision: 347 $ ($Date: 2018-10-30 17:52:52 +0000 (Tue, 30 Oct 2018) $)
%
if ~isunix
    warning('CACHE:invalid_os',...
        'This function should be only used on an appropriate Unix system. Exiting')
    return;
end
if ~exist(filename,'file')
    error('CACHE:invalid_argument',...
        ' File %s does not exist',filename);
end
script_location = fileparts(mfilename('fullpath'));
disp('*****************************************************************************************');
disp(['*** Launching caching script "cache.py" located in the folder: ',script_location]);
disp('*** To benefit from the acceleration, wait for 1-5 minutes until the caching finishes.***');
disp('*** Run top command in a terminal to observe python processes, caching the file.      ***');
disp('*** Wait for these processes to exit to know that the caching process is completed.   ***');
disp('*** Its recommended to execute the "cache.py" script directly in a terminal,          ***');
disp('*** to observe the progress of the caching.                                           ***');
disp('*****************************************************************************************');

system(sprintf('python %s %s &',fullfile(script_location,'cache.py'),filename),'-echo');
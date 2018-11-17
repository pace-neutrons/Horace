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

if ~isunix
    warning('CACHE:invalid_os',...
        'This function should be only used on appropriate Unix system. Exiting')
    return;
end
if ~exist(filename,'file')
    error('CACHE:invalid_argument',...
        ' File %s does not exist',filename);
end
script_location = fileparts(mfilename('fullpath'));
disp('****************************************************************')
disp(['*** Starting caching script "cache.py" locating in the folder: ',script_location]);
disp('*** To see the acceleratiom, wait for 2-5 minutes until the caching finishes before starting cutting it.');
disp('*** Its better to execute caching program in a separate terminal as it reports progress while running there');
disp('****************************************************************')

system(sprintf('python %s %s &',fullfile(script_location,'cache.py'),filename),'-echo')
function start_app (app_name,opt,varargin)
% Startup a named application with given root directory, or turn off an application
%
%   >> start_app (app_name, rootpath)                   % start application located in rootpath
%   >> start_app (app_name, rootpath, arg1, arg2, ...)  % start application-specific options
%   >> start_app (app_name, '-off')                     % remove application
%
% Place this function (i.e. start_app) in a directory on your matlab path.
%
% EXAMPLE
% To set up libisis, located in root directory c:\mprogs\libisis, type (or add to
% your startup.m):
%   >> start_app ('libisis','c:\mprogs\libisis')
%
% To turn the application off:
%   >> start_app ('libisis', '-off')
%
% Notes:
% ------
% This routine assumes the existence of initialisation 'init' and 'off' functions in the root
% directory of the application. For example, if the application is called 'my_app'
% then if is assumed that the root directory for that application will contain the functions
%
%   my_app_init.m       % application specific function that sets the paths and any other initialisation
%   my_app_off.m        % application specific function to turn off the program
%
% If my_program_init accepts other arguments, arg1, arg2,... to be passed to it,
% then this can be done by passing them through start_app
%
%   >> start_app ('mgenie', 'c:\mprogs', p1, p2, ...)
%
% The purpose of start_app is to make starting up and turning off an application easier, and
% to enable greater control in testing multiple versions of a given application. In particular,
% start_app(<name>,'-off') will turn off all instances of a given application


% Check application name argument exists
if exist('app_name','var')
    if ~isvarname(app_name)
        error ('First argument must be a valid name - no action taken.');
    end
else
    error('Must give application name')
end

% Get root directory or other option
if exist('opt','var')  % Check that the rootpath exists
    if ischar(opt) && size(opt,1)==1
        if strncmpi(opt,'-off',max(length(opt),2))
            initialise_application=false;
        elseif exist(opt,'dir')==7
            initialise_application=true;
            rootpath = opt;
        else
            error('''%s'' is not a valid directory or option - no action taken.',opt);
        end
    else
        error('First argument must be a valid directory or option - no action taken.');
    end
else    % use the current working directory if none given
    initialise_application=true;
    rootpath = pwd;
end

% Turn off any instances of application
application_off (app_name)

% Initialise particular instance of application, if requested
if initialise_application
    [ok,mess]=application_init (app_name, rootpath, varargin{:});
    if ~isempty(mess)
        if ok
            warning(mess)
        else
            error(mess)
        end
    end
end

%=========================================================================================================
function [ok,mess]=application_init(app_name,rootpath,varargin)
% Initialisation of application

start_dir=pwd;
try
    ok=true; mess='';
    cd(rootpath)
    % Check that the required initialisation function exists in rootpath
    if exist(fullfile(pwd,[app_name,'_init.m']),'file')
            try
                feval([app_name,'_init'],varargin{:})    % call initialisation routine
            catch
                message=lasterr;
                ok=false; mess=['Unable to run function ',fullfile(pwd,[app_name,'_init.m']),'. Reason: ',message];
            end
    else
        ok=true; mess=['Initialisation function ',app_name,'_init.m not found in directory ',rootpath,' - application not initialised'];
    end
    cd(start_dir)
catch
    cd(start_dir)
    message=lasterr;
    ok=false;
    mess=['Problems initialising ',app_name,'. Reason: ',message];
end

%=========================================================================================================
function application_off(app_name)
% Remove paths to all instances of the application.

start_dir=pwd;

% Determine the rootpaths of any instances of the application by looking for app_name on the matlab path
application_init_old = which([app_name,'_init'],'-all');

for i=1:numel(application_init_old)
    try
        rootpath=fileparts(application_init_old{i});
        cd(rootpath)
        if exist(fullfile(pwd,[app_name,'_off.m']),'file') % check that 'off' routine exists in the particular rootpath
            try
                feval([app_name,'_off'])    % call the 'off' routine
            catch
                message=lasterr;
                disp(['Unable to run function ',fullfile(pwd,[app_name,'_off.m']),'. Reason: ',message]);
            end
        else
            disp(['Function ',app_name,'_off.m not found in ',rootpath])
            disp('Clearing rootpath and subdirectories from matlab path in any case')
        end
        paths = genpath(rootpath);
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
        rmpath(paths);
        warning(warn_state);    % return warnings to initial state
        cd(start_dir)           % return to starting directory
    catch
        cd(start_dir)           % return to starting directory
        message=lasterr;
        disp(['Problems removing ',rootpath,' and any sub-directories from matlab path. Reason: ',message]);
    end
end

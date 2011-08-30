function use_mex(opt_in)
% Set use of mex files or matlab equivalents for testing purposes.
%
%   >> use_mex          % Prints whether mex or matlab functions are currently being used
%   >> use_mex(opt)     % opt='fortran' use mex files
%                       %    ='matlab'  use matlab functions
%                       %    ='ref'     use matlab reference code
%
% Assumes herbert_init has been run
% Should be robust to changes in organisation of files in Herbert

persistent opt

% If no argument, then print out if mex or matlab routines currently in use
if nargin==0
    if isempty(opt)
        disp('Unknown external code option')
    else
        display(['External code option: ',opt])
    end
    return
else
    if isempty(opt_in) || (ischar(opt_in) && size(opt_in,1)==1)
        if isempty(opt_in) || strncmpi(opt_in,'fortran',length(opt_in))
            opt_in='fortran';
        elseif strncmpi(opt_in,'matlab',length(opt_in))
            opt_in='matlab';
        end
    else
        error('Option must be character string')
    end
end

% Make no changes if already pointing to correct location of function
if strcmp(opt,opt_in)
%    display(['Unchanged external code option: ',opt])
    return
end

% Change external code option
rootpath = fileparts(which('herbert_init'));
start_dir=pwd;
try
    cd(rootpath)
    herbert_init(opt_in)
    opt=opt_in;
    cd(start_dir)
%    display(['External code option changed to: ',opt])
catch
    cd(start_dir)
    error('Problem initialising Herbert')
end

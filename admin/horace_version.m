function [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=horace_version()
% the function returns the version of horace, which should correspond to
% the distinctive tag version from the SVN server.
%
% Usage:
% [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=horace_version()
% [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=horace_version('brief')
%
% where application is a structure containing the fields with program name
% (horace)and horace release version.
%
% if horace_version is called with parameter, the function
% returns revision data (Matlab_SVN) as number rather then string
% (convenient for versions comparison)
%
%
% An pre-commit hook script provided as part of the package
% has to be enabled on svn and svn file properies
% (Keywords) Date and Revision should be set on this file
% to support valid Matlab versioning.
%
% The script will modify the data of this file before committing.
% The variable below introduced to allow the commit hook touching this file and
% make this touches available to the svn (may be it is a cumbersome solution, but is
% the best and most portable for any OS I can think of).
%
%
% $COMMIT_COUNTER:: 75 $
%
% No variable below this one should resemble COMMIT_COUNTER, as their values will
% be modified and probably corrupted at commit
% after the counter changed, the svn version row below will be updated
% to the latest svn version at commit.

application.name='horace';

% -------------------------------------------------------------------------
% Version history of sqw file formats
% -------------------------------------------------------------------------
%
% July 2007(?) to Autumn 2008:
% ----------------------------
% Prototype sqw file format.
% Did not store filename, filepath, title, alatt, and angdeg as part of the
% data block. Also, the application name and file format version number
% were not stored.
%
% Autumn 2008 to Feb 2013:
% ------------------------
% Version 1 and 2
% These have the same file format.
%(The version number was being used to distinguish between Horace, not the file formats)
%
% 23 Feb 2013:
% ------------
% Version 3
% Format of sqw file has addition information in an appendix:
% - instrument and sample blocks
% - positions of major data blocks in the file
% - position of data block
% - position of end of data block

application.version=3;

Matlab_SVN='$Revision::      $ ($Date::                                              $)';

% Information about name and version of application
mexMinVer     = [];
mexMaxVer     = [];
date          = [];

use_mex = get(hor_config,'use_mex');
if use_mex
    [mex_messages,n_errors,mexMinVer,mexMaxVer,date,can_use_mex_for_combine]=check_horace_mex();
    if n_errors~= 0
        set(hor_config,'use_mex',0);
    end
    if ~can_use_mex_for_combine
        % it will check the mode and set up "can not user mex" internaly
        set(hor_config,'mex_combine_thread_mode',0);
    end

end
hd     =str2double(Matlab_SVN(12:17));

application.svn_version=hd;
application.mex_min_version = mexMinVer;
application.mex_max_version = mexMaxVer;
application.mex_last_compilation_date=date;
if nargin>0
    Matlab_SVN =application.svn_version;
end

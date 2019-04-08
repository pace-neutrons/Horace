function [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=herbert_version(varargin)
% the function returns the version of herbert, which should correspond to
% the distinctive tag version from the SVN server. 
%
% Usage:
% [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=horace_version()
% [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=horace_version('brief')
% 
% where application is a structure containing the fields with program name
% (Horace)and Horace release version. 
%
% if horace_version is called with parameter, the function
% returns revision data (Matlab_SVN) as number rather then string
% (convenient for versions comparison)
%
%
% An pre-commit hook script provided as part of the package 
% has to be enabled on svn and svn file properties 
% (Keywords) Date and Revision should be set on this file 
% to support valid Matlab versioning.
%
% The script will modify the data of this file before committing. 
% The variable below introduced to allow the commit hook touching this file and 
% make this touches available to the svn (may be it is a cumbersome solution, but is 
% the best and most portable for any OS I can think of). 
%
%
% $COMMIT_COUNTER:: 4 $
%
% No variable below this one should resemble COMMIT_COUNTER, as their values will 
% be modified and probably corrupted at commit
% after the counter changed, the svn version row below will be updated 
% to the latest svn version at commit.

application.name='herbert';


application.version=1;

Matlab_SVN='$Revision:: 830 $ ($Date:: 2019-04-08 15:44:49 +0100 (Mon, 8 Apr 2019) $)';

% % Information about name and version of application
mexMinVer     = 'disabled';
mexMaxVer     = 'disabled';
date          = '01/01/0000';
if get(herbert_config,'use_mex')
     [mex_messages,n_errors,mexMinVer,mexMaxVer,date]=check_herbert_mex();
     if n_errors~= 0
         display(mex_messages);
         set(hor_config,'use_mex',0);
     end
end
hd     =str2double(Matlab_SVN(12:17));


application.svn_version=hd;
application.mex_min_version = mexMinVer;
application.mex_max_version = mexMaxVer;
application.mex_last_compilation_date=date;
if nargin>0    
    Matlab_SVN =sprintf('%d.%d',application.version,application.svn_version);
end



function [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=horace_version(varargin)
% the function returns the version of horace, which should correspond to
% the distinctive tag version from the SVN server. 
%
% An pre-commit hook script has to be enabled to support valid Matlab
% versioning. The script should modify the data of this file before
% committing. 
% The variable below introduced to allow the commit hook touching this file and 
% make this touches available to the svn (may be it is a cumbersome solution, but is 
% the best and most portable I can think in a five minutes time). 
%
% if horace_version is called with parameter, the function
% returns revision data as numbers rather then strings (convenient for version analysis)
%
%
% $COMMIT_COUNTER:: 47 $
%
% No variable below this one should resemble COMMIT_COUNTER, as their values will 
% be modified and probably corrupted at commit
% after the couter changed, the row below will be updated to the latest svn version while committing

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
mexMinVer     ='Not implemented                                         ';
mexMaxVer     = [];
date          = [];
if get(hor_config,'use_mex')
    [mex_messages,n_errors,mexMinVer,mexMaxVer,date]=check_horace_mex('get min-max version');
    if n_errors~= 0
        set(hor_config,'use_mex',0);
    end
end
if nargin>0
    hd     =str2double(Matlab_SVN(12:17));
    Matlab_SVN =hd(1);
end

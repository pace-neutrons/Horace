function [application,svn]=horace_version(opt)
% Returns the version of Horace, which . 
%
%   >> application = horace_version         % fast: no checks of svn information or mex files
%   >> [application,svn] = horace_version                   % full check of mex files
%   >> [application,svn] = horace_version('full')           % same as above
%   >> [application,svn] = horace_version('mex_nocheck')    % don't check mex files
%
% Output:
% -------
%   application Structure with information about Horace version. Fields are:
%                   name    Names of application: 'horace'
%                   version Formal version number e.g. 3.1, which should correspond
%                           to a distinctive tag on the SVN server
%
%   svn         Structure with svn version information. Fields are:
%                   svn_version         Version number e.g. 877
%                   svn_version_str     Full svn version string with version and date
%                   mex_ok              True if all mex files are working file; false otherwise
%                   mex_min_version     Least recent version number of a mex code file
%                                       =[] if ~mex_ok
%                   mex_min_version     Most recent version number of a mex code file
%                                       =[] if ~mex_ok
%                   mex_last_compilation_date   Date of the most recently compiled mex file
%                                       ='' if ~mex_ok
%                   mex_messages        Cell array of strings with information about mex files
%               
%
% Important note from Alex Buts:
% ------------------------------
% A pre-commit hook script provided as part of the package 
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
% $COMMIT_COUNTER:: 58 $
%
% No variable below this one should resemble COMMIT_COUNTER, as their values will 
% be modified and probably corrupted at commit
% after the counter changed, the svn version row below will be updated 
% to the latest svn version at commit.


% -------------------------------------------------------------------------
% Version history of sqw file formats
% -------------------------------------------------------------------------
%
% July 2007(?) to Autumn 2008:
% ----------------------------
% Prototype sqw file format.
%      File format version name: '-prototype'
%    File format version number: 0
%
% Did not store filename, filepath, title, alatt, and angdeg as part of the
% data block. Also, the application name and file format version number
% were not stored.
%
% Autumn 2008 to Feb 2013:
% ------------------------
% Horace versions 1 and 2
%      File format version name: '-v2'
%    File format version number: 2
%
% These have the same file format. The version number stored in the file
% was being used to distinguish between Horace versions, not the file
% formats.
%
% November 2013:
% --------------
% Horace version 3
%      File format version name: '-v3'
%    File format version number: 3
%
% Format of sqw file has addition information in an appendix:
% - instrument and sample blocks
% - positions of major data blocks in the file
% - position of data block
% - position of end of data block
%
% August 2014:
% ------------
% Horace version 3.1
%      File format version name: '-v3.1'
%    File format version number: 3.1
%
% Format of sqw file has the same information as format 3, but the fields
% are stored as float64 in general, apart from s,e,pix
% In addition a new sparse format was introduced for the case of sqw type
% data from a single spe file.
%
% -------------------------------------------------------------------------

application.name='horace';
application.version=3.1;

if nargout>1
    str = '$Revision::      $ ($Date::                                              $)';
    svn.svn_version = str2double(str(12:17));
    svn.svn_version_str = str;
    if nargin==0 || isstring(opt) && strncmpi(opt,'full',numel(opt))
        [mex_messages,n_errors,minVer,maxVer,compilation_date]=check_horace_mex();
        svn.mex_ok=~logical(n_errors);
        svn.mex_min_version=minVer;
        svn.mex_max_version=maxVer;
        svn.mex_last_compilation_date=compilation_date;
        svn.mex_messages=mex_messages;
    elseif isstring(opt) && strncmpi(opt,'mex_no_check',numel(opt))
        svn.mex_ok=false;
        svn.mex_min_version=[];
        svn.mex_max_version=[];
        svn.mex_last_compilation_date='';
        svn.mex_messages={};
    else
        error('Unrecognised optional input argument')
    end
end

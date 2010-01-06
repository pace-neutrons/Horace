function current=horace_version()
% the function returns the version of horace, which should correspond to
% distinctive tag version on the SVN server. 
%
% An pre-commit hook script has to be enabled to support valid Matlab
% versioning. The script should modify the data of this file before
% committing. 
% The variable below introduced to allow the commit hook toughing this file and 
% make this touches available to the svn (may be it is a cumbersome solution, but is 
% the best and most portable I can think in a five minutes time). 
%
%
% $COMMIT_COUNTER:: 18 $
%
% No variable below this one should resemble COMMIT_COUNTER, as their values will 
% be modified and probably corrupted at commit
% after the couter changed, the row below will be updated to the latest svn version while committing
% 
% 
current='$Revision$ ($Date$)';
predefined='3.0.1'
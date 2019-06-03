function obj = set_global_foreground(obj,set_global)
% Specify that there will be a global foreground fit function
%
%   >> obj = obj.set_global_foreground          % set global foreground
%   >> obj = obj.set_global_foreground (status) % set global foreground true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the foreground fit functions and any previously set constraints are
% cleared
%
% See also: set_local_foreground set_local_background set_global_background

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_scope_intro = fullfile(mfclass_doc,'doc_set_scope_intro.m')
%
%   type  = 'fore'
%   scope = 'global'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_scope_intro> <type> <scope>
%
% See also: set_local_foreground set_local_background set_global_background
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


if nargin==1
    set_global = true;
end
isfore = true;
obj = set_scope_private_(obj, isfore, ~set_global);

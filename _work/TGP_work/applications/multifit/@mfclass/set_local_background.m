function obj = set_local_background(obj,set_local)
% Specify that there will be a local background fit function
%
%   >> obj = obj.set_local_background          % set local background
%   >> obj = obj.set_local_background (status) % set local background true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the background fit functions and any previously set constraints are
% cleared
%
% See also: set_global_background set_local_foreground set_global_foreground

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_scope_intro = fullfile(mfclass_doc,'doc_set_scope_intro.m')
%
%   type  = 'back'
%   scope = 'local'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_scope_intro> <type> <scope>
%
% See also: set_global_background set_local_foreground set_global_foreground
% <#doc_end:>
% -----------------------------------------------------------------------------



% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if nargin==1
    set_local = true;
end
isfore = false;
obj = set_scope_private_(obj, isfore, set_local);

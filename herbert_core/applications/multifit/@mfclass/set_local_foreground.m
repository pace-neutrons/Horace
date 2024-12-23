function obj = set_local_foreground(obj,set_local)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_scope_intro = fullfile(mfclass_doc,'doc_set_scope_intro.m')
%
%   type  = 'fore'
%   scope = 'local'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_scope_intro> <type> <scope>
%
% See also: set_local_background set_global_background
% <#doc_end:>
% -----------------------------------------------------------------------------



% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


if nargin==1
    set_local = true;
end
isfore = true;
obj = set_scope_private_(obj, isfore, set_local);


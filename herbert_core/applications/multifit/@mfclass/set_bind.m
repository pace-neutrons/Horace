function obj = set_bind (obj,varargin)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_bind_intro = fullfile(mfclass_doc,'doc_set_bind_intro.m')
%
%   type = 'fore'
%   pre = ''
%   atype = 'back'
%   func = 'set'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
% Set bindings of <type>ground parameters to <type>- &/or <atype>ground parameters
%
%   <#file:> <doc_set_bind_intro> <type> <pre> <atype> <func>
%
%
% See also add_bind set_bbind add_bbind set_fun set_bfun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
% -------------
isfore = true;

% Clear all bindings first
obj = clear_bind_private_ (obj, isfore, {'all'});

% Add new bindings
obj = add_bind_private_ (obj, isfore, varargin);

end

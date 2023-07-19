function obj = set_pin (obj, varargin)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_pin_intro = fullfile(mfclass_doc,'doc_set_pin_intro.m')
%
%   type = 'fore'
%   pre = ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_pin_intro> <type> <pre>
%
%
% See also set_bpin set_fun set_bfun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
isfore = true;
obj = set_pin_private_ (obj, isfore, varargin);

end

function obj = clear_bfree (obj, varargin)
% Free all parameters to vary in fitting for one or more background functions
%
% Free all parameters for all background functions
%   >> obj = obj.clear_bfree
%   >> obj = obj.clear_bfree ('all')
%
% Free all parameters for one or more specific background function(s)
%   >> obj = obj.clear_bfree (ifun)
%
% Input:
% ------
%   ifun    Row vector of background function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_free_intro = fullfile(mfclass_doc,'doc_clear_free_intro.m')
%
%   type = 'back'
%   pre = 'b'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_clear_free_intro> <type> <pre>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


% Process input
isfore = false;
[ok, mess, obj] = clear_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end

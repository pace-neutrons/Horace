function obj = clear_fun(obj, varargin)
% Clear foreground fit function(s), clearing any corresponding constraints
%
% Clear all foreground functions
%   >> obj = obj.clear_fun
%   >> obj = obj.clear_fun ('all')
%
% Clear a particular foreground function or set of foreground functions
%   >> obj = obj.clear_fun (ifun)
%
% Input:
% ------
%   ifun    Row vector of foreground function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_fun_intro = fullfile(mfclass_doc,'doc_clear_fun_intro.m')
%
%   type = 'fore'
%   pre = ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_clear_fun_intro> <type> <pre>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


% Process input
% -------------
isfore = true;
[ok, mess, obj] = clear_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end

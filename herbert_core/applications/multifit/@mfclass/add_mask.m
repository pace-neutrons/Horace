function obj = add_mask(obj,varargin)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_mask_intro = fullfile(mfclass_doc,'doc_set_mask_intro.m')
%
%   func = 'add'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
% Accumulate masking of data points to simulate or fit
%
%   <#file:> <doc_set_mask_intro> <func>
%
%
% See also set_mask clear_mask
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
clear = false;
[ok, mess, obj] = add_mask_private_ (obj, clear,  varargin);
if ~ok, error(mess), end


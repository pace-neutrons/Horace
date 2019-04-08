function obj = add_mask(obj,varargin)
% Accumulate masking of data points to simulate or fit
%
% Mask all currently input data sets: one or more of the keyword-value pairs:
% (keyword-value pairs can appear in any order):
%
%   >> obj = obj.add_mask ('keep', xkeep, 'remove', xremove, 'mask', mask)
%
% Select for one or more particular datasets (ind an integer or integer array):
%   >> obj = obj.add_mask (ind, 'keep', xkeep,...)
%
% Input:
% ------
% Optional selection of datasets to mask:
%   ind         Index of dataset to mask, or array of indicies to mask
%              several datasets.
%               If omitted, the masking applies to all currently input datasets
%
% Optional keyword/value pairs:
%   xkeep       Cell array (row) of keep ranges, one per data set.
%               - General case of n-dimensions:
%                   [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%               - More than one range to keep can be specified in additional rows:
%                   [Range_1; Range_2; Range_3;...; Range_m]
%               where each of the ranges are given in the format above.
%                 e.g.
%                   1D data: [3,5]          % keep 3-5
%                            [3,5; 10,15]   % keep 3-5 and 10-15
%
%                   2D data: [3,5,7,10]     % keep the box x=3-5, y=7-10
%
%              (If xkeep is empty, then it is ignored)
%
%   xremove     Cell array (row) of keep ranges, one per data set.
%               Same syntax as xkeep
%
%   mask        Cell array (row) of mask arrays, one per data set.
%               Same size as data.
%              (If mask is empty, then it is ignored)
%
%
% See also set_mask clear_mask

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
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


% Process input
clear = false;
[ok, mess, obj] = add_mask_private_ (obj, clear,  varargin);
if ~ok, error(mess), end

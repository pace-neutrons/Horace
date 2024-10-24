% Description of function syntax for set_mask and add_mask
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   func = '#1'     % 'set' or 'add'
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Mask all currently input data sets: one or more of the keyword-value pairs:
% (keyword-value pairs can appear in any order):
%
%   >> obj = obj.<func>_mask ('keep', xkeep, 'remove', xremove, 'mask', mask)
%
% Select for one or more particular datasets (ind an integer or integer array):
%   >> obj = obj.<func>_mask (ind, 'keep', xkeep,...)
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
% <#doc_end:>
% -----------------------------------------------------------------------------

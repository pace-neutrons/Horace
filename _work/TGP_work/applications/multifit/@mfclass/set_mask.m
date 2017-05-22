function obj = set_mask(obj,varargin)
% Select data points to simulate or fit
%
% Select for all current data sets: one or more of the keyword-value pairs
% (keyword-value pairs can appear in any order):
%   >> obj = obj.set_mask ('keep', xkeep, 'remove', xremove, 'mask', mask)
%
% Select for one or more particular datasets (idata an integer or integer array):
%   >> obj = obj.set_mask (idata, 'keep', xkeep,...)
%
% Input:
% ------
% Optional selection of datasets to mask:
%   idata       Index of dataset to mask, or array of indicies to mask
%              several datasets.
%               If omitted, the masking applies to all datasets
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
% See also add_mask clear_mask


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0, return, end

% Find optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,~,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end

% Check there are dataset(s)
if isempty(obj.data_)
    error ('Cannot set masking before data sets have been set.')
end

% Now check validity of input
if isempty(args)
    idata_in = [];
elseif numel(args)==1
    idata_in = args{1};
else
    error ('Check number of input arguments - data set indicies must be a single row vector')
end
[ok,mess,idata] = dataset_indicies_parse (idata_in, obj.ndatatot_);
if ~ok, error(mess), end

% Check optional arguments
[xkeep,xremove,msk,ok,mess] = mask_syntax_valid (numel(idata), keyval.keep, keyval.remove, keyval.mask);
if ~ok, error(mess), end

% Create mask arrays
[msk_out,ok,mess] = mask_data (obj.w_(idata),[],xkeep,xremove,msk);
if ok && ~isempty(mess)
    display_message(mess)
elseif ~ok
    error_message(mess)
end

% Set object
% ----------
obj.msk_(idata) = msk_out;

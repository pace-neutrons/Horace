function obj = add_mask(obj,varargin)
% Refine selection of data points to fit by further adding to existing masks
%
% Select for all current data sets: 1,2 or 3 of the keyword-value pairs
%   >> obj = obj.add_mask ('keep', xkeep, 'remove', xremove, 'mask', mask)
%
% Select for one or more particular datasets: give dataset indicies first
%(idata an integer or integer array):
%   >> obj = obj.add_mask (idata, 'keep', xkeep,...)


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
[msk_out,ok,mess] = mask_data (obj.w_(idata),obj.msk_(idata),xkeep,xremove,msk);
if ok && ~isempty(mess)
    display_message(mess)
elseif ~ok
    error_message(mess)
end

% Set object
% ----------
for i=1:numel(idata)
    obj.msk_{idata(i)} = obj.msk_{idata(i)} & msk_out{i};
end

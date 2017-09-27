function obj = replace_data(obj,varargin)
% Replace one or more datasets, clearing masks. Functions and constraints are unchanged
%
% If data in the form of objects is expected:
%   >> obj = obj.replace_data (w1,w2,..)     % Replace all datasets with an equal
%                                            % number of datasets
%   >> obj = obj.replace_data (ind,w1,w2,..) % Replace indicated dataset(s)
%                                            % with an equal number of new ones
%                                            % (ind is a scalar or row vector)
%
% If x,y,e data is valid (i.e. datasets are not required to be objects)
%   >> obj = obj.replace_data (x,y,e)        % Replace a single dataset with an
%                                            % x-y-e triple
%   >> obj = obj.replace_data (ind,x,y,z)    % Replace ith dataset with x-y-e triple
%   >> obj = obj.replace_data (ind,w1,w2,..) % Replace indicated dataset(s)
%                                            % with an equal number of new ones
%                                            % cell arrays or structures of x-y-e
%                                            % data (ind is a scalar or row vector)
%
% For more details about data formats see <a href="matlab:doc('mfclass/set_data');">set_data</a>
%
%
% In addition, portions of the data sets can be masked using one or more of
% the optional keyword-value pairs (keyword-value pairs can appear in any order):
%
%   >> obj = obj.replace_data (...'keep', xkeep, 'remove', xremove, 'mask', mask)
%
% For full details of the syntax, see <a href="matlab:doc('mfclass/set_mask');">set_mask</a>
%
%
% See also append_data remove_data set_data
 

% Note for developers:
%   >> obj = obj.replace_data ()        % Inert operation: does nothing
%   >> obj = obj.replace_data ([])      % Inert operation: does nothing

 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0
    return
end

% Find arguments and optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,present,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end
if isempty(args) && any(cellfun(@logical,struct2cell(present)))
    error('Syntax error: no input data was given but optional arguments were provided')
end

% Get dataset indicies to replace
if numel(args)==3 && isnumeric(args{1}) && isnumeric(args{2}) && isnumeric(args{3})
    % Case of three numeric arrays - assume user means to give (x,y,e)
    idata = 1;
    ibeg = 1;   % start of data in args
else
    if isnumeric(args{1}) || ischar(args{1})
        % Initial numeric array; assume is meant to be dataset index array
        % Catch case of 'all' too!
        [ok,mess,idata] = indicies_parse (args{1}, obj.ndatatot_, 'Dataset');
        if ~ok, error(mess), end
        if ~isempty(idata) && numel(args)==1
            error('Index of dataset(s) to replace have been given, but no data')
        end
        ibeg = 2;   % start of data in args
    else
        % No initial numeric array; assume all datasets requested to be replaced
        idata = 1:obj.ndatatot_;
        ibeg = 1;   % start of data in args
    end
end

% Check input data
class_name = obj.dataset_class_;
[ok, mess, w] = is_valid_data (class_name, args{ibeg:end});
if ~ok, error(mess), end
if numel(w)~=numel(idata)
    error('The number of datasets to be replaced is not matched by the number of replacement datasets')
end

% Check optional arguments
[ok,mess,xkeep,xremove,msk] = mask_syntax_valid (numel(w), keyval.keep, keyval.remove, keyval.mask);
if ~ok, error(mess), end

% Create mask arrays
[msk_out,ok,mess] = mask_data (w,[],xkeep,xremove,msk);
if ok && ~isempty(mess)
    display_message(mess)
elseif ~ok
    error_message(mess)
end


% Set object properties
% ---------------------
% Note that the functions and constraints properties are unchanged; we retain
% the functions and constraints, just change the data.
% That is how this is different from 'remove' followed by 'insert'
[ok,mess,data_out] = dataset_replace (obj.data_, idata, args(ibeg:end));
if ~ok, error(mess), end

obj.data_ = data_out;
obj.w_(idata) = w;
obj.msk_(idata) = msk_out;

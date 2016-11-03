function obj = replace_data(obj,varargin)
% Replace one or all datasets. The functions and constraints are left unchanged
%
%   >> obj = obj.replace_data (i,w)     % Replace ith data set with a scalar
%                                       % object
%   >> obj = obj.replace_data (w)       % Replace the single dataset with scalar
%                                       % object
%   >> obj = obj.replace_data (w1,w2,..)% Replace all datasets with an equal
%                                       % number of datasets
% If x,y,e data is valid:
%   >> obj = obj.replace_data (i,x,y,z) % Replace ith dataset with x-y-e triple
%   >> obj = obj.replace_data (x,y,e)   % Replace the single dataset with
%                                       % x-y-e triple
%
% If replacing just a single dataset, then if that dataset is part of an array
% of datasets within the full list of datasets, the substitution is only
% possible if:
% - an element of an object array is being replaced by a scalar object of the
%   same class
% - an element of a structure or an x-y-e triple (i.e. {x,y,e} or x,y,e), is
%   being replaced by a scalar structure or a single x-y-e triple.


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0, return, end

% Find optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,~,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end

% Find out if a specific dataset index has been given, or if only dataset(s)
if (numel(args)==2 || numel(args)==4) && ...
        isnumeric(args{1}) && isscalar(args{1}) && isfinite(args{1})
    % Replace a specific dataset
    if isa_index (args{1}, obj.ndatatot_)
        id = args{1};
        args = args(2:end);
    else
        mess = ['Check the dataset index is a positive integer in the range 1 - ',...
            num2str(numel(obj.ndatatot_))];
        error(mess)
    end
else
    % Replace all datasets
    id = [];
end

% Check input data
class_name = obj.wrapfun_.dataset_class;
[ok, mess, ndim, w] = is_valid_data (class_name, args{:});
if ~ok, error(mess), end
if ~isempty(id) && numel(w)~=1  % case of replacing a single dataset
    error('A single dataset is expected, but more than one was given')
elseif isempty(id) && numel(w)~=obj.ndatatot_
    error('Number of datasets does not match current number of datasets - cannot replace')
end

% Check optional arguments
[xkeep,xremove,msk,ok,mess] = mask_syntax_valid (numel(w), keyval.keep, keyval.remove, keyval.mask);
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
if ~isempty(id)
    % Replacing a single dataset
    item=obj.item_(id);
    if obj.ndata_(item)==1
        % Replacing a scalar dataset item with another scalar dataset item
        if obj.ndatatot_>1  % more than one dataset currently set
            if numel(args)==3   % replacement data is x,y,e
                obj.data_{item} = args;    % item replaced with {x,y,e}
            else
                obj.data_{item} = args{1};
            end
        else
            obj.data_ = args;
        end
        obj.ndim_{item} = ndim{1};
    else
        % Replacing a scalar dataset in a non-scalar data item
        if (isobject(obj.data_{item}) && isa(args{1},class(obj.data_{item}))) ||...
                (isstruct(obj.data_{item}) && isstruct(args{1})) ||...
                (iscell(obj.data_{item}) && (iscell(args{1}) || numel(args)==3))
            ix=obj.ix_(id);
            if numel(args)==3
                obj.data_{item}(ix) = {args};
            else
                obj.data_{item}(ix) = args{1};
            end
            obj.ndim_{item}(ix) = ndim{1};
        else
            error('Attempting to replace a single dataset in an array with one of a different type is forbidden')
        end
    end
    obj.w_{id} = w{1};
    obj.msk_{id} = msk_out{1};
    
else
    % Replacing all datasets
    [ndata,ndatatot,item,ix] = data_indicies(ndim);
    obj.data_ = args;
    obj.ndim_ = ndim;
    obj.ndata_ = ndata;
    obj.ndatatot_ = ndatatot;
    obj.item_ = item;
    obj.ix_ = ix;
    obj.w_ = w;
    obj.msk_ = msk_out;
end

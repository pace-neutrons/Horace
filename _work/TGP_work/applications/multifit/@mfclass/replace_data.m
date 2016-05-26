function obj = replace_data(obj,varargin)
% Replace one or all datasets. The functions and constraints are left unchanged
%
%   >> obj = obj.replace_data (i,x,y,z) % Replace ith dataset with x-y-e triple
%   >> obj = obj.replace_data (i,w)     % Replace with {x,y,e}, or scalar
%                                       % structure or object
%
%   >> obj = obj.replace_data (x,y,e)   % Replace the single dataset with
%                                       % x-y-e triple (only OK if single dataset)
%   >> obj = obj.replace_data (w)       % Replace the single dataset with scalar
%                                       % structure or object (only OK if single dataset)
%   >> obj = obj.replace_data (w1,w2,..)% Replace all dataset(s) with equal number
%                                       % of datasets
%
% If replacing just a single dataset, then if that dataset is part of a cell,
% structure or object array of datasets within the full list of datasets,
% the substitution is only possible if:
% - an element of an object array is being replaced by a scalar object of the
%   same class
% - an element of a structure or an x-y-e triple (i.e. {x,y,e} or x,y,e), is
%   being replaced by a scalar structure or a single x-y-e triple.


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0, return, end

% Find out if a specific dataset index has been given, or if only dataset(s)
if (numel(varargin)==2 || numel(varargin)==4) && ...
        isnumeric(varargin{1}) && isscalar(varargin{1}) && isfinite(varargin{1})
    % Replace a specific dataset
    if isa_index (varargin{1}, obj.ndatatot_)
        id = varargin{1};
        data_cell = varargin(2:end);
        [ok, mess, ndim] = is_valid_data (data_cell{:});
        if ~ok, error(mess), end
        
        if numel(ndim)==1 && numel(ndim{1})==1
            % Replacing a single dataset
            item=obj.item_(id);
            if obj.ndata_(item)==1  % replacing a scalar dataset item with another scalar dataset item
                if obj.ndatatot_>1  % more than one dataset currently set
                    if numel(data_cell)==3   % replacement data is x,y,e
                        obj.data_{item} = data_cell;    % item replaced with {x,y,e}
                    else
                        obj.data_{item} = data_cell{1};
                    end
                else
                    obj.data_ = data_cell;
                end
                obj.ndim_{item} = ndim{1};
            else    % replacing a scalar dataset in a non-scalar data item
                if (isobject(obj.data_{item}) && isa(data_cell{1},class(obj.data_{item}))) ||...
                        (isstruct(obj.data_{item}) && isstruct(data_cell{1})) ||...
                        (iscell(obj.data_{item}) && (iscell(data_cell{1}) || numel(data_cell)==3))
                    ix=obj.ix_(id);
                    if numel(data_cell)==3
                        obj.data_{item}(ix) = {data_cell};
                    else
                        obj.data_{item}(ix) = data_cell{1};
                    end
                    obj.ndim_{item}(ix) = ndim{1};
                else
                    error('Attempting to replace a single dataset in an array with one of a different type is forbidden')
                end
            end
        else
            error('A single dataset is expected, but more than one was given')
        end
        
    else
        mess = ['Check the dataset index is a positive integer in the range 1 - ',...
            num2str(numel(obj.ndatatot_))];
        error(mess)
    end
    
else
    % Replacing all datasets - only valid if same number of datasets as originally
    [ok, mess, ndim] = is_valid_data (varargin{:});
    if ~ok, error(mess), end
    
    [ndata,ndatatot,item,ix] = data_indicies(ndim);
    if ndatatot==obj.ndatatot_
        obj.data_ = varargin;
        obj.ndim_ = ndim;
        obj.ndata_ = ndata;
        obj.ndatatot_ = ndatatot;
        obj.item_ = item;
        obj.ix_ = ix;
    else
        error('Number of datasets does not match current number of datasets - cannot replace')
    end
    
end

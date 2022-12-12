function ndims = found_dims_(varargin)
% Found number of dimensions from the dnd method inputs
if (nargin>1)
    has_dims = cellfun(@(x)(isa(x,'axes_block')||isa(x,'SQWDnDBase')||...
        isa(x,'dnd_metadata')||isa(x,'dnd_data')),varargin);
    if any(has_dims)
        dim_id = find(had_dims,1);
        ax = varargin{dim_id};
        ndims = ax.dimensions();
    else
        error('HORACE:DnDBase:invalid_argument',...
            'unknown input type does not allow to establish size of target objects')
    end
else
    if isstruct(varargin{1})
        if isfield(varargin{1},'p')
            ndims = numel(varargin{1}.p);
            %                     elseif isfield(varargin{1},'')
        else
            error('HORACE:DnDBase:invalid_argument',...
                'can not indentify the dimensions of the input data');
        end
    else
        ndims = varargin{1}.dimensions;
    end
end

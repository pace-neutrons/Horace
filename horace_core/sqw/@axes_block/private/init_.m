function [obj,uoffset,remains] = init_(obj,varargin)
%
%
remains = {};
uoffset = zeros(4,1);
nargi = nargin-1;
if isa(varargin{1},'axes_block') % handle shallow copy constructor
    obj =varargin{1};            % its COW for Matlab anyway
elseif nargi==1
    if isstruct(varargin{1})
        input_struct = varargin{1};
        %TODO: this should be removed and axis cation become part
        %of some classes from axes_block family.
        if isfield(input_struct,'axis_caption') && ~isempty(input_struct.axis_caption)
            obj.axis_caption = input_struct.axis_caption;
        else
            obj.axis_caption = an_axis_caption();
        end
        %
        [obj,remains] = from_struct(obj,varargin{1});
        remains = {remains};
    elseif isscalar(varargin{1}) && isnumeric(varargin{1})
        ndim=varargin{1};
        if ~any(ndim==[0,1,2,3,4])
            error('HORACE:axes_block:invalid_argument',...
                'Numeric input must be 0,1,2,3 or 4 to create empty dataset');
        end
        
        rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
        pbin=[repmat({{[0,1]}},1,ndim),rest];
        obj = set_axis_bins_(obj,pbin{:});
        obj.axis_caption = an_axis_caption();
    elseif iscell(varargin{1}) && numel(varargin{1})==4 % input is the array of binning parameters
        obj = set_axis_bins_(varargin{1}{:});
        obj.axis_caption = an_axis_caption();
    else
        error('HORACE:axes_block:invalid_argument',...
            'unrecognized type of single axis_block constructor argument');
    end
elseif nargi>= 4 %remaining input is p1,p2,p3,p4
    nonorthogonal_ = false;
    if nargi>4 %legacy operations
        is_proj = cellfun(@(x)((isstruct(x) && isfield(x,'u')) || ...
                isa(x,'aProjection') || isa(x,'projaxes')),varargin,...
                'UniformOutput',true);
        if any(is_proj)
            proj_ind = find(is_proj);
            if isprop(varargin{proj_ind},'nonorthogonal') ||...
                    isfield(varargin{proj_ind},'nonorthogonal')
                obj.nonorthogonal = varargin{proj_ind}.nonorthogonal;
            end
            argi = varargin(proj_ind+1:end);
            remains = varargin(1:proj_ind);
            if numel(argi) == 4
                obj = set_axis_bins_(obj,argi{:});
                obj.axis_caption = an_axis_caption();
                return
            end
        else
            proj = [];
            argi = varargin;
        end
        [pbin,uoffset,nonorthogonal_,remains]=make_axes_from_shifted_pbin_(argi{:});
        if ~isempty(proj)
            remains= [proj;remains(:)];
        end
    else % ,p1,p2,p3,p4 form
        pbin = varargin;
    end
    obj = set_axis_bins_(obj,pbin{:});
    
    obj.axis_caption = an_axis_caption();
    obj.nonorthogonal = nonorthogonal_;
else
    error('HORACE:axes_block:invalid_argument',...
        'unrecognized number %d of input arguments',nargi);
    
end



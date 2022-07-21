function [obj,offset,remains] = init_(obj,varargin)
%
%
remains = {};
offset = zeros(4,1);
nargi = nargin-1;
if isa(varargin{1},'axes_block')
    source = varargin{1};
    if strcmp(class(obj),'axes_block')% handle shallow copy constructor
        obj =source;                    % its COW for Matlab anyway
    else % child initiated (may be partially) by an axes_block.
        % the case probably will be removed in a future but logically correct
        ab = axes_block();
        flds = ab.saveableFields();
        for i=1:numel(flds)
            obj.(flds{i}) = source.(flds{i});
        end
    end
    remains = varargin(2:end);
    if isfield(remains{1},'uoffset')
        offset = remains{1}.uoffset(:);
    end
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
        ndim=varargin{1}; % build default axes block with specified number of dimensions
        if ~any(ndim==[0,1,2,3,4])
            error('HORACE:axes_block:invalid_argument',...
                'Numeric input must be 0,1,2,3 or 4 to create empty dataset');
        end

        rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
        pbin=[repmat({[0,1]},1,ndim),rest];
        obj = set_axis_bins_(obj,ndim,pbin{:});
        obj.axis_caption = an_axis_caption();
    elseif iscell(varargin{1}) && numel(varargin{1})==4 % input is the array of binning parameters
        obj = set_axis_bins_([],varargin{1}{:});
        obj.axis_caption = an_axis_caption();
    else
        error('HORACE:axes_block:invalid_argument',...
            'unrecognised type of single axis_block constructor argument');
    end
elseif nargi>= 4 % Either binning parameters (first 4) or default serializable
    % constructor with parameters as specified in saveableFields list
    is_num = cellfun(@(x)isnumeric(x),varargin);
    if all(is_num(1:4)) %binning parameters
        argi  = varargin(5:end);
        pbin = varargin(1:4);
        if numel(argi)>0 % check if single_bin_defines_iax is present and the bins should be
            % treated differently
            is_present = cellfun(@(x)(ischar(x)&&strcmp(x,'single_bin_defines_iax')),argi);
            if any(is_present)
                ind = find(is_present);
                obj.single_bin_defines_iax = argi{ind+1};
                is_present(ind+1) = true;
                argi = argi(~is_present);
            end
        end
        obj = set_axis_bins_(obj,[],pbin{:});
    else
        argi  = varargin;
    end
    if numel(argi)>0
        names = obj.saveableFields();
        [obj,remains] = obj.set_positional_and_key_val_arguments(...
            names,argi{:});
    end
    % For data_sqw_dnd (to remove)
    %     nonorthogonal_ = false;
    %     if nargi>4 %legacy operations
    %         is_proj = cellfun(@(x)((isstruct(x) && isfield(x,'u')) || ...
    %             isa(x,'aProjection') || isa(x,'projaxes')),varargin,...
    %             'UniformOutput',true);
    %         if any(is_proj)
    %             proj_ind = find(is_proj);
    %             if isprop(varargin{proj_ind},'nonorthogonal') ||...
    %                     isfield(varargin{proj_ind},'nonorthogonal')
    %                 obj.nonorthogonal = varargin{proj_ind}.nonorthogonal;
    %             end
    %             argi = varargin(proj_ind+1:end);
    %             remains = varargin(1:proj_ind);
    %             if numel(argi) == 4
    %                 obj = set_axis_bins_(obj,argi{:});
    %                 obj.axis_caption = an_axis_caption();
    %                 return
    %             end
    %         else
    %             proj = [];
    %             argi = varargin;
    %         end
    %         [pbin,offset,nonorthogonal_,remains]=make_axes_from_shifted_pbin_(argi{:});
    %         if ~isempty(proj)
    %             remains= [proj;remains(:)];
    %         end
    %     else % ,p1,p2,p3,p4 form
    %         pbin = varargin;
    %         ndims = [];
    %     end
    %     obj = set_axis_bins_(obj,ndims,pbin{:});
    %
    %     obj.axis_caption = an_axis_caption();
    %         obj = set_axis_bins_(obj,ndims,pbin{:});
else
    error('HORACE:axes_block:invalid_argument',...
        'unrecognised number %d of input arguments',nargi);
end

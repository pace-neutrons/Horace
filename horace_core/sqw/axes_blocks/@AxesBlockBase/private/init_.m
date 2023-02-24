function [obj,offset,remains] = init_(obj,varargin)
%
%
remains = {};
offset = zeros(4,1);
nargi = nargin-1;
if nargi>0 && isa(varargin{1},'AxesBlockBase')
    obj = varargin{1};
    remains = varargin(2:end);
    if ~isempty(remains) && isfield(remains{1},'uoffset')
        offset = remains{1}.uoffset(:);
    end
    return;
end

if nargi==1
    if isstruct(varargin{1})
        input_struct = varargin{1};
        [obj,remains] = from_struct(obj,varargin{1});
        remains = {remains};
    elseif isscalar(varargin{1}) && isnumeric(varargin{1})
        ndim=varargin{1}; % build default axes block with specified number of dimensions
        if ~any(ndim==[0,1,2,3,4])
            error('HORACE:AxesBlockBase:invalid_argument',...
                'Numeric input must be 0,1,2,3 or 4 to create empty dataset');
        end

        rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
        pbin=[repmat({[0,1]},1,ndim),rest];
        obj = set_axis_bins_(obj,ndim,pbin{:});
    elseif iscell(varargin{1}) && numel(varargin{1})==4 % input is the array of binning parameters
        obj = set_axis_bins_([],varargin{1}{:});
    else
        error('HORACE:AxesBlockBase:invalid_argument',...
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
            names,false,argi{:});
        if ~isempty(remains)
            out = cellfun(@any_to_char,remains,'UniformOutput',false);
            error('HORACE:AxesBlockBase:invalid_argument',...
                'Unknown input parameters and/or values %s',strjoin(out,'; '))
        end
    end
elseif nargi<4 && nargi>1
    names = obj.saveableFields();
    [obj,remains] = obj.set_positional_and_key_val_arguments(...
        names,false,varargin{:});
else
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Unrecognised number: %d of input arguments',nargi);
end

function out = any_to_char(x)
if ischar(x)||isstring(x)
    out = x;
else
    out = evalc('disp(x)');
end
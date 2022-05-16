function [obj,remains] = process_positional_args_(obj,varargin)
% Process positional arguments of an ortho_projection init method
% Inputs:

%   u    if present, [1x3] Vector of first axis (r.l.u.) defining projection axes
%   v    if present, [1x3] Vector of second axis (r.l.u.) defining projection axes

%   w    if present,  [1x3] Vector of third axis (r.l.u.) - only needed if the third
%               character of argument 'type' is 'p'. Will otherwise be ignored.
% Returns:

% ortho_proj object with properties set
if numel(varargin)>0 && isnumeric(varargin{1})
    obj = check_and_set_uv_(obj,'u',varargin{1});
elseif isa(varargin{1},'ortho_proj') % copy constructor
    if strcmp(class(obj),'ortho_proj')
        obj = varargin{1}; % clear copy constructor
    else % works for children of the orho_proj; Needs check for arrays.
        % It may be better to convert to_struct (certainly works for arrays, but this one may work too)
        strct = varargin{1}.to_bare_struct();
        obj = obj.from_bare_struct(strct);
    end
elseif isstruct(varargin{1})
    prop = properties(obj);
    remains = varargin{1};
    for i=1:numel(prop)
        if isfield(remains,prop{i})
            obj.(prop{i}) = remains.(prop{i});
            remains = rmfield(remains,prop{i});
        end
    end
    fn = fieldnames(remains);
    if isempty(fn)
        remains = {};
        return;
    end
else
    remains= varargin;
    return;
end
if numel(varargin)>1 && isnumeric(varargin{2})
    obj = check_and_set_uv_(obj,'v',varargin{2});
else
    remains= varargin(2:end);
    return;
end
if numel(varargin)>2 && isnumeric(varargin{3})
    obj = check_and_set_w_(obj,varargin{3});
    remains = varargin(4:end);
else
    remains= varargin(3:end);
end
%

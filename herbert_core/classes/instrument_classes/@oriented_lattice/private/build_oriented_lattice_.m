function obj = build_oriented_lattice_(obj,varargin)
% build non-empty oriented lattice from any form of constructor input
% including 5 positional arguments: 'alatt','angdeg','psi','u','v'
%

if isa(varargin{1},'oriented_lattice') % copy constructor
    obj = varargin{1};
elseif isstruct(varargin{1}) % strucure with oriented lattice fields
    input = varargin{1};
    field_names = fieldnames(input);
    for i=1:numel(field_names)
        obj.(field_names{i}) = input.(field_names{i});
    end
elseif isnumeric(varargin{1}) % the initialization is done by positional
    % arguments followed by key-value pairs
    isnum = cellfun(@(x)isnumeric(x),varargin); % number of positional arguments
    pos_arg_names = [obj.lattice_parameters_(:)','angular_units']; % names of all possible
    % positional arguments
    if ~all(isnum)
        first_non_num = find(~isnum,1);
        key_val_arg = varargin(first_non_num:end);
    else
        key_val_arg = {};
        first_non_num = numel(varargin)+1;
    end
    pos_arg_val = varargin(1:first_non_num-1);
    pos_arg_names = pos_arg_names(1:first_non_num-1);
    for i=1:numel(pos_arg_val)
        obj.(pos_arg_names{i}) = pos_arg_val{i};
    end
    if isempty(key_val_arg)
        return;
    end
    % key-val arguments remain
    obj = parse_keyval_argi(obj,key_val_arg{:});
elseif ischar(varargin{1})
    obj = parse_keyval_argi(obj,varargin{:});
else
    error('HERBERT:oriented_lattcie:invalid_argument',...
        ['oriented lattice may be constructed only with input structure,'...
        ' containing the same fields as public fields of the oriented lattice itself or '...
        'using constructor, containing up to 5 positional parameters and key-value pairs']);
end

[ok,mess,obj] = check_combo_arg_(obj);
if ~ok
    error('HERBERT:oriented_lattcie:invalid_argument',mess);
end
%
function obj = parse_keyval_argi(obj,varargin)
n_kvargs = numel(varargin);
n_kvarg = n_kvargs/2;
if n_kvarg*2 ~=n_kvargs
    error('HERBERT:oriented_lattcie:invalid_argument',...
        'each key argument has to be followed by its value')
end
for i=1:n_kvarg
    obj.(varargin{2*i-1}) = varargin{2*i};
end

function  [obj,remains] = set_positional_and_key_val_arguments_(obj,...
    positional_arg_names,varargin)
if nargin == 1
    remains = {};
    return;
end

if ischar(varargin{1})
    [obj,remains] = parse_keyval_argi(obj,positional_arg_names,varargin{:});
else
    isnum = cellfun(@(x)isnumeric(x),varargin); % number of positional arguments
    % Extract and set up positional arguments, which should always come
    % first
    if ~all(isnum)
        first_non_num = find(~isnum,1);
        key_val_arg   = varargin(first_non_num:end);
    else
        key_val_arg = {};
        first_non_num = numel(varargin)+1;
    end
    % assosiate positional argument names with their values
    pos_arg_val = varargin(1:first_non_num-1);
    pos_arg_names = positional_arg_names(1:first_non_num-1);
    % set up positional arguments values
    for i=1:numel(pos_arg_val)
        obj.(pos_arg_names{i}) = pos_arg_val{i};
    end
    if isempty(key_val_arg)
        remains = {};
        return;
    end
    % process remaining key-val arguments pairs
    pos_arg_remain = positional_arg_names(first_non_num:end);
    [obj,remains] = parse_keyval_argi(obj,pos_arg_remain,key_val_arg{:});
end

function [obj,remains] = parse_keyval_argi(obj,arg_names,varargin)

is_key = cellfun(@(arg)(ischar(arg)&&ismember(arg,arg_names)),varargin);
if ~any(is_key)
    remains = varargin;
    return;
end
key_pos = find(is_key);
val_pos = key_pos+1;
if val_pos(end)>numel(varargin) || any(ismember(key_pos,val_pos))
    error('HERBERT:serializable:invalid_argument', ...
        'should be even number of key-value pairs, but some keys do not have correspondent pair-value')
end
% find indexes of key-val pairs
is_key(val_pos) = true;
remains = varargin(~is_key);

for i=1:numel(key_pos)
    obj.(varargin{key_pos(i)}) = varargin{val_pos(i)};
end

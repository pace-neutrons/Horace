function  [obj,remains] = set_positional_and_key_val_arguments_(obj,...
    positional_arg_names,validators,varargin)
% Utility function, to use in a serializable class constructor,
% allowing to specify the constructor parameters in the form:
%
% ObjConstructor(positional_par1,positional_par2,positional_par3,...
% positional_par...,key1,val1,key2,val2,...keyN,valN);
% where all potitional parameters
% have to be numeric and all keys from key-value pairs have to
% be present in the list returned by indepFields(obj) function.
%
% Everything found after last Key-Value pair with the last key,
% which is a member of the list, returned by indepFields
% function is returned in remains cellarray
%
% Inputs:
% positinal_param_names_list
%            -- list of positional parameter
%               names, the target properties should be
%               associated with
% validators -- cellarray (size of positinal_param_names_list)
%               of the functions, whihch verify
%               the types of the input artuments. If empty,
%               the checks assumes that all input parameters
%               should be numeric. Cautions about character
%               types

%
if nargin == 1
    remains = {};
    return;
end
% check what arguments are positional arguments, verifying their types
% assume that first argument with type different from the one in the list 
% of validators starts the sequence of remaining (not used) or key-val arguments
is_positional = check_correct_positional_types(validators,varargin{:});
% process positional arguments
if any(is_positional)
    if ~all(is_positional)
        first_keyval = find(~is_positional,1);
        key_val_arg   = varargin(first_keyval:end);
    else
        key_val_arg = {};
        first_keyval = numel(varargin)+1;
    end
    pos_arg_val = varargin(1:first_keyval-1);
    pos_arg_names = positional_arg_names(1:first_keyval-1);
    % Extract and set up positional arguments, which should always come
    % first
    % assosiate positional argument names with their values
    % set up positional arguments values
    for i=1:numel(pos_arg_val)
        obj.(pos_arg_names{i}) = pos_arg_val{i};
    end
    if isempty(key_val_arg)
        remains = {};
        return;
    end
    pos_arg_remain = positional_arg_names(first_keyval:end);
else
    pos_arg_remain = positional_arg_names;
    key_val_arg   = varargin;
end

[obj,remains] = parse_keyval_argi(obj,pos_arg_remain,key_val_arg{:});


function [obj,remains] = parse_keyval_argi(obj,arg_names,varargin)
% find keys, corresponding to key arguments and set up object to the values
% which follow the keys in the cellarray of input arguments
%
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

function is_positional = check_correct_positional_types(validators,varargin)
% check if positional types correspond to their validators.
% first argument which do not correspond to its type assumed to be
% key-value argument
%
nargi = numel(varargin);
is_positional = false(nargi,1);
n_val = numel(validators);
for i = 1:nargi
    if i>n_val
        is_positional(i) = isnumeric(varargin{i});
    else
        check = validators{i};
        is_positional(i) = check(varargin{i});
    end
    if ~is_positional(i)
        break;
    end

end


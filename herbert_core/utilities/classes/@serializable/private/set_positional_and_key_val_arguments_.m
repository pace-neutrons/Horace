function  [obj,remains] = set_positional_and_key_val_arguments_(obj,...
    positional_arg_names,varargin)
% Utility function, to use in a serializable class constructor,
% allowing to specify the constructor parameters in the form:
%
% ObjConstructor(positional_par1,positional_par2,positional_par3,...
% positional_par...,key1,val1,key2,val2,...keyN,valN);
%
% All positional parameters should have the type defined in the validators
% list. If the validator list is shorter then positional_arg_names list or
% empty, the remaining positional argument values assumed to be numeric.
%
% First argument, which type not corresponds to the type, defined by the
% validator list, assumed to be belonging to key-value pair.
%
% Everything not identified as Key-Value pair where the keys,
% belong to the property names returned by saveableFields function
% is returned in remains cellarray
%
% Inputs:
% positinal_param_names_list
%            -- list of positional parameter
%               names, the target properties should be
%               associated with
% EXAMPLE:
% if class have the properties {'a1'=1(numeric), 'a2'='blabla'(char),
% 'a3'=sqw() 'a4=[1,1,1] (numeric), and these properties are independent
% properties redutned by saveableFields() function as list {'a1','a2','a3','a4'}
%
% Then the list of input parameters
% set_positional_and_key_val_arguments(1,'blabla',an_sqw_obj,'blabla','a4',[1,0,0],'cccc','a3',[1,1,0])
% sets up the three first argument as positional parameters, for properties
% a1,a2 and a3, a4 are set as postional arguments and 'a3' and 'a4' are
% reset as key-value pair after this. `cccc` is returned in remains
%

if nargin == 1
    remains = {};
    return;
end
obj.do_check_combo_arg_ = false;
[obj,remains,key_num,val_num,is_positional] = parse_keyval_argi(obj,positional_arg_names,varargin{:});


% process positional arguments
if any(is_positional)
    argi = varargin;
    pos_arg_val = argi(is_positional);
    pos_arg_names = positional_arg_names(1:numel(pos_arg_val));
    % Extract and set up positional arguments, which should always come
    % first
    % associate positional argument names with their values
    % set up positional arguments values
    for i=1:numel(pos_arg_val)
        obj.(pos_arg_names{i}) = pos_arg_val{i};
    end
end
for i=1:numel(key_num)
    obj.(varargin{key_num(i)}) = varargin{val_num(i)};
end
% enable check for the combo properties
obj.do_check_combo_arg_ = true;
obj=obj.check_combo_arg();



function [obj,remains,key_pos,val_pos,is_positional] = parse_keyval_argi( ...
    obj,arg_names,varargin)
% find keys, corresponding to key arguments and set up object to the values
% which follow the keys in the cellarray of input arguments
%
is_key = cellfun(@(arg)(ischar(arg)&&ismember(arg,arg_names)),varargin);
is_positional = ~is_key;
if ~any(is_key)
    key_pos = [];
    val_pos = [];
    remains = {};
    return;
end
key_pos = find(is_key);
if key_pos(1)>1
    is_positional(key_pos(1):end) = false;
else
    is_positional(1:end) = false;
end
val_pos = key_pos + 1;
if val_pos(end)>numel(varargin) || any(ismember(key_pos,val_pos))
    error('HERBERT:serializable:invalid_argument', ...
        'should be even number of key-value pairs, but some keys do not have correspondent pair-value')
end
% find places of key-val pairs
is_key(val_pos) = true;
remains = varargin(~is_key & ~is_positional);




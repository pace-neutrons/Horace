function  [obj,remains] = set_positional_and_key_val_arguments_(obj,...
    positional_arg_names,suport_dashed_keys,varargin)
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
% suport_dashed_keys
%            -- if set to true, keys in varargin may have form
%               '-keyN' in addition to 'keyN'. Deprecation warning is
%               issued for this kind of key names
% EXAMPLE:
% if class have the properties {'a1'=1(numeric), 'a2'='blabla'(char),
% 'a3'=sqw() 'a4=[1,1,1] (numeric), and these properties are independent
% properties redutned by saveableFields() function as list {'a1','a2','a3','a4'}
%
% Then the list of input parameters
% set_positional_and_key_val_arguments(1,'blabla',an_sqw_obj,'blabla','a4',[1,0,0],'cccc','a3',[1,1,0])
% sets up the three first argument as positional parameters, for properties
% a1,a2 and a3, a4 are set as positional arguments and 'a3' and 'a4' are
% reset as key-value pair after this. `cccc` is returned in remains
%

if nargin == 1
    remains = {};
    return;
end
obj.do_check_combo_arg_ = false;
[obj,remains,key_num,val_num,is_positional,argi] = parse_keyval_argi(obj, ...
    positional_arg_names,suport_dashed_keys,varargin{:});


% process positional arguments
if any(is_positional)
    if sum(is_positional)> numel(positional_arg_names)
        error('HERBERT:serializable:invalid_argument',...
            'More positional arguments identified (%d) then properties values required (%d). Some keys have identified as property values',...
            sum(is_positional),numel(positional_arg_names))
    end
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
    obj.(argi{key_num(i)}) = argi{val_num(i)};
end
% enable check for the combo properties
obj.do_check_combo_arg_ = true;
obj=obj.check_combo_arg();



function [obj,remains,key_pos,val_pos,is_positional,argi] = parse_keyval_argi( ...
    obj,arg_names,support_dash_option,varargin)
% find keys, corresponding to key arguments and set up object to the values
% which follow the keys in the cellarray of input arguments
%
[is_key,deprecated_fields,argi] = is_char_key_member(obj,arg_names,support_dash_option,varargin{:});
if support_dash_option
    if ~isempty(deprecated_fields)
        warning('HORACE:serializable:deprecated',...
            ['Some class %s constructor key-value inputs have been provided with "-" prefix\n', ...
            'These properties are: %s\n', ...
            'This syntax is deprecated. Provide these keys without "-" prefix in the beginning'], ...
            class(obj),disp2str(deprecated_fields));
    end
end


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

function [is,deprecated_fields,argi] = is_char_key_member(obj,key_list,support_dash,varargin)
% identify character keys belonging to the provided cellarray within the list of
% the inputs parameters
%
is = false(1,numel(varargin));
deprecated_fields = {};
if support_dash
    is_deprecated = false(1,numel(varargin));
end
in_pos_parameters = true;

argi = varargin;
prev_input_is_key = false;
for i=1:numel(varargin)
    min_comp_base = 4; % define minimal number of letters in abbreviation plus 1
    par = varargin{i};
    if in_pos_parameters % check if we have not exceeded the range of positional parameters
        in_pos_parameters = i<=numel(key_list);
    end
    if ~(ischar(par)||isstring(par)) % key can only be char, this is value
        prev_input_is_key = false;
        continue;
    end
    if prev_input_is_key
        prev_input_is_key = false;
        continue;
    end
    if in_pos_parameters
        % character parameter may be a key for some property or character value
        % for a char positional parameter

        % if char value starts with '-' its probablyt a key
        if ischar(obj.(key_list{i})) || isstring(obj.(key_list{i}))
            if strncmp(par,'-',1)
                par = extractAfter(par,1);
            else % if it not starts with '-' and can be still the key so we
                %  need full comparison with some key name
                min_comp_base = inf;
            end
        end

    end
    %
    if support_dash
        is_key = cellfun(@(x)compare_par(par,x,min_comp_base),key_list);
        is_depr_key = cellfun(@(x)compare_par(par,['-',x],min_comp_base+1),key_list);
        if any(is_depr_key)
            is_deprecated(i) = true;
        end
        is_key = is_key|is_depr_key;
    else
        is_key = cellfun(@(x)compare_par(par,x,min_comp_base),key_list);
    end
    found = sum(is_key);
    if found>1
        error('HERBERT:serializable:invalid_argument',...
            ' Input key N%d (%s) can non-uniquely define more then one possible properties: [%s].\n Can not interpret this key',...
            i,par,disp2str(key_list(is_key)));
    elseif found == 1
        if prev_input_is_key
            error('HERBERT:serializable:invalid_argument',...
                'Two input parameters in a row (N%d and N%d) are identified as keys: (%s and %s). Something is wrong',...
                i-1,i,argi{i-1},key_list{is_key})
        end
        prev_input_is_key = true;
        in_pos_parameters = false; % first key indicates that positional parameters have been finished
        is(i) = true;
        argi{i}= key_list{is_key};
        if support_dash && any(is_deprecated)
            deprecated_fields = varargin(is_deprecated);
        end
    else
        prev_input_is_key = false;
    end
end

function eq = compare_par(par,key,min_comp)
% let's prohibit keyword abbreviation to less then specified number of symbols.
if isinf(min_comp)
    comp_base  = numel(key);
else
    comp_base  = min(min_comp,numel(key));
end
if numel(par) < comp_base
    eq = false;
    return;
end
eq = strncmp(par,key,numel(par));
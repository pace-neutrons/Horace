function  [obj, remains] = set_positional_and_key_val_arguments_ (obj, ...
    positional_arg_names, options, varargin)
% Utility function to parse the input to a serializable class constructor
% It allows the constructor parameters to be specified with the syntax:
%
% ObjConstructor(positional_par1,positional_par2,positional_par3,...
%                       positional_parM, key1, val1, key2, val2,...keyN, valN);
%
% The keys are the names of the properties and the values are their values.
% The positional parameters are intended to be the values of the properties
% with names determined such that positional_par1 is assigned as the value of
% key1 in the positional_arg_names list, positional_par2 assigned to key2 etc.
%
% Any parameters that appear within the list of key-val pairs are collected into
% the output argument remains.
%
% Usage:
% ------
% Do nothing:
%   >> [obj, remains] = set_positional_and_key_val_arguments_ (obj)
%
%
%   >> [obj, remains] = set_positional_and_key_val_arguments_ (obj, ...
%                               positional_arg_names, options, ...
%                               par1, par2,...parM, ...
%                               key1, val1, key2, val2,...keyN, valN)
%
% Input:
% ------
%   obj         Object to be constructed (or updated)
%
%   positional_arg_names
%               Cellarray of positional parameter names, coinciding with
%               the names of the properties the function is called to set
%
%   options     Control options:
%               Legacy syntax: logical flag:
%                   If set to true, keys may have the form '-keyN' in addition
%                   to 'keyN'. A deprecation warning is issued for this kind of
%                   key name. False if the '-' option is forbidden.
%
%               Current syntax: structure with fields
%                   .key_dash   True: keys may have the form '-keyN'; false if not
%                   .mandatory_fields   Logical vector with which fields of
%                                       positional_arg_names must appear in the
%                                       input (either as a positional or a
%                                       key-value pair)
%
%   par1, par2, ...
%               Values to be assigned to the properties named in
%               positional_arg_names
%
%   key1, val1, key2, val2,...
%               The list of the inputs of the class constructor to parse
%               according to positional parameters names list
%
% Output:
% -------
%   obj         Object with properties updated according to the input
%               positional parameters and key-val pairs.
%
%   remains     Cellarray of arguments within the key-val pairings that are
%               not assigned to a key named in positional_arg_names
%
%
% Note: if a property is assigned more than once (because it appears in both
% the positional parameter list and key-val list, or it appears more that once
% in the key-val list), then the last occurence in the list is the one that
% is assined to the property value.
%
%
% EXAMPLE:
% --------
% Suppose an object has the properties:
%   'a1' = 1            (numeric)
%   'a2' = 'blabla'     (char)
%   'a3' = sqw()        (sqw object)
%   'a4 = [1,1,1]       (numeric)
% and these properties are those returned by the call
%   fld = saveableFields()
% so that flds == {'a1','a2','a3','a4'}
%
% Then the call:
%   [obj, remains] = set_positional_and_key_val_arguments(obj, flds, false, ...
%       1, 'blabla', an_sqw_obj, 'blabla', 'a4', [1,0,0], 'cccc', 'a3', [1,1,0])
%
% sets properties 'a1', 'a2', 'a3' as positional arguments, but then resets
% 'a3' and 'a4' as key-value pairs. 'cccc' is returned in the cellarray remains.
%
%
% CODE TEMPLATE:
% --------------
% Simple Code sample to insert into new object constructor
% to use this function as part of generic constructor:
%
%           :
%       flds = obj.saveableFields();
%       [obj, remains] = obj.set_positional_and_key_val_arguments(...
%           flds,false,varargin{:});
%       if ~isempty(remains)    % process the parameters not recognized
%                               % as positional or key-value arguments
%           error('HORACE:class_name:invalid_argument',...
%               ['Class constructor has been invoked with non-recognized ',...
%               'parameters: %s'], disp2str(remains));
%       end
%           :


% Case of no input arguments
% *** shouldn't this be generalised to numel(varargin)==0?
if nargin == 1
    remains = {};
    return;
end

% Parse options
if ~isstruct(options)
    % Backwards compatibility
    support_dash_option = options;
    mandatory_properties = [];
else
    support_dash_option = options.key_dash;
    mandatory_properties = logical(options.mandatory_props);   % ensure Boolian
end

% Turn off property interdependence validation so that property values can be
% set without interdependency checking
obj.do_check_combo_arg_ = false;

% Parse input arguments to determine the presence of keywords
[obj, remains, key_ind, key_pos, val_pos, is_positional, argi] = ...
    parse_keyval_argi(obj, positional_arg_names, support_dash_option, varargin{:});

% Check that the number of positional arguments does not exceed the number
% of parameter names
n_positional_arg_names = numel(positional_arg_names);
n_positional = sum(is_positional);
if n_positional> n_positional_arg_names
    if all(is_positional)
        n_positional_arg_names                = numel(positional_arg_names);
        n_positional                          = n_positional_arg_names;
        pos_remains                           = is_positional;
        pos_remains(1:n_positional_arg_names) = false;
        is_positional                         = ~pos_remains;
        remains = [remains(:);argi(pos_remains)'];
        argi = argi(is_positional);
    else
        error('HERBERT:serializable:invalid_argument',...
            ['More positional arguments identified: (%d) then positional values allowed: (%d).\n', ...
            ' Looks like some keys from key-value pairs have been identified as property values'],...
            n_positional, n_positional_arg_names)
    end
end
% Check that mandatory property assignment will be performed
% Do this check before changing the object properties, which might be an
% expensive procedure
if ~isempty(mandatory_properties)
    property_set = false(1,n_positional_arg_names);
    property_set(1:n_positional) = true;
    property_set(key_ind) = true;
    mandatory_missing = (mandatory_properties & ~property_set);
    %    if ~all(property_set(mandatory_properties))
    if any(mandatory_missing)
        properties_not_set = positional_arg_names(mandatory_missing);
        error('HERBERT:serializable:invalid_argument',...
            ['One or more class %s constructor mandatory properties have not been provided\n', ...
            'These properties are: %s\n'], ...
            class(obj), disp2str(properties_not_set));
    end
end

% Process positional arguments first
if any(is_positional)
    pos_arg_val   = argi(is_positional);
    pos_arg_names = positional_arg_names(1:n_positional);
    for i=1:n_positional
        obj.(pos_arg_names{i}) = pos_arg_val{i};
    end
end

% Now process keyword-value pairs
for i=1:numel(key_pos)
    obj.(argi{key_pos(i)}) = argi{val_pos(i)};
end

% Now check for interdependency of properties
obj.do_check_combo_arg_ = true;
obj=obj.check_combo_arg();

end


%-------------------------------------------------------------------------------
function [obj, remains, key_ind, key_pos, val_pos, is_positional, argi] = ...
    parse_keyval_argi (obj, arg_names, support_dash_option, varargin)
% find keys, corresponding to key arguments and set up object to the values
% which follow the keys in the cellarray of input arguments

% Determine the positions of keywords, and update the values of the input
% arguments to the unabbreviated keywords, stripped of any leading '-' if the
% dash option is permitted
[is_key, indx_key, deprecated_fields, argi] = is_char_key_member (obj, arg_names, ...
    support_dash_option, varargin{:});

% Warning message if any keyword arguments began with '-'
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
if any(is_key)
    % One or more keywords found in the argument list

    % Assign arguments that appear before the first keyword as positional
    % arguments
    key_pos = find(is_key);
    key_ind = indx_key(is_key);    % extract the non-zero values
    if key_pos(1)>1
        is_positional(key_pos(1):end) = false;
    else
        is_positional(1:end) = false;
    end

    % Check all keywords had a corresponding argument
    val_pos = key_pos + 1;
    if val_pos(end)>numel(varargin) || any(ismember(key_pos,val_pos))
        error('HERBERT:serializable:invalid_argument', ...
            ['should be even number of key-value pairs, but some keys do not ',...
            'have corresponding value argument'])
    end

    % Determine any arguments not matches to keyword-value pairs
    is_key(val_pos) = true;
    remains = varargin(~is_key & ~is_positional);


else
    % All arguments are assumed to be positional
    key_ind = [];
    key_pos = [];
    val_pos = [];
    remains = {};
end

end


%-------------------------------------------------------------------------------
function [is_key, indx_key, deprecated_fields, argi] = is_char_key_member ...
    (obj, key_list, support_dash_option, varargin)
% Identify character keys belonging to the provided cellarray within the list of
% the inputs parameters
%
%   >> [is_key, deprecated_fields, argi] = is_char_key_member ...
%                   (obj, key_list, support_dash, arg1, arg2, arg3,...argN)
%
% Input:
% ------
%   obj             Object; used to check class and length of properties in
%                   order to be forgiving about interpretation of keywords.
%
%   key_list        Cellstr of permitted keywords.
%
%   support_dash_option     If true, also allow the keywords to begin with '-'
%
% Output:
% -------
%   is_key          Logical array length N; true where an argument is a keyword,
%                   false where not.
%
%   indx_key        Numeric array length N; non-zero value is index of keyword
%                   in key_list
%
%   deprecated_fields   Cell array with fields that begin with '-' that were
%                       interpreted as keywords. Only filled if support_dash is
%                       true.
%
%   argi            Cell array length N, of input arguments arg1, arg2,...argN,
%                   but updated to hold full keyword names where arguments were
%                   identified as being valid abbreviations of keywords.
%
% NOTE:
%
% The outline of this algorithm is as follows:
% Progress along the arguments, assigning values as positional arguments, until
% a keyword is encountered in the argument list. From that point, search for
% keyword-value pairs.
%
% As of 30/6/23 the algorithm has some unexpected behaviour:
%
% * Marching through the arguments (starting with the assumption they are
%   positional) then if an argument is encountered that is a valid abbreviation
%   of a keyword, and the class of the corresponding positional property in obj
%   is a character, then the argument will be assumed to be a new value for that
%   property unless it is an exact match of the keyword. While peculiar, this is
%   a design decision albeit it unexpected by a user or developer.
%
% * If keywords beginning with '-' are forbidden, the first occurence will still
%   be accepted as a keyword. This is a bug, but a test  explicitly checks that
%   this occurs.
%
% * Checks of keyword-value pairing and the handling of multiple occurences of
%   properties (either by appearing in the positional and key-val lists, or
%   appearing twice as a key-val) are completed by the caller.


is_key = false(1,numel(varargin));
indx_key = zeros(1,numel(varargin));
if support_dash_option
    is_deprecated = false(1,numel(varargin));
end
deprecated_fields = {};

% Initialise state of keyword search
argi = varargin;
in_pos_parameters = true;   %
prev_input_is_key = false;  % previous parameter was a keyword

for i=1:numel(varargin)
    min_comp_base = 4; % define minimal number of letters in abbreviation plus 1
    arg = varargin{i};
    if in_pos_parameters % check has not exceeded the range of positional parameters
        in_pos_parameters = (i<=numel(key_list));
    end
    if ~(ischar(arg)||isstring(arg))
        % Argument cannot be a keyword (as not character array or string)
        % Move to next argument
        prev_input_is_key = false;
        continue;
    end
    if prev_input_is_key
        % Is a character array or string, but
        % Argument cannot be
        prev_input_is_key = false;
        continue;
    end
    if in_pos_parameters
        % Is a character array or string in the positional args if got this far.
        % Determine if the corresponding property is already a character string;
        % if it is, then it may be that the argument is a new value, so lets be
        % cautious and demand that the argument is a full match to a keyword.

        % if char value starts with '-' its probably a key
        if ischar(obj.(key_list{i})) || isstring(obj.(key_list{i}))
            if strncmp(arg,'-',1)
                arg = extractAfter(arg,1);
            else % if it not starts with '-' and can be still the key so we
                %  need full comparison with some key name
                min_comp_base = inf;
            end
        end
    end

    if support_dash_option
        matches_key = cellfun(@(x)compare_par(arg,x,min_comp_base),key_list);
        matches_depr_key = cellfun(@(x)compare_par(arg,['-',x],min_comp_base+1),key_list);
        if any(matches_depr_key)
            is_deprecated(i) = true;
        end
        matches_key = matches_key|matches_depr_key;
    else
        matches_key = cellfun(@(x)compare_par(arg,x,min_comp_base),key_list);
    end

    found = sum(matches_key);
    if found>1
        error('HERBERT:serializable:invalid_argument',...
            ['Input key N%d (%s) can non-uniquely define more then one ',...
            'possible property:\n[%s].\n Can not interpret this key'],...
            i, arg, disp2str(key_list(matches_key)));
    elseif found == 1
        if prev_input_is_key
            error('HERBERT:serializable:invalid_argument',...
                ['Two adjacent input parameters N%d and N%d are identified as keys:\n',...
                '(%s and %s). Something is wrong'],...
                i-1, i, argi{i-1}, key_list{matches_key})
        end
        prev_input_is_key = true;
        in_pos_parameters = false; % first key indicates positional parameters are finished
        is_key(i) = true;
        indx_key(i) = find(matches_key);
        argi{i}= key_list{matches_key};
        if support_dash_option && any(is_deprecated)
            deprecated_fields = varargin(is_deprecated);
        end
    else
        prev_input_is_key = false;
    end
end

end


%-------------------------------------------------------------------------------
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

end

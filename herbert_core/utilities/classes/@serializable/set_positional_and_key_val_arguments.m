function [obj, remains] = set_positional_and_key_val_arguments (obj, ...
    positional_param_names_list, old_keyval_compat, varargin)
% Utility function to parse the input to a serializable class constructor
% It allows the constructor parameters to be specified with the syntax:
%
%   ObjConstructor (positional_par1, positional_par2, positional_par3,...
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


[obj,remains] = ...
    set_positional_and_key_val_arguments_(obj,...
    positional_param_names_list,old_keyval_compat,varargin{:});

end

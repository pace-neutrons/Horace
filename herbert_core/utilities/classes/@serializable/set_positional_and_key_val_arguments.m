function [obj, remains] = set_positional_and_key_val_arguments (obj, ...
    positional_param_names_list, old_keyval_compat, varargin)
% Utility method, to use in a serializable class constructor,
% allowing to specify the constructor parameters in the form:
%
% ObjConstructor(positional_par1,positional_par2,positional_par3,...
% positional_par...,key1,val1,key2,val2,...keyN,valN);
%
% The keys are the names of the properties and the values are
% the values of the properties to set.
% The positional parameters are intended to be the values of
% the properties with names defined in the
% positinal_param_names_list list.
%
% Everything not identified as positional parameters or
% Key-Value pair is returned in remains cellarray
%
% Input:
% ------
% positional_param_names_list
%            -- cellarray of positional parameter names,
%               coinciding with the names of the properties the
%               function is called to set
% old_keyval_compat
%            -- if set to true, keys in varargin may have form
%               '-keyN' in addition to 'keyN'. Deprecation
%                warning is issued for this kind of names.
% varargin   -- cellarray of the constructor inputs, in the
%               form, described above.
%
% End of positional parameters list is established by finding
% in varargin the element, belonging to the
% positinal_param_names_list  (first key)
%
% If the same property is defined using positional parameter
% and as key-value pair, the key-val parameter value takes
% priority.
%
%
% EXAMPLE:
% if class have the properties {'a1'=1, 'a2'='blabla',
% 'a3'=sqw() 'a4=[1,1,1], 'a5'=something} and these properties
% are the independent properties defining the state of the
% object and provided in positional_param_names_list as:
% ppp = {'a1','a2','a3','a4','a5'}
% Then the call to the function with the list of input parameters:
% varargin = {1,'blabla',an_sqw_obj,'a4',[1,0,0],'blabla'}
% in the form:
%>> [obj,remains] = set_positional_and_key_val_arguments(obj,ppp,false,varargin{:});
%
% sets up the three first arguments as positional parameters,
% for properties a1,a2 and a3, a4 is set as key-value pair,
% 'blabla' is returned in remains and property a5 remains
% unset.
%
%
[obj,remains] = ...
    set_positional_and_key_val_arguments_(obj,...
    positional_param_names_list,old_keyval_compat,varargin{:});
%
% Simple Code sample to insert into new object constructor
% to use this function as part of generic constructor:
%
% flds = obj.saveableFields();
% [obj,remains] = obj.set_positional_and_key_val_arguments(...
%        flds,false,varargin{:});
%  if ~isempty(remains) % process the parameters not recognized
%                       % as positional or key-value arguments
%      error('HORACE:class_name:invalid_argument',...
%           ' Class constructor has been invoked with non-recognized parameters: %s',...
%                         disp2str(remains));
%  end

end

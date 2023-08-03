function obj = from_bare_struct_ (obj_template, S)
% Restore object or object array from a structure
%
%   >> obj = from_bare_struct_ (obj_template, S)
%
% Input:
% ------
%   obj_template    Scalar instance of the class to be recovered.
%                   This is needed because the structure created by the method
%                  to_bare_struct does not contain the class type. The object
%                  is used to provide the class to be recovered, and the value
%                  of any missing properties if recovering from an older
%                  version.
%
%   S               Structure or structure array of data with the structure as
%                  created by the method to_bare_struct.
%                   Note that structures created by to_struct (i.e. with the
%                  fields 'serial_name', 'version' and (if from an array of
%                  objects) 'array_dat' are *NOT* valid.
%
% Output:
% -------
%   obj             Object or array of objects of the same class as the input
%                  argument obj_template.


% *** Special case
% Catch the case of an empty input structure with no fields as meaning
% just return the template object. This is because we have used the case of
% such a structure as meaning 'not assigned' in the past. This is possibly
% poor design as a valid object to save/load is one with no fields and no
% size. Serializable also interprets an empty object *with* fields in the
% same way - again possibly inconsistent design. Catch this case too until
% a robust design is made.
if numel(S)==0
    obj = obj_template;
    return
end

% Create default output object array to be updated from the input structure
nobj = numel(S);
if nobj == 1
    obj = obj_template;
else
    if isequal(size(obj_template),size(S))
        obj = obj_template;        
    else
        obj = repmat(obj_template(1), size(S));
    end
end

% Find the fields to be set from the structure
% (The complex verification of intersection of input and output fields is
% necessary for supporting classes with a variable field set depending on the
% state of the object. Also support inheritance, when partial object
% (parent) is restored from full child structure. The question if one should
% allow this to happen - for example heterogeneous arrays - remains open.
fields_to_set = obj_template.saveableFields();
fields_present = fieldnames(S);
is_present = ismember (fields_to_set, fields_present);
if ~any(is_present)
    % There are no fields in the object to recover that are in the structure, so
    % the return object is just the template object, suitably repeated to the
    % size of the inoput structure.
    return;
end
if ~all(is_present)
    fields_to_set = fields_to_set(is_present);
end

% There are properties to be set from the input structure
% Set properties without checking interdependecies by turning off the method
% check_combo_arg, turning on and performing the check only when all properties
% have been updated.

for i=1:nobj
    obj(i).do_check_combo_arg_ = false;
    obj(i) = set_obj (obj(i), S(i), fields_to_set);
    obj(i).do_check_combo_arg_ = true;
    % Check interdependent properties. If the object is invalid, an
    % exception is thrown
    obj(i) = obj(i).check_combo_arg();
end
if nobj > 1
    obj = reshape(obj,size(S));
end

end

%-------------------------------------------------------------------------------
function obj = set_obj (obj, S, fields_names)
% Set properties of an object from the named fields of the scalar structure S
%
%   >> obj = set_obj (obj, S, fields_names)
%
% Note that this function is recursive in that a field that contains a structure
% that corresponds to a serializable object it is sent to from_struct to recover
% the object.

for i=1:numel(fields_names)
    field_name = fields_names{i};
    val = S.(field_name);
    if isstruct(val)
        if isfield(val,'serial_name')
            % Structure is one that has been created by to_struct
            val = serializable.from_struct (val);
        end
    end
    obj.(field_name) = val;
end

end

function S = to_bare_struct_ (obj, recursive_bare)
% Convert a serializable object or array of objects into a structure
%
%   >> S = to_bare_struct_ (obj)
%   >> S = to_bare_struct_ (obj, recursive_bare)
%
% Input:
% ------
%   obj             Object or array of objects which are serializable i.e.
%                  which belong to a child class of serializable
%
%   recursive_bare  Logical true or false
%                   If false, nested properties that are serializable objects
%                  are converted to structures using the public method
%                  to_struct. That is, they contain the information about the
%                  class name and version.
%                   If true, then they are converted to the bare structure using
%                  to_bare_struct.
%
% Output:
% -------
%   S               S is a structure array, each element of the array being the
%                  structure created from one object. The field names match the
%                  property names returned from the method saveableFields.


% Get saveable fields
field_names = saveableFields (obj(1));

% Recursively turn serializable fields into structures
cell_dat = cell (numel(field_names), numel(obj));
for j = 1:numel(obj)
    obj_tmp = obj(j);   % get pointer to jth object to save expensive indexing
    for i = 1:numel(field_names)
        field_name = field_names{i};
        val = obj_tmp.(field_name);
        if isa(val,'serializable')
            % Recursively convert serializable objects to a structure
            % Serializer will handle non-serializable objects by its own
            % internal converters.
            if recursive_bare
                %
                % === TGP 2023-06-04: ==========================================
                % Change from calling to_bare_struct_ to the public (and
                % therefore possibly overloaded) to_bare_struct.
                % Makes consistent with behaviour using to_struct below, and
                % with the call to to_bare_struct in to_struct_
                val= to_bare_struct (val, recursive_bare);
            else
                % Uses public (therefore possibly overloaded) method
                % It contrasts with the original behaviour of calling
                % to_bare_struct_ above, now changed.
                val= to_struct (val);
            end
        end
        cell_dat{i,j} = val;
    end
end

% Package into output structure
S = cell2struct (cell_dat, field_names, 1);
if numel(obj)>1
    S = reshape(S,size(obj));
end

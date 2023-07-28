function [obj,remains] = init_(obj,varargin)
% build non-empty oriented lattice from any form of constructor input
% including positional arguments, defined in the order, returned by
% saveableFields function (i.e. 'psi','u','v'...etc.)
%
remains = {};
if isa(varargin{1},'goniometer') % copy constructor
    obj = obj.from_bare_struct(varargin{1}.to_bare_struct());
    if numel(varargin)>1
        remains = varargin(2:end);
    end
elseif isstruct(varargin{1}) % structure with oriented lattice fields
    [is,value,input] = obj.check_angular_units_present(varargin{:});
    if is % the constructor defines specific units for
        % the angular values. It has to be set first
        obj.angular_units = value;
    end

    obj = obj.from_bare_struct(input);
    if numel(varargin)>1
        remains = varargin(2:end);
    end
elseif isnumeric(varargin{1}) || ischar(varargin{1}) % the initialization is done by positional
    % arguments followed by key-value pairs or numeric positional arguments
    % followed (optionally) by key-value pairs
    %
    flds = obj.saveableFields();
    [is,value,argi] = obj.check_angular_units_present(varargin{:});
    if is% the constructor defines specific units for
        % the angular values. It has to be set first
        obj.angular_units = value;
    end
    obj = set_positional_and_key_val_arguments(obj,flds,false,argi{:});
else
    error('HERBERT:goniometer:invalid_argument',...
        ['goniometer may be constructed only with an input structure,'...
        ' containing the same fields as public fields of the goniometer itself or'...
        ' using constructor,containing positional arguments and key-value pairs']);
end

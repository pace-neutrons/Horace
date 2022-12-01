function [obj,remains] = build_oriented_lattice_(obj,varargin)
% build non-empty oriented lattice from any form of constructor input
% including positional arguments, defined in the order, returned by
% saveableFields function (i.e. 'alatt','angdeg','psi','u','v'...etc.)
%
remains = {};
if isa(varargin{1},'oriented_lattice') % copy constructor
    obj = varargin{1};
    if numel(varargin)>1
        remains = varargin(2:end);
    end
elseif isstruct(varargin{1}) % structure with oriented lattice fields
    input = varargin{1};
    if isfield(input,'angular_units') % the constructor defines specific units for
        % the angular values. It has to be set first
        obj.angular_units = input.angular_units;
        input = rmfield(input,'angular_units');
    end
    obj = obj.from_bare_struct(input);
    if numel(varargin)>1
        remains = varargin(2:end);
    end
elseif isnumeric(varargin{1}) || ischar(varargin{1}) % the initialization is done by positional
    % arguments followed by key-value pairs or numeric positional arguments
    % followed (optionally) by key-value pairs
    %
    pos_par_names = oriented_lattice.lattice_parameters_;
    pos_deg = numel(pos_par_names); % The location of deg/rad argument as positonal argument
    if numel(varargin)>=pos_deg && ischar(varargin{pos_deg}) && ismember(varargin{pos_deg},{'deg','rad'})
        % deg/rad argument is present as last postional argument
        obj.angular_units = varargin{pos_deg};

        keep = true(1,numel(varargin));
        keep(pos_deg) = false;
        if strcmp(varargin{pos_deg-1},'angular_units')
            keep(pos_deg-1) = false;
        end
        argi = varargin(keep);
    else
        argi = varargin;
    end
    is_ang = cellfun(@(x)ischar(x)&&strcmp(x,'angular_units'),argi);
    if any(is_ang) % the constructor defines specific units for
        % the angular values. It has to be set first
        au_key_num = find(is_ang);
        au_val_num = au_key_num +1;
        obj.angular_units = argi{au_val_num};
        is_ang(au_val_num) = true;
        argi = argi(~is_ang);
    end
    obj = set_positional_and_key_val_arguments(obj,...
        pos_par_names,false,argi{:});
else
    error('HERBERT:oriented_lattice:invalid_argument',...
        ['oriented lattice may be constructed only with an input structure,'...
        ' containing the same fields as public fields of the oriented lattice itself or'...
        ' using constructor,containing positional arguments and key-value pairs']);
end
if ~isempty(remains)
    error('HERBERT:oriented_lattcie:invalid_argument',...
        'The lattice constructor provided with unrecognized extra argument(s): %s',...
        evalc('disp(remains)'));
end



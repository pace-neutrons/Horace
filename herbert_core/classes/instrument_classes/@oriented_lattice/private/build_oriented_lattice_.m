function [obj,remains] = build_oriented_lattice_(obj,varargin)
% build non-empty oriented lattice from any form of constructor input
% including positional arguments, defined in the order, returned by
% indepFields function (i.e. 'alatt','angdeg','psi','u','v'...etc.)
%
remains = {};
if isa(varargin{1},'oriented_lattice') % copy constructor
    obj = varargin{1};
    if numel(varargin)>1
        remains = varargin(2:end);
    end
elseif isstruct(varargin{1}) % strucure with oriented lattice fields
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
    [input,remains] = convert_inputs_to_structure(obj,varargin{:});
    if isfield(input,'angular_units') % the constructor defines specific units for
        % the angular values. It has to be set first
        obj.angular_units = input.angular_units;
        input = rmfield(input,'angular_units');
    end
    obj = obj.from_bare_struct(input);
else
    error('HERBERT:oriented_lattcie:invalid_argument',...
        ['oriented lattice may be constructed only with an input structure,'...
        ' containing the same fields as public fields of the oriented lattice itself or'...
        ' using constructor,containing positional arguments and key-value pairs']);
end
if ~isempty(remains)
    error('HERBERT:oriented_lattcie:invalid_argument',...
        'The lattice constructor provided with unrecognized extra argument(s): %s',...
        evalc('disp(remains)'));
end

[ok,mess,obj] = check_combo_arg_(obj);
if ~ok
    error('HERBERT:oriented_lattcie:invalid_argument',mess);
end
%
function  [input,remains] = convert_inputs_to_structure(obj,varargin)
% All possible parameters
remains = {};
key_names = obj.lattice_parameters_;

% find if deg/rad option is provided
deg_rad = cellfun(@(x)(strncmp(x,'deg',3)||strncmp(x,'rad',3)),varargin);
deg_rad_ind = find(deg_rad);
if ~isempty(deg_rad_ind )&& deg_rad_ind>1
    % is angular_units key located before deg|rad value
    % or deg|rad is provided as positional argument?
    deg_rad_key = deg_rad_ind-1;
    is_reg_rad_key = ischar(varargin{deg_rad_key}) && ...
        strcmp(varargin{deg_rad_key},'angular_units');
else
    is_reg_rad_key= false;
end
% remove deg/rad option from the list of the input options
non_deg_rad = true(1,numel(varargin));
if is_reg_rad_key
    non_deg_rad(deg_rad_key) = false;
    non_deg_rad(deg_rad_ind) = false;
    key_names = key_names(1:end-1); % deg_rad key is the last key in the sequence
else
    if ~isempty(deg_rad_ind)
        non_deg_rad(deg_rad_ind) = false;
        key_names = key_names(1:end-1); % deg_rad key is the last key in the key sequence
    end
end
argi = varargin(non_deg_rad);

% identify how many positional numeric parameters are there
is_num = cellfun(@isnumeric,argi);
key_pos = find(~is_num);
if isempty(key_pos)
    last_pos_ind = numel(is_num);
else
    last_pos_ind = key_pos(1)-1;
end
if all(is_num)
    all_keys = key_names(is_num);
    values    = argi;
else
    assumed_keys = key_names(1:last_pos_ind);
    provided_keys = argi(~is_num);
    values = argi(is_num);
    all_keys = [assumed_keys,provided_keys];
end
if numel(values)< numel(all_keys)
    all_keys = all_keys(1:last_pos_ind);
elseif numel(values)> numel(all_keys)
    remains = values(numel(all_keys):1:end);
end
input =  cell2struct(values, all_keys,2);

if ~isempty(deg_rad_ind)
    input.angular_units = varargin{deg_rad_ind};
else
    input.angular_units = obj.angular_units; %use default value
end
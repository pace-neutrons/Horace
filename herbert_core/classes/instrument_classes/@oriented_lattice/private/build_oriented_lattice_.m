function obj = build_oriented_lattice_(obj,varargin)
% build oriented lattice from any form of constructor input
%


if isa(varargin{1},'oriented_lattice') % copy constructor
    obj = varargin{1};
elseif isstruct(varargin{1})
    input = varargin{1};
    field_names = fieldnames(input);
    %obj.undef_fields_ = ~ismember(obj.fields_to_define_,field_names);
    for i=1:numel(field_names)
        obj.(field_names{i}) = input.(field_names{i});
    end
elseif isnumeric(varargin{1}) && numel(varargin{1}) == 3 % non-empty
    arglist = obj.struct('-all');
    [par,argout,present,~,ok,mess] = parse_arguments(varargin,arglist);
    if ~ok
        error('ORIENTED_LATTICE:invalid_argument',mess);
    end
    if ~isempty(par)
        lf = obj.lattice_fields();
        pos_fields = lf(1:numel(par));
        for i=1:numel(pos_fields)
            obj.(pos_fields{i}) = par{i};
        end
    end
    names=fieldnames(argout);
    def_names =names(cell2mat(struct2cell(present)));
    for i=1:numel(def_names )
        obj.(def_names {i}) = argout.(def_names {i});
    end
else
    error('ORIENTED_LATTICE:invalid_argument',...
        ['oriented lattice may be constructed ony with input structure,'...
        ' containing the same fields as public fields of the oriented lattice itself or '...
        'using constructor, containing positional parameters']);
end



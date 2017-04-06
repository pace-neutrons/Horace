function lattice = build_oriented_lattice_(lattice,varargin)

if isa(varargin{1},'oriented_lattice')
    lattice = varargin{1};
elseif isstruct(varargin{1})
    input = varargin{1};
    field_names = fieldnames(input);
    for i=1:numel(field_names)
        lattice.(field_names{i}) = input.(field_names{i});
    end
else
    error('ORIENTED_LATTICE:invalid_argument',...
        'oriented lattice may be constructed ony with input structure, containing the same fields as public fields of the oriented lattice itself');    
end
end





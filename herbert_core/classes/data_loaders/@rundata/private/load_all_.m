function this = load_all_(this,reload)
% Method to load or reload all data from attached data file using defined
% loader
%
%
if reload
    this.loader_ = this.loader_.load();
else
    this.loader_ = this.loader_.load('-keepexisting');
end

def_fields = this.loader_.loader_define();
if ismember('efix',def_fields)
    if reload || isempty(this.efix_)
        this.efix_ = this.loader.efix;
    end
end

lattice_fields = oriented_lattice.lattice_fields;
lattice_loaded = ismember(def_fields,lattice_fields);
if any(lattice_loaded)
    lat_fields=def_fields(lattice_loaded);
    if isempty(this.oriented_lattice_)
        lat  = oriented_lattice();
    else
        lat = this.oriented_lattice_;
    end
    for i=1:numel(lat_fields)
        fld =lat_fields{i};
        if reload || ~lat.is_defined(fld)
            lat.(fld) = this.loader_.(fld);
        end
    end
    this.oriented_lattice_ = lat;
end

function val=get_field(this,field_name)

if ismember(field_name,oriented_lattice.lattice_fields())
    val = this.lattice.(field_name);
else
    val = this.(field_name);
end
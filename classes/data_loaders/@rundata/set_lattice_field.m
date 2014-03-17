function this = set_lattice_field(this,name,val,varargin)
% method sets a field of  lattice if the lattice
% present and initates the lattice first if it is not present
%Usage: 
%>>rundata_instance=set_lattice_field(rundata_instance,'psi',20);
%>>rundata_instance=set_lattice_field(rundata_instance,'psi',20,'-ifempty');
%
% -ifempty -- if this option is present, lattice field is set only if it is
%             undefined
%
options = {'-ifempty'};
if isempty(this.oriented_lattice__)
    this.oriented_lattice__ = oriented_lattice();
    if_empty = false;
else
    [ok,mess,if_empty]=parse_char_options(varargin,options);
    if ~ok
        error('RUNDATA:set_lattice_field',mess);
    end
end
if if_empty
    if isempty(this.oriented_lattice__.(name))
        this.oriented_lattice__.(name)=val;
    end
else
    this.oriented_lattice__.(name)=val;
end


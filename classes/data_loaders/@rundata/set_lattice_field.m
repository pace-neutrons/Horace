function this = set_lattice_field(this,name,val,varargin)
% method sets a field of  lattice if the lattice
% present and initates the lattice first if it is not present
%Usage:
%>>rundata_instance=set_lattice_field(rundata_instance,'psi',20);
%>>rundata_instance=set_lattice_field(rundata_instance,'psi',20,'-ifempty');
%>>rundata_instance=set_lattice_field(rundata_instance,'psi',20,'-if_undef');
%
% -ifempty if_undef -- if one of these options is present, lattice field
%                      is set only if it is undefined
%
options = {'-ifempty','-if_undef'};
if isempty(this.oriented_lattice__)
    this.oriented_lattice__ = oriented_lattice();
    if_empty = false;
else
    [ok,mess,if_empty,if_undef]=parse_char_options(varargin,options);
    if ~ok
        error('RUNDATA:set_lattice_field',mess);
    end
    if_empty = if_empty||if_undef;
end
if if_empty
    if ~this.oriented_lattice__.is_defined(name)
        this.oriented_lattice__.(name)=val;
    end
else
    this.oriented_lattice__.(name)=val;
end


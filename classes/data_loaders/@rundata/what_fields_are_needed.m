function [data_fields,lattice_fields] = what_fields_are_needed(this,varargin)
% Returns the list data fields which have to be defined by the run for cases of crystal or powder experiments
data_fields = rundata.main_data_fields();
lattice_fields=[];

if this.is_crystal || nargin> 1
    lattice_fields = oriented_lattice.lattice_fields();
    data_fields = {data_fields{:},lattice_fields{:}};
end

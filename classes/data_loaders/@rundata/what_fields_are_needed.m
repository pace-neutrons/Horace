function [data_fields,lattice_fields] = what_fields_are_needed(this,varargin)
% Returns the list data fields which have to be defined by the run for cases
% of crystal or powder experiments
data_fields = rundata.main_data_fields();
lattice_fields=[];
crystal_needed = this.is_crystal;
if ~crystal_needed
    if nargin == 2 
        if strcmpi(varargin{1},'all_fields')
            crystal_needed = true;
        end
    end
end

if ~crystal_needed
    if nargin>1
        lattice_fields = oriented_lattice.lattice_fields();
        if any(ismember(varargin{:},lattice_fields))
            crystal_needed = true;
        else
            lattice_fields =[];
        end
    end
end
if crystal_needed
    if isempty(lattice_fields)
        lattice_fields = oriented_lattice.lattice_fields();
    end
    data_fields = [data_fields,lattice_fields];
end


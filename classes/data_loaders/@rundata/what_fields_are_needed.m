function data_fields = what_fields_are_needed(this)
% Returns the list data fields which have to be defined by the run for cases of crystal or powder experiments

if this.is_crystal
    data_fields = {'efix','en','S','ERR','det_par','alatt','angldeg','psi','omega','dpsi','gl','gs','u','v'};
else
    data_fields = {'efix','en','S','ERR','det_par'};
end

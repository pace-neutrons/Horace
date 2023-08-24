function obj = check_combo_arg_(obj)
% Validate lattice parameters which depend on each other.
%

uf = obj.get_undef_fields();
% check the fields that have to be defined for the object to make sense
if ~isempty(uf)
    obj.isvalid_ = false;
    undef_fields_mess = strjoin(uf,'; ');
    obj.reason_for_invalid_ =  sprintf( ...
        'The necessary field(s): %s remain undefined so the lattice is invalid',...
        undef_fields_mess);
    return;
end
obj.isvalid_ = true;
obj.reason_for_invalid_ = '';

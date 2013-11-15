function [pulse_model,pp,ok,mess] = pulse_shape_parameters(win)
% Return the fixed neutron energy for an array of sqw objects. Error if not the same in all objects.
%
%   >> [pulse_model,pp,ok,mess] = pulse_shape_parameters(win)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
%
% Output:
% -------
%   efix_val    Fixed neutron energy (meV)
%   ok          Logical flag: =true if all ok, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise

[pulse_model,pp,ok,mess]=pulse_shape_parameters_single(win(1));
if ~ok
    if nargout<2, error(mess), else return, end
end
for i=2:numel(win)
    [pulse_model_tmp,pp_tmp,ok,mess]=pulse_shape_parameters_single(win(i));
    if ~ok
        if nargout<2, error(mess), else return, end
    elseif ~strcmp(pulse_model_tmp,pulse_model_tmp) || ~isequal(pp,pp_tmp)
        ok=false; mess='Not all moderator pulse shape models and parameters in the array of sqw objects are the same';
        if nargout<2, error(mess), else return, end
    end
end

%------------------------------------------------------------------------------
function [pulse_model,pp,ok,mess]=pulse_shape_parameters_single(w)
% Determine if the moderator pulse shape name, and moderator pulse shape parameters
% are the same for an array of moderator objects
moderator=get_instrument_component(w,'moderator');
pulse_model=moderator(1).pulse_model;
pp=moderator(1).pp;
for i=2:numel(moderator)
    if ~isequal(moderator(i).pulse_model,pulse_model) || ~isequal(moderator(i).pp,pp)
        pulse_model=[];
        pp=[];
        ok=false; mess='Not all moderator pulse shape models and parameters are the same within one sqw object';
        return
    end
end
ok=true; mess='';

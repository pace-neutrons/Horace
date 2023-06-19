function obj = check_combo_arg (obj)
% Check validity of interdependent properties, updating them where necessary
%
%   >> obj = check_combo_arg (obj)
%
% Overload this method for your particular child class, and implement the check
% in all interdependent properties setters of your class with the following
% block of code:
%               :
%           if obj.do_check_combo_arg_
%               obj = check_combo_arg (obj);
%           end
%               :
%
% Method functionality:
% - The method must throw an error if the properties are not consistent.
% - Update properties of the object if necessary
% - Recompute any cached properties that are derived from the set properties,
%   for example a probability distribution lookup table. Additional input
%   arguments can be provided to check_combo_arg ensure that this is only
%   done when necessary. For an example, see IX_fermi_chopper/check_combo_arg.
%
% EXAMPLE
%
%       function obj = set.wall (obj, val)
%           % Independent validy check:
%           if any(val(:)<0)
%               error ('HERBERT:IX_det_He3tube:invalid_argument',...
%                   'Wall thickness(es) must be greater or equal to zero')
%           end
%           obj.wall_ = val(:);
%
%           % Now check interdependencies:
%           if obj.do_check_combo_arg_
%               obj = obj.check_combo_arg();
%           end
%       end


% This method is the default and performs no function. Overload the method for
% your purposes

end

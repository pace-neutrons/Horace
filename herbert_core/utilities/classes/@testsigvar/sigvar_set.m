function w = sigvar_set(w, sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w, sigvarobj)
%
% Input:
% ------
%   w           Object whose signal and variance arrays will be updated
%   sigvarobj   Object of class sigvar which provides the new signal and
%               variance arrays


% Check input argument type and signal array sizes (generic checks fo any class)
classname = mfilename('class');
if ~isa(sigvarobj, 'sigvar')
    mess = 'Source of new signal and variance data must be a sigvar object';
    error([upper(classname),':binary_op_manager'], mess);
    
elseif ~isequal(sigvar_size(w), sigvar_size(sigvarobj))
    mess = [classname,' object and sigvar object have inconsistent sizes'];
    error([upper(classname),':binary_op_manager'], mess);

end

% Update signal (specific to particular class)
w = testsigvar(sigvarobj.s, sigvarobj.e, sigvarobj.msk);

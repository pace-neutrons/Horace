function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring

if ~isequal(size(w.signal),size(sigvarobj.s))
    error('IX_dataset:invalid_argument',...
        '%s and sigvar object have inconsistent sizes',class(w))
end
w.do_check_combo_arg = false;
w.signal=sigvarobj.s;
w.error =sqrt(sigvarobj.e);
w.do_check_combo_arg = true;
w = w.check_combo_arg();

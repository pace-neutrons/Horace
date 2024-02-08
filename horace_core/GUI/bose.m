function wout=bose(win,T)
% Correct a dataset for the bose population factor
% 
%   >> wout = (1 - exp(-en/kB*T)) * win


% RAE 7/12/09

%We can cheat here by making a dummy sqw function that returns the bose
%factor for all of the points:
sqw_bose=sqw_eval(win,@bose_factor,T);

% as bose and sqw_bose have the same pixels, and the same pixels
% coordinates, sorting pixels over bins are not necessary. This is why we
% set ignore_cell_sorting to true
wout = binary_op_manager(win,sqw_bose,@mtimes,true);



%==============================

function y = bose_factor(h,k,l,en,T)
%
y = (1 - exp(-11.6044.*en/T));


function y=demo_FM_spinwaves_2dSlice_sqw(qh,qk,ql,en,pars)
%
% Calculate the spectral weight from a Heisenberg ferromagnet for a Q-E slice
% with nearest-neighbour interactions only.
% Same model as in sqw_broad in Tobyfit.
%
% syntax:
%   >> wout= sqw_eval(win,@demo_FM_spinwaves,[pars],options)
%
% Input for function:
% ------
%   qh,qk,ql,en - arrays that are all the same size (or are scalars)
%                 that specify the co-ordinates for point in (Q,E)-space
%                 where you wish to calculate the intensity
%
% Output:
% -------
%   y    array the same size as the input arrays qvar and en.
%
% RAE 10/7/08

% trick to avoid divide by zero warning
% warning_status = warning('query');
% warning off
%=============================================

js=pars(1); delta=pars(2);
gam=pars(3); temp=pars(4); amp=pars(5);

omega0 = delta + ...
    (4*js)*((sin(pi.*qh)).^2 + (sin(pi.*qk)).^2 + (sin(pi.*ql)).^2);

Bose= en./ (1-exp(-11.602.*en./temp));%Bose factor from Tobyfit. 

%Use damped SHO model to give intensity:
y = amp.* (Bose .* (4.*gam.*omega0)./(pi.*((en.^2-omega0.^2).^2 + 4.*(gam.*en).^2)));


%=============================================
% return to original warning status
% warning(warning_status);
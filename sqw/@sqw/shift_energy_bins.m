function wout = shift_energy_bins (win, dispreln, pars)
% Shift the energy bins of a d1d object according to a dispersion relation
%
%   >> wout = shift_energy_bins (win, dispreln, pars)
%
% This routine is to be used to plot energy cuts that have been flattened
% using shift_pixels. It does not have meaning in any other context.
%
% Input:
% ------
%   win         Dataset (or array of datasets) that form constant-Q cuts
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q)
%              Must have the form:
%                   w = dispreln (qh,qk,ql,p)
%               where
%                 Input:
%                   qh,qk,ql    Arrays containing the coordinates of a set
%                              of points in reciprocal lattice units
%                   p           Vector of parameters needed by the function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                 Output:
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   w = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might
%                              want to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name of
%                              a look-up table.
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   'ave'       [option] Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%               Applies only to the case of sqw object with pixel information - it is
%              ignored if dnd type object.
%
% Output:
% -------
%   wout        Output dataset or array of datasets


% Check that all cuts are sqw-type constant-Q cuts
for i=1:numel(win)
    if is_sqw_type(win(i))   % determine if sqw or dnd type
        if ~(dimensions(win(i))==1 && win(i).data.pax==4)
            error('All cuts must be one-dimensional energy cuts')
        end
    else
        error('Not yet implemented for dnd objects')
    end
end

% Shift the energy bins
wout = win;
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

for i=1:numel(win)
    q = calculate_q_bins (win(i));
    wdisp=dispreln(q{:},pars{:});
    if iscell(wdisp)
        wdisp=wdisp{1};     % pick out the first dispersion relation
    end
    wout(i).data.p{1} = wout(i).data.p{1} + wdisp;
end

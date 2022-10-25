function [wout_disp, wout_weight] = dispersion(win, dispreln, pars)
% Calculate dispersion relation for dataset or array of datasets.
%
% New behaviour: Always returns appropriate dnd object. May be modified in
% a future.
%
% If the input contains array of sqw objects, the objects need to have the
% same number of dimensions (may be relaxed if requested)
%
%   >> wdisp = dispersion (win, dispreln, p)            % dispersion only
%   >> [wdisp,weight] = dispersion (win, dispreln, p)   % dispersion and spectral weight
%
% The output dataset (or array of data sets), wdisp, will retain only the Q axes, and
% the signal array(s) will contain the values of energy along the Q axes. If the
% dispersion relation returns the spectral weight, this will be placed in the error
% array (actually the square of the spectral weight is put in the error array). In the
% case when the dispersion has been calculated on a plane in momentum (i.e. wdisp
% is IX_datset_2d) then the plot function ps2 (for plot_surface2)
%   >> ps2(wdisp)
% will plot a surface with the z axis as energy and coloured according to the spectral
% weight.
%
% The dispersion relation is calculated at the bin centres (that is, the individual pixel
% information in a sqw input object is not used).
%
% If the function that calculates dispersion relations produces more than one
% branch, then in the case of a single input dataset the output will be an array
% of datasets, one for each branch. If the input is an array of datasets, then only
% the first dispersion branch will be returned, so there is one output dataset per
% input dataset.
%
% Input:
% ======
%   win         Dataset that provides the axes and points for the calculation
%               If one of the plot axes is energy transfer, then the output dataset
%              will have dimensionality one less than the input dataset
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q)
%              Must have form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                              in reciprocal lattice units
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%                   s           Array of spectral weights, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table.
%
%   p           Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%
% Output:
% =======
%   wdisp       Output dataset or array of datasets of the same type as the input argument.
%               The output dataset (or array of data sets) will retain only the Q axes, the
%              the signal array(s) will contain the values of energy along the Q axes, and
%              the error array will contain the square of the spectral weight.
%               If the function that calculates dispersion relations produces more than one
%              branch, then in the case of a single input dataset the output will be an array
%              of datasets, one for each branch. If the input is an array of datasets, then only
%              the first dispersion branch will be returned, so there is one output dataset per
%              input dataset.
%
%   weight      Mirror output: the signal is the spectral weight, and the error array
%               contains the square of the frequency.
%
%   e.g.        If win is a 2D dataset with Q and E axes, then wdisp is a 1D dataset
%              with just the Q axis


if ~iscell(pars)   % package parameters as a cell for convenience
    pars={pars};
end

wout_disp = win(1).data;
if numel(win)>1
    wout_disp = repmat(wout_disp,size(win));
end
if nargout>1
    [wout_disp,wout_weight] = dispersion(wout_disp,dispreln,pars);
else
    wout_disp = dispersion(wout_disp,dispreln,pars);    
end

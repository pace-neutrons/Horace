function [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in)
% Take parameters and sqw object and realign the crystal, stripping parameters
%
%   >> [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in)
%
% Input:
% ------
%   win         Single sqw object
%
%   xtal        Crystal refinement constants. Structure with fields:
%                   urot        x-axis for rotation (r.l.u.)
%                   vrot        Defines y-axis for rotation (r.l.u.): y-axis in plane
%                              of urot and vrot, perpendicualr to urot with positive
%                              component along vrot
%                   ub0         ub matrix for lattice parameters in the input sqw objects
%
%   pars_in     Arguments needed by the fit function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...} 
%
% Output:
% -------
%   wout        The sqw object with the crystal realigned accordiung to the 
%              crystal refinement orientation
%
%   pars_out    Parameters stripped of crystal refinement parameters


% Strip out crystal refinement parameters
dummy_mfclass = mfclass;
ptmp = mfclass_gateway_parameter_get(dummy_mfclass, pars_in);
pars_out = mfclass_gateway_parameter_set(dummy_mfclass, pars_in, ptmp(1:end-9));
alatt = ptmp(end-8:end-6);
angdeg = ptmp(end-5:end-3);
rotvec = ptmp(end-2:end);

% Compute rotation matrix and new ub matrix
rotmat = rotvec_to_rotmat2(rotvec);
ub = ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt,angdeg));
rlu_corr = ub\rotmat*xtal.ub0;

% Reorient workspace
wout = change_crystal(win,rlu_corr);

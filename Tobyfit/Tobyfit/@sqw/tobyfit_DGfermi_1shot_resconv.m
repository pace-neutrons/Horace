function [wout,state_out,store_out]=tobyfit_DGfermi_1shot_resconv(win,caller,state_in,store_in,...
    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
%    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
%
% Input:
% ------
%   win         sqw object or array of objects
%
%   caller      Stucture that contains ionformation from the caller routine. Fields
%                   reset_state     Reset internal state to stored value in
%                                  state_in (logical scalar)
%                   ind             Indicies into lookup tables. The number of elements
%                                  of ind must match the number of sqw objects in win
%
%   state_in    Cell array of internal state of this function for function evaluation.
%               If an element is not empty. then the internal state can be reset to this
%              stored state; if empty, then a default state must be used.
%               The number of elements must match numel(win); state_in must be a cell
%              array even if there is only a single input dataset.
%
%   store_in    Stored information that could be used in the function evaluation,
%              for example lookup tables that accumulate.
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated energies; if more than
%                              one dispersion relation, then a cell array of arrays
%
%               More general form is:
%                   weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   lookup      A structure containing lookup tables and pre-calculated matricies etc.
%              For details, see the help for function tobyfit_DGfermi_resconv_init
%
%   mc_contributions    Structure indicating which components contribute to the resolution
%              function. Each field is the name of a component, and its value is
%              either true or false
%
%   mc_points   Number of Monte Carlo points per pixel
%
%   xtal        Crystal refinement constants. Structure with fields:
%                   urot        x-axis for rotation (r.l.u.)
%                   vrot        Defines y-axis for rotation (r.l.u.): y-axis in plane
%                              of urot and vrot, perpendicualr to urot with positive
%                              component along vrot
%                   ub0         ub matrix for lattice parameters in the input sqw objects
%               Empty if the crystal oreintation is not going to be refined
%
%   modshape    Moderator refinement constants. Structure with fields:
%                   pulse_model Pulse shape model for the moderator pulse shape whose
%                              parameters will be refined
%                   pin         Initial pulse shape parameters
%                   ei          Incident energy for pulse shape calculation (this
%                              will be the common ei for all the sqw objects)
%               Empty if the moderator is not going to be refined
%
%
% Output:
% -------
%   wout        Output dataset or array of datasets with computed signal
%
%   state_out   Cell array of internal state of this function for future evaluation.
%               The number of elements must match numel(win); state_in must be a cell
%              array even if there is only a single input dataset.
%
%   store_out   Updated stored values. Must always be returned, but can be
%              set to [] if not used.

% Check consistency of caller information, stored internal state, and lookup tables
% ---------------------------------------------------------------------------------
ind=caller.ind;                 % indicies into lookup tables
if numel(ind) ~= numel(win)
    error('Inconsistency between number of input datasets and number passed from control routine')
elseif numel(ind) ~= numel(state_in)
    error('Inconsistency between number of input datasets and number of internal function status stores')
elseif max(ind(:))>numel(lookup.sample)
    error('Inconsistency between dataset indicies passed from control routine and the lookup tables')
end

% use_parallel_worker = ~isempty(license('inuse','distrib_computing_toolbox')) && ~isempty(gcp('nocreate'));


% Perform resolution broadening calculation
% -----------------------------------------
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

% Generate the full list of (Q,E) points at which we will calculate S(Q,E)

% -------------------------------------------------------------
% To avoid re-generating points when, e.g., determing the derivatives of a
% goodness of fit criteria, allow for the points to be passed to us in the
% store_in structure
if isfield(caller,'reset_state') && caller.reset_state ...
        && isfield(store_in,'allQE') && isfield(store_in,'pnt_win') ...
        && isfield(store_in,'pnt_pix')
    allQE = store_in.allQE;
    pnt_win = store_in.pnt_win;
    pnt_pix = store_in.pnt_pix;
    state_out = state_in;
    fprintf('Calculating S(Q,E) for a total of %d stored (Q,E) points\n',size(allQE,2));
else
    [pnt_win,pnt_pix,allQE,state_out] = tobyfit_DGfermi_1shot_genpoints(win,caller,state_in,store_in,pars,lookup,mc_contributions,mc_points,xtal,modshape);
    fprintf('Calculating S(Q,E) for a total of %d (Q,E) points\n',size(allQE,2));
end
% Calculate S(Q,E) for each point in allQE
% ----------------------------------------
allSQE = sqwfunc( allQE(1,:), allQE(2,:), allQE(3,:), allQE(4,:), pars{:});

% make sure S(Q,E) is a column vector
allSQE = allSQE(:);

wout = gst_collect_points_from_pixels(win,mc_points,pnt_win,pnt_pix,allSQE);

store_out = struct('allQE',allQE,'pnt_win',pnt_win,'pnt_pix',pnt_pix);


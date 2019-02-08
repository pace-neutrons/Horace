function [wout,state_out,store_out]=gst_DGfermi_resconv(win,caller,state_in,store_in,...
    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> [wout,state_out,store_out]=gst_DGfermi_resconv(win,caller,state_in,store_in,...
%                                 sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
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

use_parallel_worker = ~isempty(license('inuse','distrib_computing_toolbox')) && ~isempty(gcp('nocreate'));


% Perform resolution broadening calculation
% -----------------------------------------
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

% Get neighbourhood cell array information from the lookup:
minQE = lookup.minQE;
maxQE = lookup.maxQE;
dQE = lookup.dQE;
cell_span = lookup.cell_span;
cell_N = lookup.cell_N;

% % Every cell either has pixels in it or is a neighbour to a cell with
% % pixels. That's the whole reason behind this method
% cells_with_pixels = gst_cells_with_pixels(win,minQE,maxQE,dQE,cell_span,cell_N);
% neighbours_with_pixels = cll_cell_neighbours(cells_with_pixels,cell_N,cell_span,prod(cell_N),1);
% fprintf('\n\tFor %d cells with pixels, there are %d neighbours of %d total cells.\n',numel(cells_with_pixels),numel(neighbours_with_pixels),prod(cell_N));

% Generate the full list of (Q,E) points at which we will calculate S(Q,E)

% -------------------------------------------------------------
% To avoid re-generating points when, e.g., determing the derivatives of a
% goodness of fit criteria, allow for the points to be passed to us in the
% store_in structure
if isfield(caller,'reset_state') && caller.reset_state ...
        && isfield(store_in,'allQE') && isfield(store_in,'iW') ...
        && isfield(store_in,'iPx')   && isfield(store_in,'nPt') ...
        && isfield(store_in,'fst') && isfield(store_in,'lst') ...
        && isfield(store_in,'iPt') && isfield(store_in,'VxR') 
    allQE = store_in.allQE;
    % Vectors relating pixel indicies to between 0 and npt point indicies
    % [i.e., allQE(:,j)].
    iW  = store_in.iW;  % The index into win for the pixel
    iPx = store_in.iPx; % the index into win(iW).pix(:,i) for the pixel
    nPt = store_in.nPt; % The number of points within resolution for the pixel
    fst = store_in.fst; % The first index into iPt for the pixel
    lst = store_in.lst; % The last  index into iPt for the pixel
    iPt = store_in.iPt; % The indicies into allQE(:,i). For a pixel iPx(i), the indicies are iPt( Pt1(i)+(0:nPt(i)-1) )
    VxR = store_in.VxR; % The resolution volume times the resolution probability.
                        % For a pixel iPx(i), VxR(Pt1(i)+(0:nPt(i)-1))
                        % gives the volume of the resolution volume of
                        % pixel iPx(i) times the value of the resolution
                        % function evaluated at allQE(:, iPt(Pt1(i)+(0:nPt(i)-1)) )
    % We don't use state_in, but if we're fitting we need to make sure we
    % define state_out, and it might as well be a copy of state_in
    state_out = state_in;
    % Calculate S(Q,E) for each point in allQE
    % ----------------------------------------
    fprintf('Calculating S(Q,E) for a total of %d (Q,E) points\n',size(allQE,2));
    % TODO: Shunt this into its own thread somehow? Allow for Sij(Q,E)
    allSQE = sqwfunc( allQE(1,:), allQE(2,:), allQE(3,:), allQE(4,:), pars{:});
else
    % [npt,allQE,state_out] = cll_generate_points_mc(caller,state_in,mc_points,minQE,dQE,cell_N,cell_span);
    % [allQE,state_out] = gst_DGfermi_genpoints_same(win,caller,lookup);
    % [npt,allQE,state_out] = gst_DGfermi_gencornerpoints(win,caller,state_in,store_in,pars,lookup,mc_contributions,mc_points,xtal,modshape);
    % [allQE,state_out] = gst_DGfermi_genpoints_gaussian(win,caller,state_in,lookup,mc_points);
    [allQE,state_out] = gst_DGfermi_genpoints(win,caller,state_in,store_in,pars,lookup,mc_contributions,mc_points,xtal,modshape);

    if use_parallel_worker
        % Calculate S(Q,E) for each point in allQE, using a parallel worker
        % ----------------------------------------
        fprintf('Calculating S(Q,E) for a total of %d (Q,E) points on a parallel worker\n',size(allQE,2));
        f = parfeval(sqwfunc,1,allQE(1,:),allQE(2,:),allQE(3,:),allQE(4,:),pars{:});
    end

    % Determine the linked list for generated point neighbourhoods
    [allQE_head,allQE_list]= cll_make_linked_list(allQE,minQE,maxQE,dQE,cell_span,cell_N);
    
    % Determine the vectors describing the points within resolution for
    % each pixel
    fprintf('\t%30s\t','Points within R(Q,E) per pixel');
    [iW,iPx,nPt,fst,lst,iPt,VxR] = gst_points_in_pixels_res(win,lookup,allQE,allQE_head,allQE_list);
    fprintf('<n>=%d min(n)=%d median(n)=%d mode(n)=%d max(n)=%d\n',round(mean(nPt)),min(nPt),round(median(nPt)),mode(nPt),max(nPt));
    
    % Block execution until allSQE is calculated and returned
    if use_parallel_worker
        allSQE = fetchOutputs(f);
    else
        % Calculate S(Q,E) for each point in allQE
        % ----------------------------------------
        fprintf('Calculating S(Q,E) for a total of %d (Q,E) points\n',size(allQE,2));
        allSQE = sqwfunc( allQE(1,:), allQE(2,:), allQE(3,:), allQE(4,:), pars{:});
    end
end

% make sure S(Q,E) is a column vector
allSQE = allSQE(:);

wout = gst_collect_points_into_pixels(win,iW,iPx,nPt,fst,lst,iPt,allSQE,VxR);

store_out = struct('allQE',allQE,'iW',iW,'iPx',iPx,'nPt',nPt,'fst',fst,'lst',lst,'iPt',iPt,'VxR',VxR);
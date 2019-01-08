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


% Initialise output arguments
% ---------------------------
wout = win;

% Perform resolution broadening calculation
% -----------------------------------------
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

% Generate the full list of (Q,E) points which we will simulate
% -------------------------------------------------------------
% TODO: Is this the only part which is instrument-specific?
[allQE,widx,state_out,store_out] = gst_DGfermi_genpoints(win,caller,state_in,store_in,pars,lookup,mc_contributions,mc_points,xtal,modshape);

% Calculate S(Q,E) for each point in allQE
% ----------------------------------------
% TODO: Shunt this into its own thread somehow? Allow for Sij(Q,E)
allSQE = sqwfunc( allQE(:,1), allQE(:,2), allQE(:,3), allQE(:,4), pars{:});

% Determine which (Q,E) points are within the resolution of each pixel
% --------------------------------------------------------------------
% TODO: Also push this to its own thread. It could be time consuming and is
% independent of calculating S(Q,E).
% At the very least this should go into its own function definition, since
% indx_in_res and prob_in_res are constant while determining the
% derivatives for a refinement step.
nwin = numel(win);
npix = arrayfun(@(x)(size(x.data.pix,2)), win);
indx_in_res = cell(nwin,1);
prob_in_res = cell(nwin,1);
for i=1:nwin 
    % The resolution ellipsoids are constant for every pixel (as long as
    % the resolution parameters are fixed, of course). These could be
    % pre-calculated and stored in the lookup-tables.
    [eM,eQE0] = resolution_ellipsoids(win(i),'frac',0.2);
    indx_in_res{i} = point_in_ellipsoid_as_cells(allQE,eM,eQE0);
    [rM,rQE0] = resolution_mats(win(i));
    prob_in_res{i} = cell(npix(i),1);
    for j=1:npix(i)
        prob_in_res{i}{j} = probability_of_point( allQE(indx_in_res{i}{j},:), rM(:,:,j), rQE0(j,:) );
    end
end

% Finally pull it all together to simulate the intensity for each pixel
for i=1:nwin
%     zzz = cellfun(@numel,indx_in_res{i});
%     fprintf('SQW object %d: %d (%d,%d) (Q,E) points per pixel\n',i,round(median(zzz)),min(zzz),max(zzz));
    for j=1:npix(i)
%         s = volume_of_ellipsoid(eM{i}(:,:,j)) * prob_in_res{i}{j} .* allSQE(indx_in_res{i}{j});
        s = prob_in_res{i}{j} .* allSQE(indx_in_res{i}{j});
        
        % If there was any per-SQW and per-point  
        % 'slow' function/prefactor/background to deal with, we should 
        % do so here:
        %   s = prefunc( win{i}, allQE(:,indx_in_res{i}{j}), ...) .* s;
        wout(i).data.pix(8,j) = sum(s)/numel(s);
        
        % We *could* calculate the error in our Monte Carlo estimate if we
        % know the variance of sqwfunc 
%         wout(i).data.pix(9,j) = [variance]/numel(s);
        % Or we could just assume it's Gaussian to get some measure of the error. 
        wout(i).data.pix(9,j) = abs(sum(s.^2)-sum(s)^2)/numel(s)^2;
        % Or claim that this method is perfect.
%         wout(i).data.pix(9,j) = 0; 
    end
    % with the ith SQW object handled, fix the bin data
    wout(i) = recompute_bin_data(wout(i));
end

% % Don't bother trying to figure out which points contribute. Just calculate
% % for all points present:
% for i=1:numel(win)
%     [M,QE] = resolution_mats(win(i));
%     for j=1:size(win(i).data.pix,2)
%         prob = probability_of_point(allQE,M(:,:,j),QE(j,:));
%         s = prob .* allSQE;
%         s = s(prob>0);
%         wout(i).data.pix(8,j) = sum(s)/numel(s);
%         wout(i).data.pix(9,j) = abs(sum(s.^2)-sum(s)^2)/numel(s)^2;
%     end
%     wout(i) = recompute_bin_data(wout(i));
% end

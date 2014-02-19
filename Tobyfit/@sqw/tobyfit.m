function [wout, fitdata, ok, mess, varargout] = tobyfit(win, varargin)
% Simultaneously fit a model for S(Q,w) to an array of sqw objects.
% Optionally allows background functions,which are also S(Q,w) models, that vary independently for each sqw object.
%
% Simultaneously fit several objects to a given function:
%   >> [wout, fitdata] = multifit_sqw_sqw (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = multifit_sqw_sqw (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = multifit_sqw_sqw (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per object
%   >> [wout, fitdata] = multifit_sqw_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit_sqw_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit_sqw_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
% If unable to fit, then the program will halt and display an error message.
% To return if unable to fit, call with additional arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = multifit_sqw_sqw (...)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit_sqw_sqw (..., keyword, value, ...)
%
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%       'evaluate'  evaluate function at initial parameter values only, with argument check as well
%       'chisqr'    evaluate chi-squared at the initial parameter values (ignored if 'evaluate' not set)
%
%   Example:
%   >> [wout, fitdata] = multifit_sqw_sqw (..., 'keep', xkeep, 'list', 0)
%
%
% Input:
% ======
%   win     sqw object or array of sqw objects to be fitted
%
%   sqwfunc Handle to function that calculates S(Q,w)
%           Most commonly used form is:
%               weight = sqwfunc (qh,qk,ql,en,p)
%           where
%               qh,qk,ql,en Arrays containing the coordinates of a set of points
%               p           Vector of parameters needed by dispersion function
%                          e.g. [A,js,gam] as intensity, exchange, lifetime
%               weight      Array containing calculated energies; if more than
%                          one dispersion relation, then a cell array of arrays
%
%           More general form is:
%               weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%             where
%               p           Typically a vector of parameters that we might want
%                          to fit in a least-squares algorithm
%               c1,c2,...   Other constant parameters e.g. file name for look-up
%                          table
%
%   pin     Initial function parameter values
%            - If the function my_function takes just a numeric array of parameters, p, then this
%             contains the initial values [pin(1), pin(2)...]
%            - If further parameters are needed by the function, then wrap as a cell array
%               {[pin(1), pin(2)...], c1, c2, ...}
%
%   pfree   [Optional] Indicates which are the free parameters in the fit
%           e.g. [1,0,1,0,0] indicates first and third are free
%           Default: all are free
%
%   pbind   [Optional] Cell array that indicates which of the free parameters are bound to other parameters
%           in a fixed ratio determined by the initial parameter values contained in pin:
%             pbind={1,3}               parameter 1 is bound to parameter 3.
%             pbind={{1,3},{4,3},{5,6}} parameter 1 bound to 3, 4 bound to 3, and 5 bound to 6
%                                       In this case, parmaeters 1,3,4,5,6 must all be free in pfree.
%
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,0,7.4)         parameter 1 is bound to parameter 3, ratio 7.4 (the extra '0' is required)
%             pbind={{1,3,0,7.4},{4,3,0,0.023},{5,6}}
%
%           To bind to background parameters (see below), give the index of the background function
%           handle in the cell array bkdfunc defined below.
%             pbind={1,3,[7,2]}         parameter 1 bound to background parameter 3 of background
%                                       function handle bkdfunc{7,2}.
%
%             pbind={1,3,[7,2],3.14}    Give explicit binding ratio.
%
%
%   Optional background function(s):
%   --------------------------------
%   It is sometimes convenient to fit a global function, func, to the collection of objects w,
%   but have a function that might be used to provide an object-specific background. For example,
%   we may want to fit S(Q,w) to several one-dimensional cuts, but have an independent linear
%   background for each cut. These are defined similarly to the above
%
%  bkdfunc  Cell array of background function (of sqw-type) handles
%            - If contains a single handle, then the same function applies to every object
%              in the collection of objects, w, that is to be fitted.
%             (Internally, is expanded into a cell array of the same size as w. If wish to bind
%              background parameters to a particular background handle, then refer to the
%              corresponding index of that expanded array).
%            - Otherwise, the size of the cell array must match the size of w, and there
%              will be a one-to-one correspondence of the background function handles to the elements of w.
%              The form required for the functions is identical to that for func above.
%
%   bpin    Cell array of initial parameter values for the background function(s), following the
%           same definitions and conventions as pin
%            - If a single element in the cell array, then will be used for every background function;
%            - Otherwise, the size of the cell array must match the size of w, and there will be a
%              one-to-one correspondence of the elements to the background initial parameters
%
%   bpfree  Array, or cell array of arrays indicating which parameters are free to vary.
%            - If single array, or cell array with a single array, then applies to every background function
%            - Otherwise, the size of the cell array must match the size of w, and there will be a
%              one-to-one correspondence of the elements to indicate the free background parameters
%
%   bpbind  Cell array of binding cell arrays of the form defined for pbind. Indicates how background
%           parameters are bound. Take care here: as the object that defined the binding is itself
%           a cell array of cell arrays, it is easy to get confused as to whether the binding description
%           applies to all background functions, or if it is a set of distinct binding descriptions, one
%           for each background function. The size of the outermost cell array dictates which:
%            - If a single element in the cell array, then will be used for every background function;
%            - Otherwise, the size of the cell array must match the size of w, and there will be a
%              one-to-one correspondence of the elements to the background functions.
%
%           Examples of a single binding description:
%               {1,4}         Background parameter (bp) 1 is bound to bp 3, with the fixed
%                                  ratio determined by the initial values
%               {2,3,[7,2]}   Bp 2 bound to bp 3 of background function handle bkdfunc{7,2}
%               {5,11,0}      Bp 5 bound to parameter 11 of the global fitting function, func
%               {{1,4}, {2,3,[7,2]}, {5,11,0}}        Several bindings defined together
%
%               {5,11,0,0.013}      Explicit ratio for binding bp 5 to parameter 11 of the global fitting function
%               {1,4,[7,2],14.15}   Explicit ratio for binding bp 1 to bp 4 of background function [7,2]
%
%           In a call to multifit: as an example of the need to take care:
%               bpbind = {{1,4}, {2,3,[7,2]}, {5,11,0}}     binding description for three separate backgrounds
%
%               bpbind = { {{1,4}, {2,3,[7,2]}, {5,11,0}} } Binding description for all background functions
%
%
%   Optional keywords:
%   ------------------
%   'list'  Numeric code to control output to Matlab command window to monitor
%           status of fit
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
%   'fit'   Array of fit control parameters
%           fcp(1)  relative step length for calculation of partial derivatives
%           fcp(2)  maximum number of iterations
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if chisqr_new-chisqr_old < fcp(3)*chisqr_old
%
%   'keep'  Array or cell array of arrays giving ranges of x to retain for fitting.
%            - single array: applies to all elements of w
%            - a cell array of arrays must have length the same as w, and describes the
%             keep ranges for those elements one-by-one.
%
%           A range is specified by an arrayv of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%  'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. xremove takes precendence over xkeep.
%
%   'mask'  Array, or cell array of arrays, of ones and zeros, with the same number
%           of elements as the data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting.
%
%  'select' Calculates the returned function values, wout, only at the points
%           that were selected for fitting by 'keep', 'remove', 'mask' and were
%           not eliminated for having zero error bar etc; this is useful for plotting the output, as
%           only those points that contributed to the fit will be plotted.
%
%  A final useful set of keyword is:
%
%  'evaluate'   Evaluate the fitting function at the initial parameter values only. Useful for
%               checking the validity of starting parameters.
%
%  'chisqr'     If 'evaulate' is set, then if this option keyword is present the reduced
%               chi-squared is evaluated. Otherewise, chi-squared is set to zero.
%
%
% Output:
% =======
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%           If there was a problem i.e. ok==false, wout=[]
%
%   fitdata Result of fit for each dataset
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors of global parameters (=0 for fixed parameters)
%               fitdata.bp     - background parameter values
%               fitdata.bsig   - estimated errors of background (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%               fitdata.bpnames- background parameter names
%           If there was a problem i.e. ok==false, fitdata=[]
%
%   ok      True if all ok, false if problem fitting.
%
%   mess    Character string contaoning error message if ~ok; '' if ok
%
%
% EXAMPLES:
%
% Fit a spin waves to a collection of sqw objects, allowing only intensity and coupling constant to vary:
%   >> weight=100; SJ; gamma=3;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], [1,1,0])
%
% The background S(Q,w) can be used to have some parameters of a global cross-section model float independently
% for e.g. If an array of 1D sqw objects: fit from -1.5 to 0.5 allowing width and intensity to be independent,
% but have global exchange:
%   >> ht=100; SJ=10; gamma=3;
%   >> ht_dummy=0; gamma_dummy=1;   % ht=0 forces foreground to have zero constribution to calculated signal
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht_dummy,SJ,gamma_dummy], [0,1,0],...
%                             @bcc_damped_spinwaves, [ht,SJ,gamma], [1,1,1], {{{2,2,0}}}, 'keep',[-1.5,0.5])


% Clean up any persistent or global storage in case tobyfit was left in a strange state
% -------------------------------------------------------------------------------------
tobyfit_cleanup     % Initialise Tobyfit
if matlab_version_num>=7.06     % R2008a or more recent: robust cleanup even if cntl-c
    cleanupObj=onCleanup(@tobyfit_cleanup);
end


% Parse input arguments
% ---------------------
% Default output arguments if error
wout=[];
fitdata=[];
rlu_corr=[];
fitmod=[];

% Check the data types are ok
for i=1:numel(win)
    if ~is_sqw_type(win(i));   % must be if sqw type
        ok=false; mess='All input datasets must be sqw type';
        if nargout<3, error(mess), else return, end
    end
end

% Strip out Tobyfit specific arguments from varargin
arglist = struct('mc_contributions',[],'mc_npoints',10,'refine_crystal',[],'refine_moderator',[]);
[varargin,opt,present] = parse_arguments(varargin,arglist,[],false);
mc_contrib=opt.mc_contributions;
mc_npoints=opt.mc_npoints;
if present.refine_crystal
    refine_crystal=true;
    xtal_opts=opt.refine_crystal;
else
    refine_crystal=false;
end
if present.refine_moderator
    refine_moderator=true;
    mod_opts=opt.refine_moderator;
else
    refine_moderator=false;
end
if refine_crystal && refine_moderator
    ok=false; mess='Cannot refine both crystal parameters and moderator parameters - choose only one of these options';
    if nargout<3, error(mess), else return, end
end

% Parse the input arguments to multifit
[ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] = multifit_gateway_parsefunc (win, varargin{:});
if ~ok
    if nargout<3, error(mess), else return, end
end
ndata=1;     % There is just one argument before the varargin
pos=pos-ndata;
bpos=bpos-ndata;
narg=narg-ndata;


% Prepare Monte Carlo arguments, crystal and moderator refinement
% ---------------------------------------------------------------
% Set which contributions to the resolution are to be accounted for
[mc_contrib,ok,mess]=tobyfit_mc_contributions(mc_contrib);
if ~ok
    if nargout<3, error(mess), else return, end
end

% Check the number of Monte Carlo points
if ~isnumeric(mc_npoints) || ~isscalar(mc_npoints) || mc_npoints-round(mc_npoints)~=0 || mc_npoints<1
    ok=false; mess='Number of Monte Carlo points per pixel must be an integer greater or equal to one';
    if nargout<3, error(mess), else return, end
end

% Check crystal refinement input, if refinement is requested
if refine_crystal
    % Check lattice parameters in input objects
    [alatt0,angdeg0,ok,mess] = lattice_parameters(win);
    if ~ok
        mess=['Crystal refinement: ',mess];
        if nargout<3, error(mess), else return, end
    end
    
    % Check validity of refinement options structure, and set starting values for lattice parameters if necessary
    [xtal_opts,ok,mess] = tobyfit_refine_crystal_options(xtal_opts);
    if ~ok
        if nargout<3, error(mess), else return, end
    end
    if isempty(xtal_opts.alatt)
        xtal_opts.alatt=alatt0;
    end
    if isempty(xtal_opts.angdeg)
        xtal_opts.angdeg=angdeg0;
    end
    
    % Append crystal refinement parameters to the foreground parameter arguments
    [plist,pfree,pbind]=refine_crystal_pack_parameters (plist,pfree,pbind,xtal_opts);
    
    % Re-create argument list for multifit
    pbind=multifit_gateway_pbind_struct_to_cell(pbind);     % return to cell array input
    if isempty(bpos)    % no background function(s) present
        varargin=[{func,plist,pfree,pbind},varargin(narg+1:end)];
    else
        bpbind=multifit_gateway_pbind_struct_to_cell(bpbind);
        varargin=[{func,plist,pfree,pbind,bfunc,bplist,bpfree,bpbind},varargin(narg+1:end)];
        bpos=5;
    end
    
    % Fill refine argument to be passed as argument to multifit
    xtal.refine=true;
    xtal.urot=xtal_opts.urot;
    xtal.vrot=xtal_opts.vrot;
    xtal.ub0 = ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt0,angdeg0));   % ub matrix for lattice parameters in sqw objects
    
else
    xtal.refine=false;
end

% Check moderator refinement input, if refinement is requested
if refine_moderator
    % Check that the moderator contribution is included to the resolution calculation
    if ~mc_contrib.moderator
        mess='Moderator refinement: must have Monte Carlo contribution from moderator selected in ''mc_contributions''';
        if nargout<3, error(mess), else return, end
    end
    % Check all incident energies are the same in input objects
    [ei_common,emode,ok,mess] = get_efix(win);
    if ~ok
        mess=['Moderator refinement: ',mess];
        if nargout<3, error(mess), else return, end
    end
    
    % Check validity of refinement options structure on entry
    [mod_opts,ok,mess] = tobyfit_refine_moderator_options(mod_opts);
    if ~ok
        if nargout<3, error(mess), else return, end
    end
    
    % Get model and starting parameters if not given
    if isempty(mod_opts.pulse_model) || isempty(mod_opts.pp_init)
        [pulse_model_default,pp_init_default,ok,mess] = get_mod_pulse(win);
        if ~ok
            if nargout<3, error(mess), else return, end
        end
        if isempty(mod_opts.pulse_model)
            mod_opts.pulse_model=pulse_model_default;
        end
        if isempty(mod_opts.pp_init)
            mod_opts.pp_init=pp_init_default(:)';   % guarantee it is a row vector
        end
    end
    if isempty(mod_opts.pp_free)
        mod_opts.pp_free=true(size(mod_opts.pp_init));  % default is all parameters are free
    end
    
    % Check validity of refinement options structure after filling missing arguments
    [mod_opts,ok,mess] = tobyfit_refine_moderator_options(mod_opts);
    if ~ok
        if nargout<3, error(mess), else return, end
    end
    
    % Append crystal refinement parameters to the foreground parameter arguments
    [plist,pfree,pbind]=refine_moderator_pack_parameters (plist,pfree,pbind,mod_opts);
    
    % Re-create argument list for multifit
    pbind=multifit_gateway_pbind_struct_to_cell(pbind);     % return to cell array input
    if isempty(bpos)    % no background function(s) present
        varargin=[{func,plist,pfree,pbind},varargin(narg+1:end)];
    else
        bpbind=multifit_gateway_pbind_struct_to_cell(bpbind);
        varargin=[{func,plist,pfree,pbind,bfunc,bplist,bpfree,bpbind},varargin(narg+1:end)];
        bpos=5;
    end
    
    % Fill refine argument to be passed as argument to multifit
    modshape.refine=true;
    modshape.pulse_model=mod_opts.pulse_model;
    modshape.pp=mod_opts.pp_init;
    modshape.ei=ei_common;

else
    modshape.refine=false;
end


% Perform the fit
% ---------------
% Set control options for function evaluation
resol_conv_tobyfit_mc_control('multifit',size(win))


% Wrap the foreground and background functions
wrap_plist={mc_contrib,mc_npoints,xtal,modshape};
args=multifit_gateway_wrap_functions (varargin,pos,func,plist,bpos,bfunc,bplist,...
                                        @resol_conv_tobyfit_mc,wrap_plist,@func_eval,{});

% Least-squares fitting
[ok,mess,wout,fitdata] = multifit_gateway_main (win, args{:}, 'init_func', @resol_conv_tobyfit_mc_init);
if ~ok
    if nargout<3, error(mess), else return, end
end


% Pack output arguments
% ---------------------
% Get the rlu correction matrix if crystal refinement
if refine_crystal
    if numel(func)==1
        pxtal=fitdata.p(end-8:end);
    else
        pxtal=fitdata.p{1}(end-8:end);
    end
    alatt=pxtal(1:3);
    angdeg=pxtal(4:6);
    rotvec=pxtal(7:9);
    rotmat=rotvec_to_rotmat2(rotvec);
    ub=ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt,angdeg));
    rlu_corr=ub\rotmat*xtal.ub0;
    % Pack output arguments
    varargout={rlu_corr};
end

% Get the moderator refinement parameters
if refine_moderator
    fitmod.pulse_model=modshape.pulse_model;
    npmod=numel(modshape.pp);
    if numel(func)==1
        fitmod.p=fitdata.p(end-npmod+1:end);
        fitmod.sig=fitdata.sig(end-npmod+1:end);
    else
        fitmod.sig=fitdata.sig{1}(end-npmod+1:end);
    end
    % Pack output arguments
    varargout={fitmod.pulse_model,fitmod.p,fitmod.sig};
end


% Cleanup resolution convolution status
% -------------------------------------
if matlab_version_num<7.06     % prior to R2008a: does not automatically call cleanup (see start of this function)
    tobyfit_cleanup
end

%=================================================================================================================
function tobyfit_cleanup
% Cleanup Tobyfit
resol_conv_tobyfit_mc_control
refine_moderator_sampling_table_buffer

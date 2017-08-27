function [data_out, fitdata, ok, mess, varargout] = fit (obj, varargin)
% Perform a fit of the data using the current functions and starting parameter values
%
% Return calculated fitted datasets and parameters:
%   >> [data_out, fitdata] = obj.fit                    % if ok false, throws error
%
% Return the calculated fitted signal, foreground and background in a structure:
%   >> [data_out, fitdata] = obj.fit ('components')     % if ok false, throws error
%
% Continue execution even if an error condition is thrown:
%   >> [data_out, fitdata, ok, mess] = obj.fit (...)    % if ok false, still returns
%
% If refining crystal orientation:
%   >> [data_out, fitdata, ok, mess, rlu_corr] = obj.fit (...)
%
% If refining moderator parameters:
%   >> [data_out, fitdata, ok, mess, pulse_model, p, psig] = obj.fit (...)
%
%
% Output:
% -------
%  data_out Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%           If there was a problem i.e. ok==false, then data_out=[].
%
%           If option 'components' was given, then data_out is a structure with fields
%           with the same format as above, as follows:
%               data_out.sum        Sum of foreground and background
%               data_out.fore       Foreground calculation
%               data_out.back       Background calculation
%           If there was a problem i.e. ok==false, then each field is =[].
%
%   fitdata Structure with result of the fit for each dataset. The fields are:
%           p      - Foreground parameter values (if foreground function(s) present)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           sig    - Estimated errors of foreground parameters (=0 for fixed
%                    parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bp     - Background parameter values (if background function(s) present)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bsig   - Estimated errors of background (=0 for fixed parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           corr   - Correlation matrix for free parameters
%           chisq  - Reduced Chi^2 of fit i.e. divided by:
%                       (no. of data points) - (no. free parameters))
%           converged - True if the fit converged, false otherwise
%           pnames - Foreground parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%           bpnames- Background parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%
%           If there was a problem i.e. ok==false, then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%                 both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g. the
%                 number of free parameters equals or exceeds the number
%                 of data points
%
%   mess    Message if ok==false; Empty string if ok==true.
%
% If ok is not a return argument, then if ok is false an error will be thrown.
%
% Additional return arguments if refining moderator or crystal orientation:
% -------------------------------------------------------------------------
% Crystal orientation:
%   If crystal refinement has been set (see <a href="matlab:doc('mfclass_tobyfit/set_refine_crystal');">set_refine_crystal</a>):
%
%   >> [data_out, fitdata, ok, mess, rlu_corr] = obj.fit (...)
%
%   rlu_corr    Reorientation matrix used to change crystal orientation.
%
%   See:
%   <a href="matlab:doc sqw/change_crystal">mfclass/change_crystal</a>
%   <a href="matlab:doc change_crystal_horace">mfclass/change_crystal_horace</a>
%   <a href="matlab:doc change_crystal_sqw">mfclass/change_crystal_sqw</a>
%   <a href="matlab:doc change_crystal_dnd">mfclass/change_crystal_dnd</a>
%
% Moderator refinement:
%   If moderator refinement has been set (see <a href="matlab:doc('mfclass_tobyfit/set_refine_moderator');">set_refine_moderator</a>):
%
%   >> [data_out, fitdata, ok, mess, pulse_model, p, psig] = obj.fit (...)
%
%   pulse_model, p, psig    Refined moderator parameters (and standard errors)
%                          used as input by set_mod_pulse to reset the
%                          moderator parameters in an sqw object or file.
%   See:
%   <a href="matlab:doc sqw/get_mod_pulse">mfclass/get_mod_pulse</a>
%   <a href="matlab:doc get_mod_pulse_horace">mfclass/get_mod_pulse_horace</a>
%   <a href="matlab:doc sqw/set_mod_pulse">mfclass/set_mod_pulse</a>
%   <a href="matlab:doc set_mod_pulse_horace">mfclass/set_mod_pulse_horace</a>

%-------------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_fit_intro = fullfile(mfclass_doc,'doc_fit_intro.m')
%
%   mfclass_tobyfit_doc = fullfile(fileparts(which('mfclass_tobyfit')),'_docify')
%   doc_fit_intro_extra_header = fullfile(mfclass_tobyfit_doc,'doc_fit_intro_extra_header.m')
%   doc_fit_intro_extra_body = fullfile(mfclass_tobyfit_doc,'doc_fit_intro_extra_body.m')
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_fit_intro> <doc_fit_intro_extra_header> <doc_fit_intro_extra_body>
% <#doc_end:>
%-------------------------------------------------------------------------------

% Check there is data
data = obj.data;
if isempty(data)
    error('No data sets have been set - nothing to fit')
end

% Update parameter wrapping
obj_tmp = obj;

is_refine_crystal = ~isempty(obj_tmp.refine_crystal);
if is_refine_crystal
    [ok, mess, obj_tmp, xtal] = refine_crystal_pack_parameters_ (obj_tmp);
    if ~ok, error(mess), end
else
    xtal = [];
end

is_refine_moderator = ~isempty(obj_tmp.refine_moderator);
if is_refine_moderator
    [ok, mess, obj_tmp, modshape] = refine_moderator_pack_parameters_ (obj_tmp);
    if ~ok, error(mess), end
else
    modshape = [];
end

obj_tmp.wrapfun.p_wrap = append_args (obj_tmp.wrapfun.p_wrap, obj.mc_contributions, obj.mc_points, xtal, modshape);

% Perform fit
[data_out, fitdata, ok, mess] = fit@mfclass (obj_tmp, varargin{:});

% Extract crystal or moderator refinement parameters (if any) in a useful form
if is_refine_crystal
    % Get the rlu correction matrix if crystal refinement
    if ~iscell(fitdata.p)   % single function
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

if is_refine_moderator
    % Get the moderator refinement parameters
    fitmod.pulse_model=modshape.pulse_model;
    npmod=numel(modshape.pin);
    if ~iscell(fitdata.p)   % single function
        fitmod.p=fitdata.p(end-npmod+1:end);
        fitmod.sig=fitdata.sig(end-npmod+1:end);
    else
        fitmod.p=fitdata.p{1}(end-npmod+1:end);
        fitmod.sig=fitdata.sig{1}(end-npmod+1:end);
    end
    % Pack output arguments
    varargout={fitmod.pulse_model,fitmod.p,fitmod.sig};
end

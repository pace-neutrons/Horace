classdef mfclass_tobyfit < mfclass
    % mfclass_tobyfit
    % Resolution convolution
    
    properties (Access=private, Hidden=true)
        % Define which components of instrument contribute to resolution function model
        mc_contributions_ = [];
        
        % The number of Monte Carlo points per pixel
        mc_points_ = [];
        
        % Crystal orientation refinement. If not to be performed, contains [];
        % otherwise a structure with various parameters
        refine_crystal_ = [];
        
        % Moderator parameter refinement. If not to be performed, contains [];
        % otherwise a structure with various parameters
        refine_moderator_ = [];
    end
    
    properties (Dependent)
        mc_contributions
        mc_points
        refine_crystal
        refine_moderator
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_tobyfit (varargin)
            obj@mfclass(varargin{:});
            obj = obj.set_mc_contributions;
            obj = obj.set_mc_points;
            obj = obj.set_refine_crystal (false);
            obj = obj.set_refine_moderator (false);
        end
        
        %------------------------------------------------------------------
        % Set/get methods
        %------------------------------------------------------------------
        function out = get.mc_contributions (obj)
            out = obj.mc_contributions_;
        end
        
        function out = get.mc_points (obj)
            out = obj.mc_points_;
        end
        
        function out = get.refine_crystal (obj)
            out = obj.refine_crystal_;
        end
        
        function out = get.refine_moderator (obj)
            out = obj.refine_moderator_;
        end
        
        %------------------------------------------------------------------
        % Extend superclass methods
        %------------------------------------------------------------------
        function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
            %
            % Create cleanup object
            cleanupObj=onCleanup(@() tobyfit_cleanup);
            
            % Check there is data
            data = obj.data;
            if isempty(data)
                error('No data sets have been set - nothing to simulate')
            end
            
            % Update parameter wrapping
            obj_tmp = obj;
            
            wrapfun = obj_tmp.wrapfun_;
            wrapfun = wrapfun.append_p_wrap(obj.mc_contributions, obj.mc_points, [], []);
            obj_tmp.wrapfun_ = wrapfun;
            
            % Perform simulation
            [data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
        end
        
        %------------------------------------------------------------------
        function [data_out, fitdata, ok, mess, varargout] = fit (obj)
            % Perform a fit of the data using the current functions and starting parameter values
            %
            %   >> [data_out, fitdata] = obj.fit            % if ok false, throws error
            %
            %   >> [data_out, fitdata, ok, mess] = obj.fit  % if ok false, still returns
            %
            % If crystal or moderator refinement is being performed, then there are additional
            % return arguments:
            %
            % - Moderator refinement:
            %   >> [data_out, fitdata, ok, mess, pulse_model, pmod, sigmod] = obj.fit
            %
            % - Crystal refinement:
            %   >> [data_out, fitdata, ok, mess, rlu_corr] = obj.fit
            %
            %   Here the matrix rlu_corr can be used to reset the crystal orientation
            %   and/or lattice parameters in Horace using the function:
            %       >> wout = change_crystal (w, rlu_corr)
            %
            % Output:
            % -------
            %  data_out Output with same form as input data but with y values evaluated
            %           at the final fit parameter values. If the input was three separate
            %           x,y,e arrays, then only the calculated y values are returned.
            %
            %           If there was a problem i.e. ok==false, then data_out=[].
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
            %
            % If ok is not a return argument, then if ok is false an error will be thrown.
            
            % Create cleanup object
            cleanupObj=onCleanup(@() tobyfit_cleanup);
            
            % Check there is data
            data = obj.data;
            if isempty(data)
                error('No data sets have been set - nothing to fit')
            end
            
            % Update parameter wrapping
            obj_tmp = obj;
            is_refine_crystal = ~isempty(obj_tmp.refine_crystal);
            is_refine_moderator = ~isempty(obj_tmp.refine_moderator);
            if is_refine_crystal
                [ok, mess, obj_tmp, xtal] = refine_crystal_pack_parameters_ (obj_tmp);
                if ~ok, error(mess), end
            else
                xtal = [];
            end
            if is_refine_moderator
                [ok, mess, obj_tmp, modshape] = refine_moderator_pack_parameters_ (obj_tmp);
                if ~ok, error(mess), end
            else
                modshape = [];
            end
            
            wrapfun = obj_tmp.wrapfun_;
            wrapfun = wrapfun.append_p_wrap(obj.mc_contributions, obj.mc_points, xtal, modshape);
            obj_tmp.wrapfun_ = wrapfun;
            
            % Perform fit
            [data_out, fitdata, ok, mess] = fit@mfclass (obj_tmp);
            
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
        end
    end
    
    methods (Access=private)
        [ok, mess, obj, xtal] = refine_crystal_pack_parameters_ (obj, xtal_opts)
        [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj, mod_opts)
    end
end


%--------------------------------------------------------------------------------------------------
function tobyfit_cleanup
% Cleanup Tobyfit

% Cleanup the stored buffer for moderator fitting
refine_moderator_sampling_table_buffer (sqw)

end

classdef (Abstract) IX_det_abstractType < serializable
    % Abstract class to be inherited by detector classes
    % Defines one or more generic properties and required methods for all
    % detector types.

    properties (Abstract, Dependent, Hidden)
        ndet    % number of detectors
    end

    methods (Abstract)
        %------------------------------------------------------------------
        % General format of the methods that compute detector properties must be
        %
        %   >> val = func (obj, wvec)
        %   >> val = func (obj, ind, wvec)
        %
        %   ind     Indices of detectors for which to calculate. Scalar or array.
        %           Default: all detectors (i.e. ind = 1:ndet) as a row vector.
        %
        %   wvec    Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
        %             - if ind is a scalar, the calculation is performed for
        %              that value at each of the values of wvec
        %             - if wvec is a scalar, the calculation is performed for
        %              that value at each of the values of ind
        %
        %   The output is a stack of arrays of the size of the ouput for a
        %   scalar instance of ind and wvec, with the size of the stacking
        %   array being whichever of ind or wvec is an array.
        %   Leading singleton dimensions of the stacking array size are
        %   used to accommodate non-singleton dimensions of the output once
        %   trailing singletons have been removed
        %
        %   EXAMPLES
        %   Suppose the output for single value of ind and wvec has size
        %   [3,3] (for example, a covariance matrix)
        %
        %       size(wvec) == [2,5]     ==> size(val) == [3,3,2,5]
        %       size(wvec) == [1,5]     ==> size(val) == [3,3,5]
        %       size(wvec) == [1,1,5]   ==> size(val) == [3,3,5]
        %       size(wvec) == [1,1,1,5] ==> size(val) == [3,3,1,5]
        %
        %   If both ind and wvec are arrays,then the stacking size is that
        %   of wvec.


        % Utility routines
        obj_out = reorder (obj, ix)
        obj_out = replicate (obj, n)

        % Efficiency
        val = effic (obj, varargin)

        % Mean depth of absorption w.r.t. notional centre along neutron path
        val = mean_d (obj, varargin)

        % Variance of depth of absorption along neutron path
        val = var_d (obj, varargin)

        % Mean position along the detector coordinate axes, and all three
        % as a vector.
        % There can be efficiency savings by having the last as a separate
        % function that calls common code for each of the three others.
        val = mean_x (obj, varargin)
        val = mean_y (obj, varargin)
        val = mean_z (obj, varargin)
        val = mean (obj, varargin)      % 3 x 1 vector for single point

        % Variances along the detector coordinate axes, and all three as a
        % vector.
        % There can be efficiency savings by having the last as a separate
        % function that calls common code for each of the three others.
        val = var_x (obj, varargin)
        val = var_y (obj, varargin)
        val = var_z (obj, varargin)
        val = covariance (obj, varargin)     % 3 x 3 matrix for single point

        % Array of random points
        X = rand (obj, varargin)
    end

    methods (Static)
        function varargout = tobyfit_defaults(val,parms)
        % TOBYFIT_DEFAULTS store and make available defaults for detector types
        % e.g. He3Tube, Tobyfit_Classic, slab... so that they can be used to
        % initialise detectors, until this information is available in
        % nxspe input.
        %
        % NOTE - this is an interim solution to make data available for
        % IX_det_abstractType subclasses until such time as the actual data
        % is available in nxspe. Its structure, particularly the use of
        % persistent, assumes that many detectors of the same type will be
        % deployed in a given Horace session, so that the persistent
        % variables store the set-once use-many-times values. Innsue #1338
        % tracks the need to update this.
        %
        % Inputs
        % ======
        % EITHER
        % (no arguments) - the call is used to return the detector type and parms from perisistent
        %                  storage
        % OR
        % val       - type (output of class(detector_object) e.g. He3Tube etc.....
        % parms     - a struct containing data which can be used to initialise
        %             an object of type val, e.g. for He3Tube, wall thickness and pressure
        %             In this example case, parms will be a struct with those values
        %
        % OUTPUTS
        % =======
        % Optional (none, one or two):
        % varargout{1} - the detector type string, if requested
        % varargout{2} - a struct with the detector type parameters
        
        
            persistent type parameters;
            if nargin>0
                type = val;
                if nargin>1 && isstruct(parms)
                    parameters = parms;
                end
            end
            if nargout>0
                varargout{1} =type;
            end
            if nargout>1
                varargout{2} = parameters;
            end
        end
    end
    
    %======================================================================
    % SERIALIZABLE INTERFACE
    %======================================================================

    methods(Access=protected)
        function obj = expand_internal_properties_to_max_length (obj, flds)
            % Method runs over the class properties and expands these
            % properties arrays to properties maximal length
            % identify maximal length of all saveble property values

            % Store the current state of do_check_combo_arg_
            old_state = obj.do_check_combo_arg_;            

            % Disable check_combo_arg in case if it has been enabled to work
            % with public properties as with private one and not to re-run 
            % this function recursively
            obj.do_check_combo_arg_ = false;

            num_elements = cellfun(@(x)numel(obj.(x)), flds);
            max_len = max(num_elements);

            % what property have maximal length
            ref_len = (num_elements == max_len);
            if ~all(ref_len)
                max_ind = find(ref_len,1); 
                for i=1:numel(flds)
                    if num_elements(i)~=max_len % expand prperty value to maximal length
                        obj.(flds{i}) = ...
                            expand_args_by_ref( ...
                            obj.(flds{max_ind}),...
                            obj.(flds{i}));
                    end
                end
            end
            
            % Restore incoming state of do_check_combo_arg_
            obj.do_check_combo_arg_ = old_state;
        end
    end

end

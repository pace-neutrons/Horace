classdef (Abstract) IX_det_abstractType < serializable
    % Abstract class that defines detector type

    properties (Abstract, Dependent, Hidden)
        ndet    % number of detectors
    end

    methods (Abstract)
        %------------------------------------------------------------------
        % General format of the methods must be
        %   >> val = func (obj, wvec)
        %   >> val = func (obj, ind, wvec)
        %   ind     Indices of detectors for which to calculate. Scalar or array.
        %           Default: all detectors (i.e. ind = 1:ndet)
        %
        %   wvec    Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
        %
        %   If both ind and wvec are arrays, then they must have the same number
        %   of elements.
        %   The return argument has trailing size given by that of wvec if both are
        %   ind and wvec are arrays.
        %   Excess dimensions are squeezed away
        %    e.g. suppose covariance:
        %           size = [3,3] for a single element
        %           size(ind) = [2,2]
        %           size(wvec)= [1,4]
        %         then size of output is squeeze of [3,3,1,4] i.e. [3,3,4]

        % Utility routines
        obj_out = reorder (obj, ix)
        obj_out = replicate (obj, n)

        % Efficiency
        val = effic (obj, varargin)

        % Mean depth of absorption w.r.t. notional centre along neutron path
        val = mean_d (obj, varargin)

        % Variance of depth of absorption along neutron path
        val = var_d (obj, varargin)

        % Mean position along the detector coordinate axes, and all three as a vector
        % There can be efficiency savings by having the last as a separate
        % function that calls common code for each of the three others
        val = mean_x (obj, varargin)
        val = mean_y (obj, varargin)
        val = mean_z (obj, varargin)
        val = mean (obj, varargin)      % 3 x 1 vector for single point

        % variances along the detector coordinate axes, and all three as a vector
        % There can be efficiency savings by having the last as a separate
        % function that calls common code for each of the three others
        val = var_x (obj, varargin)
        val = var_y (obj, varargin)
        val = var_z (obj, varargin)
        val = covariance (obj, varargin)     % 3 x 3 matrix for single point

        % Array of random points
        X = rand (obj, varargin)
    end
    methods(Access=protected)
        function obj = expand_internal_propeties_to_max_length(obj,flds)
            % method runs over the class properties and expands these
            % properties arrays to properties maximal length
            % identify maximal length of all saveble property values
            % 

            % store the previous state of check_combo_arg property
            old_state = obj.do_check_combo_arg_;            
            % disable check_combo in case if it has been enabled to work
            % with public properties as with private one and not to re-run 
            % this function recursively
            obj.do_check_combo_arg_ = false;

            num_elments = cellfun(@(x)numel(obj.(x)),flds);
            max_len = max(num_elments);

            % what property have maximal length
            ref_len = num_elments == max_len;
            if ~all(ref_len)
                max_ind = find(ref_len,1);
                for i=1:numel(flds)
                    if num_elments(i)~=max_len % expand prperty value to maximal length
                        obj.(flds{i}) = ...
                            expand_args_by_ref( ...
                            obj.(flds{max_ind}),...
                            obj.(flds{i}));
                    end
                end
            end
            obj.do_check_combo_arg_ = old_state;
        end
    end

end

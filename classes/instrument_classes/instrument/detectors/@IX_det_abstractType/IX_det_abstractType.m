classdef (Abstract) IX_det_abstractType
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
        val = covar (obj, varargin)     % 3 x 3 matrix for single point
        
        % Array of random points
        X = rand (obj, varargin)
    end
    
end

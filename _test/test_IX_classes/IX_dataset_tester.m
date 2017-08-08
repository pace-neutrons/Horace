classdef IX_dataset_tester < IX_dataset
    % Class to test some IX_dataset_methods
    %======================================================================
    %======================================================================
    methods
        function obj = IX_dataset_tester(varargin)
        end
        
        %======================================================================
        % Abstract interface:
        %======================================================================
        % (re)initialize object using constructor' code
        function obj = init(obj,varargin)
            error('IX_dataset_tester:not_implemented','init not implemented')
        end
        % Find number of dimensions and extent along each dimension of the signal arrays.
        function [nd,sz] = dimensions(w)
            nd = NaN;
            sz = NaN;
        end
        % Return array containing true or false depending on dataset being
        % histogram or point;
        function status=ishistogram(w,n)
            error('IX_dataset_tester:not_implemented','ishistogram not implemented')
        end
    end
    %======================================================================
    methods(Static)       
        % used to reload old style objects from mat files on hdd
        function obj = loadobj(data)
            error('IX_dataset_tester:not_implemented','loadobjnot implemented')
        end
        % get number of class dimensions
        function nd  = ndim()
            nd = NaN;
        end
    end
    %======================================================================
    methods(Access=protected)
        % Generic checks:
        % Check if various interdependent fields of a class are consistent
        % between each other.
        function  [ok,mess] = check_joint_fields(obj)
            error('IX_dataset_tester:not_implemented','check_joint_fields not implemented')
        end
        % verify and set signal or error arrays
        function obj = check_and_set_sig_err(obj,field_name,value)
            error('IX_dataset_tester:not_implemented','check_and_set_sig_err not implemented')
        end
    end
    
    %======================================================================
    methods(Static,Access=protected)
        % Rebins histogram data along specific axis.
        function [wout_s, wout_e] = rebin_hist(iax,wout_x, use_mex, force_mex)
            error('IX_dataset_tester:not_implemented','rebin_hist not implemented')
        end
        %Integrates point data along along specific axis.
        function [wout_s,wout_e] = integrate_points(iax,xbounds_true, use_mex, force_mex)
            error('IX_dataset_tester:not_implemented','integrate_points not implemented')
        end
    end
end


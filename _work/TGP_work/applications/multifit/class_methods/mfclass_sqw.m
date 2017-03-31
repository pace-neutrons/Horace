classdef mfclass_sqw < mfclass
% Simultaneously fit functions to several datasets, with optional
% background functions. The foreground function(s) and background
% function(s) can be set to apply globally to all datasets, or locally,
% one function per dataset.
%
% mfclass_sqw Methods:
%
% To set data:
%   set_data     - Set data, clearing any existing datasets
%   append_data  - Append further datasets to the current set of datasets
%   remove_data  - Remove one or more dataset(s)
%   replace_data - Replace one or more dataset(s)
%
% To mask data points:
%   set_mask     - Mask data points
%   add_mask     - Mask additional data points
%   clear_mask   - Clear masking for one or more dataset(s)
%
% To set fitting functions:
%   set_fun      - Set foreground fit functions
%   set_bfun     - Set background fit functions
%   clear_fun    - Clear one or more foreground fit functions
%   clear_bfun   - Clear one or more background fit functions
%
% To set which parameters are fixed or free:
%   set_free     - Set free or fix foreground function parameters
%   set_bfree    - Set free or fix background function parameters
%   clear_free   - Clear all foreground parameters to be free for one or more data sets
%   clear_bfree  - Clear all background parameters to be free for one or more data sets
%
% To bind parameters:
%   set_bind     - Bind foreground parameter values in fixed ratios
%   set_bbind    - Bind background parameter values in fixed ratios
%   add_bind     - Add further foreground function bindings
%   add_bbind    - Add further background function bindings
%   clear_bind   - Clear parameter bindings for one or more foreground functions
%   clear_bbind  - Clear parameter bindings for one or more background functions
%
% To set functions as operating globally or local to a single dataset
%   set_global_foreground - Specify that there will be a global foreground fit function
%   set_global_background - Specify that there will be a global background fit function
%   set_local_foreground  - Specify that there will be local foreground fit function(s)
%   set_local_background  - Specify that there will be local background fit function(s)
%
% To fit or simulate:
%   fit          - Fit data
%   simulate     - Simulate datasets at the initial parameter values
%
% Fiting and other options:
%   set_options  - Set options
%   get_options  - Get values of one or more specific options

    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_purpose_summary_file = fullfile(mfclass_doc,'purpose_summary.m')
    %   mfclass_methods_summary_file = fullfile(mfclass_doc,'methods_summary.m')
    %
    %   class_name = 'mfclass_sqw'
    %
    % <#doc_beg:> multifit
    %   <#file:> <mfclass_purpose_summary_file>
    %
    % <class_name> Methods:
    %
    %   <#file:> <mfclass_methods_summary_file>
    % <#doc_end:>


    properties
        average = false;
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_sqw (varargin)
            obj@mfclass(varargin{:});
        end

        %------------------------------------------------------------------
        % Set/get methods
        %------------------------------------------------------------------
        function obj = set.average (obj, val)
            if islognumscalar(val)
                obj.average = logical(val);
            else
                error ('Propery named ''average'' must be a logical scalar (or numeric 0 or 1)')
            end
        end

        %------------------------------------------------------------------
        % Extend superclass methods
        %------------------------------------------------------------------
        function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
            % Update parameter wrapping according to 'average' property and wrapping function
            wrapfun = obj.wrapfun_;
            if obj.average && strcmp(wrapfun.dataset_class,'sqw')
                if isequal(wrapfun.fun_wrap,@sqw_eval)
                    wrapfun = wrapfun.append_p_wrap ('ave');
                end
                if isequal(wrapfun.bfun_wrap,@sqw_eval)
                    wrapfun = wrapfun.append_bp_wrap ('ave');
                end
            end
            obj_tmp = obj;
            obj_tmp.wrapfun_ = wrapfun;
            [data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
        end

        function [data_out, calcdata, ok, mess] = fit (obj)
            % Update parameter wrapping according to 'average' property and wrapping function
            wrapfun = obj.wrapfun_;
            if obj.average && strcmp(wrapfun.dataset_class,'sqw')
                if isequal(wrapfun.fun_wrap,@sqw_eval)
                    wrapfun = wrapfun.append_p_wrap ('ave');
                end
                if isequal(wrapfun.bfun_wrap,@sqw_eval)
                    wrapfun = wrapfun.append_bp_wrap ('ave');
                end
            end
            obj_tmp = obj;
            obj_tmp.wrapfun_ = wrapfun;
            [data_out, calcdata, ok, mess] = fit@mfclass (obj_tmp);
        end
    end
end

classdef mfclass_sqw < mfclass
    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_purpose_summary_file = fullfile(mfclass_doc,'purpose_summary.m')
    %   mfclass_methods_summary_file = fullfile(mfclass_doc,'methods_summary.m')
    %
    %   class_name = 'mfclass_sqw'
    %
    % <#doc_beg:>
    %   <#file:> <mfclass_purpose_summary_file>
    %
    % <class_name> Methods:
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

classdef mfclass_sqw < mfclass
    % mfclass_sqw
    % To be used by sqw methods multifit_sqw and multifit_sqw_sqw
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
                    wrapfun.p_wrap = [wrapfun.p_wrap,{'ave'}];
                end
                if isequal(wrapfun.bfun_wrap,@sqw_eval)
                    wrapfun.bp_wrap = [wrapfun.bp_wrap,{'ave'}];
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
                    wrapfun.p_wrap = [wrapfun.p_wrap,{'ave'}];
                end
                if isequal(wrapfun.bfun_wrap,@sqw_eval)
                    wrapfun.bp_wrap = [wrapfun.bp_wrap,{'ave'}];
                end
            end
            obj_tmp = obj;
            obj_tmp.wrapfun_ = wrapfun;
            [data_out, calcdata, ok, mess] = fit@mfclass (obj_tmp);
        end
    end
end

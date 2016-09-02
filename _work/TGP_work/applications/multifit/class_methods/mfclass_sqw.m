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
                    wrapfun.p_wrap = append_cell (wrapfun.p_wrap, 'ave');
                end
                if isequal(wrapfun.bfun_wrap,@sqw_eval)
                    wrapfun.bp_wrap = append_cell (wrapfun.bp_wrap, 'ave');
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
                    wrapfun.p_wrap = append_cell (wrapfun.p_wrap, 'ave');
                end
                if isequal(wrapfun.bfun_wrap,@sqw_eval)
                    wrapfun.bp_wrap = append_cell (wrapfun.bp_wrap, 'ave');
                end
            end
            obj_tmp = obj;
            obj_tmp.wrapfun_ = wrapfun;
            [data_out, calcdata, ok, mess] = fit@mfclass (obj_tmp);
        end
    end
end

%--------------------------------------------------------------------------------------------------
function Cout = append_cell (C,varargin)
% Append arguments to a row cell array. If the inital argument C is not a
% cell array, it becomes the first argument of the output cell array.
% If no arguments are to be appended, then Cout is identical to C (i.e. it
% is NOT changed into a cell array with one element)

if numel(varargin)>0
    if ~iscell(C)
        Cout = [{C},varargin];
    else
        Cout = [C,varargin];
    end
else
    Cout = C;
end

end

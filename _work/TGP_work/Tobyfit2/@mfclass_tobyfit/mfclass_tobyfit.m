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
    
    methods (Access=private)
        [ok, mess, obj, xtal] = refine_crystal_pack_parameters_ (obj, xtal_opts)

        [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj, mod_opts)

    end
end

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
            wrapfun.p_wrap = append_cell (wrapfun.p_wrap, obj.mc_contributions, obj.mc_points, [], []);
            obj_tmp.wrapfun_ = wrapfun;
                        
            % Perform simulation
            [data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
        end
        
        function [data_out, calcdata, ok, mess] = fit (obj)
            % Create cleanup object
            cleanupObj=onCleanup(@() tobyfit_cleanup);
            
            % Check there is data
            data = obj.data;
            if isempty(data)
                error('No data sets have been set - nothing to fit')
            end
            
            % Update parameter wrapping
            obj_tmp = obj;
            if ~isempty(obj_tmp.refine_crystal)
                [ok, mess, obj_tmp, xtal] = refine_crystal_pack_parameters_ (obj_tmp);
                if ~ok, error(mess), end
            else
                xtal = [];
            end
            if ~isempty(obj_tmp.refine_moderator)
                [ok, mess, obj_tmp, modshape] = refine_moderator_pack_parameters_ (obj_tmp);
                if ~ok, error(mess), end
            else
                modshape = [];
            end
            
            wrapfun = obj_tmp.wrapfun_;
            wrapfun.p_wrap = append_cell (wrapfun.p_wrap, obj.mc_contributions, obj.mc_points,...
                xtal, modshape);
            obj_tmp.wrapfun_ = wrapfun;
            
            % Perform fit
            [data_out, calcdata, ok, mess] = fit@mfclass (obj_tmp);
            
            % Extract crystal or moderator refinement parameters (if any) in a useful form
        end
    end
    
    methods (Access=private)
        [ok, mess, obj, xtal] = refine_crystal_pack_parameters_ (obj, xtal_opts)
        [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj, mod_opts)
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

%--------------------------------------------------------------------------------------------------
function tobyfit_cleanup
% Cleanup Tobyfit

% Cleanup the random number generator store (and any other control parameters for the datasets)
resol_conv_tobyfit_mc_control

% Cleanup the stored buffer for moderator fitting
refine_moderator_sampling_table_buffer

end

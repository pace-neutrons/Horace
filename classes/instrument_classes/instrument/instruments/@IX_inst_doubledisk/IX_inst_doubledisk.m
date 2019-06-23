classdef IX_inst_doubledisk < IX_inst
    % Instrument with double disk shaping and monochromating choppers
    
    properties (Access=private)
        mod_shape_mono_ = IX_mod_shape_mono
        horiz_div_ = IX_divergence_profile
        vert_div_ = IX_divergence_profile
    end
    
    properties (Dependent)
        moderator       % Moderator (object of class IX_moderator)
        shaping_chopper % Moderator shaping chopper (object of class IX_doubledisk_chopper)
        mono_chopper    % Monochromating chopper (object of class IX_doubledisk_chopper)
        horiz_div       % Horizontal divergence lookup (object of class IX_divergence profile)
        vert_div        % Vertical divergence lookup (object of class IX_divergence profile)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst_doubledisk (varargin)
            % Create double disk chopper instrument
            
            % General case
            namelist = {'moderator','shaping_chopper','mono_chopper',...
                'horiz_div','vert_div','name','source'};
            [S, present] = parse_args_namelist (namelist, varargin{:});
            
            % Set instrument base
            if present.name && present.source
                args = {S.name,S.source};
            elseif present.name
                args = {S.name};
            elseif present.source
                args = {'-source',S.source};
            else
                args = {};
            end
            obj@IX_inst(args{:});
            
            % Set monochromating components
            if present.moderator && present.shaping_chopper && present.mono_chopper
                obj.mod_shape_mono_ = IX_mod_shape_mono(S.moderator,...
                    S.shaping_chopper, S.mono_chopper);
            else
                error('Must give all of moderator, shaping, and monochromating chopper')
            end
            
            % Set divergences
            if present.horiz_div && present.vert_div
                obj.horiz_div_ = S.horiz_div;
                obj.vert_div_ = S.vert_div;
            else
                error('Must give both the horizontal and vertical divegences')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for independent properties
        %
        % Devolve any checks on interdependencies to the constructor (where
        % we refer only to the independent properties) and in the set
        % functions for the dependent properties.
        %
        % There is a synchronisation that must be maintained as the checks
        % in both places must be identical.
        
        function obj=set.mod_shape_mono_(obj,val)
            if isa(val,'IX_mod_shape_mono') && isscalar(val)
                obj.mod_shape_mono_ = val;
            else
                error('''mod_shape_mono_'' must be an IX_mod_shape_mono_ object')
            end
        end
        
        function obj=set.horiz_div_(obj,val)
            if isa(val,'IX_divergence_profile') && isscalar(val)
                obj.horiz_div_ = val;
            else
                error('The horizontal divergence must be an IX_divergence_profile object')
            end
        end
        
        function obj=set.vert_div_(obj,val)
            if isa(val,'IX_divergence_profile') && isscalar(val)
                obj.vert_div_ = val;
            else
                error('The vertical divergence must be an IX_divergence_profile object')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.moderator(obj,val)
            obj.mod_shape_mono_.moderator = val;
        end
        
        function obj=set.shaping_chopper(obj,val)
            obj.mod_shape_mono_.shaping_chopper = val;
        end
        
        function obj=set.mono_chopper(obj,val)
            obj.mod_shape_mono_.mono_chopper = val;
        end
        
        function obj=set.horiz_div(obj,val)
            obj.horiz_div_ = val;
        end
        
        function obj=set.vert_div(obj,val)
            obj.vert_div_ = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.moderator(obj)
            val = obj.mod_shape_mono_.moderator;
        end
        
        function val=get.shaping_chopper(obj)
            val = obj.mod_shape_mono_.shaping_chopper;
        end
        
        function val=get.mono_chopper(obj)
            val = obj.mod_shape_mono_.mono_chopper;
        end
        
        function val=get.horiz_div(obj)
            val = obj.horiz_div_;
        end
        
        function val=get.vert_div(obj)
            val = obj.vert_div_;
        end
        
        %------------------------------------------------------------------
    end
end

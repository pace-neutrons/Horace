classdef IX_mod_shape_mono
    % Moderator - shaping chopper - monochromating chopper as a single object
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % may require checks against the other properties
        %
        % We use a trick to cache whether or not the shaping chopper has a
        % predominant effect on the pulse width. It is a private
        % non-dependent property, but is recomputed whenever a public (and
        % in this class) dependent property is changed that could alter it.
        %
        % ***************************************************************
        %    WARNING: Do not change the value of any private property
        %             within a class method. This risks making shaped_mod
        %             out of synchronisation with the other properties.
        %             Only change the public properties, as this will force
        %             a recalculation.
        % ***************************************************************
        class_version_ = 1;
        moderator_ = IX_moderator();
        shaping_chopper_ = IX_doubledisk_chopper();
        mono_chopper_ = IX_doubledisk_chopper();
        % The following are effectively cached dependent properties
        shaped_mod_ = false;    
        t_m_offset_ = zeros(1,8);
        t_chop_av_ = zeros(2,8);
        t_chop_cov_ = zeros(2,2,8);
    end
    
    properties (Dependent)
        % Mirrors of private properties
        moderator
        shaping_chopper
        mono_chopper
        energy
        shaped_mod
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_mod_shape_mono (varargin)
            % Create moderator-shaping chopper-monochromating chopper object
            %
            %   >> obj = IX_mod_shape_mono (moderator, shaping_chopper, mono_chopper)
            %   >> obj = IX_mod_shape_mono (moderator, shaping_chopper, mono_chopper, energy)
            %
            % Reuired:
            %   moderator       IX_moderator object
            %   shaping_chopper IX_doubledisk_chopper object
            %   mono_chopper    IX_doubledisk_chopper object
            %
            % Optional:
            %   energy          Neutron energy.
            %                   Default: taken from tne IX_moderator object
            
            
            % Original author: T.G.Perring
            
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_mod_shape_mono.loadobj(varargin{1});
                
            elseif nargin==3 || nargin==4
                obj.moderator_ = varargin{1};
                obj.shaping_chopper_ = varargin{2};
                obj.mono_chopper_ = varargin{3};
                if nargin==4
                    if valid_energy(varargin{4})
                        obj.moderator_.energy = varargin{4};
                    else
                        error('Energy must be a scalar value greater than or equal to zero')
                    end
                end
                obj.shaped_mod_ = obj.recompute_shaped_mod_();
                obj.t_m_offset_ = obj.t_m_offset_calibrate_();
                [obj.t_chop_cov_, obj.t_chop_av_] = obj.moments_ ();
                
            elseif nargin~=0
                error('Check the number of input arguments')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods
        %
        % Set the non-dependent properties. We cannot make the set
        % functions depend on other non-dependent properties (see Matlab
        % documentation). Have to devolve any checks on interdependencies to the
        % constructor (where we refer only to the non-dependent properties)
        % and in the set functions for the dependent properties. There is a
        % synchronisation that must be maintained as the checks in both places
        % must be identical.
        
        function obj=set.moderator_(obj,val)
            if ~isscalar(val) || ~isa(val,'IX_moderator')
                error('Moderator must be scalar IX_moderator object')
            end
            obj.moderator_ = val;
        end
        
        function obj=set.shaping_chopper_(obj,val)
            if ~isscalar(val)
                error('Moderator shaping chopper must be scalar')
            end
            obj.shaping_chopper_ = val;
        end
        
        function obj=set.mono_chopper_(obj,val)
            if ~isscalar(val)
                error('Monochromating chopper must be scalar')
            end
            obj.mono_chopper_ = val;
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.moderator(obj,val)
            obj.moderator_ = val;
            obj.shaped_mod_ = obj.recompute_shaped_mod_();
            obj.t_m_offset_ = obj.t_m_offset_calibrate_();
            [obj.t_chop_cov_, obj.t_chop_av_] = obj.moments_ ();
        end
        
        function obj=set.shaping_chopper(obj,val)
            obj.shaping_chopper_ = val;
            obj.shaped_mod_ = obj.recompute_shaped_mod_();
            obj.t_m_offset_ = obj.t_m_offset_calibrate_();
            [obj.t_chop_cov_, obj.t_chop_av_] = obj.moments_ ();
        end
        
        function obj=set.mono_chopper(obj,val)
            obj.mono_chopper_ = val;
            obj.shaped_mod_ = obj.recompute_shaped_mod_();
            obj.t_m_offset_ = obj.t_m_offset_calibrate_();
            [obj.t_chop_cov_, obj.t_chop_av_] = obj.moments_ ();
        end
        
        function obj=set.energy(obj,val)
            if valid_energy(val)
                if val~=obj.moderator_.energy
                    obj.moderator_.energy = val;
                    obj.shaped_mod_ = obj.recompute_shaped_mod_();
                    obj.t_m_offset_ = obj.t_m_offset_calibrate_();
                    [obj.t_chop_cov_, obj.t_chop_av_] = obj.moments_ ();
                end
            else
                error('Energy must be a scalar value greater than or equal to zero')
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.moderator(obj)
            val=obj.moderator_;
        end
        
        function val=get.shaping_chopper(obj)
            val=obj.shaping_chopper_;
        end
        
        function val=get.mono_chopper(obj)
            val=obj.mono_chopper_;
        end
        
        function val=get.energy(obj)
            val=obj.moderator_.energy;
        end
        
        function val=get.shaped_mod(obj)
            val=obj.shaped_mod_;
        end
        
        %------------------------------------------------------------------
    end
    
    methods(Hidden)
        %------------------------------------------------------------------
        % Private methods
        %------------------------------------------------------------------
        function status = recompute_shaped_mod_(obj)
            % Determine if the shaping chopper predominantly determines the
            % initial pulse width (i.e. status==true if the shaping chopper
            % pulse width is less than the scaled moderator pulse width at
            % the shaping chopper position)
            x1 = obj.mono_chopper_.distance;
            x0 = obj.moderator_.distance - x1;          % distance from mono chopper to moderator face
            xa = obj.shaping_chopper_.distance - x1;    % distance from shaping chopper to mono chopper
            [~,~,fwhh_moderator] = pulse_width(obj.moderator_);
            [~,fwhh_shaping_chopper] = pulse_width(obj.shaping_chopper_);
            status = ((x0/xa)*fwhh_shaping_chopper < fwhh_moderator);
        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility
    
    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

%------------------------------------------------------------------
function status = valid_energy (val)
status = (isscalar(val) && isnumeric(val) && val>=0);
end

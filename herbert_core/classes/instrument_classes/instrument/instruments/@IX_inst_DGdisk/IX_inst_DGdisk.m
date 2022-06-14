classdef IX_inst_DGdisk < IX_inst
    % Instrument with double disk shaping and monochromating choppers
    
    properties (Access=private)
        class_version_ = 1;
        mod_shape_mono_ = IX_mod_shape_mono
        horiz_div_ = IX_divergence_profile
        vert_div_ = IX_divergence_profile
    end
    
    properties (Dependent)
        mod_shape_mono  % Moderator-shaping chopper-monochromating chopper combination
        moderator       % Moderator (object of class IX_moderator)
        shaping_chopper % Moderator shaping chopper (object of class IX_doubledisk_chopper)
        mono_chopper    % Monochromating chopper (object of class IX_doubledisk_chopper)
        horiz_div       % Horizontal divergence lookup (object of class IX_divergence profile)
        vert_div        % Vertical divergence lookup (object of class IX_divergence profile)
        energy          % Incident neutron energy (meV)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst_DGdisk (varargin)
            % Create double disk chopper instrument
            %
            %   obj = IX_inst_DGdisk (moderator, shaping_chopper, mono_chopper,...
            %               horiz_div, vert_div)
            %
            % Optionally:
            %   obj = IX_inst_DGdisk (..., energy)
            %
            %  one or both of:
            %   obj = IX_inst_DGdisk (..., '-name', name)
            %   obj = IX_inst_DGdisk (..., '-source', source)
            %
            %   moderator       Moderator (IX_moderator object)
            %   shaping_chopper Moderator shaping chopper (IX_doubledisk_chopper object)
            %   mono_chopper    Monochromating chopper (IX_doubledisk_chopper object)
            %   horiz_div       Horizontal divergence (IX_divergence object)
            %   vert_div        Vertical divergence (IX_divergence object)
            %   energy          Neutron energy (meV)
            %   name            Name of instrument (e.g. 'LET')
            %   source          Source: name (e.g. 'ISIS') or IX_source object
            
            % General case
            % make DGdisk not empty by default
            obj.name_ = '_';
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst_DGdisk.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'moderator','shaping_chopper','mono_chopper',...
                    'horiz_div','vert_div','energy','name','source'};
                [S, present] = parse_args_namelist (namelist, varargin{:});
                
                % Superclass properties: TODO: call superclass to set them
                if present.name
                    obj.name_ = S.name;
                end
                if present.source
                    obj.source_ = S.source;
                end
                
                % Set monochromating components
                if present.moderator && present.shaping_chopper && present.mono_chopper
                    if present.energy
                        obj.mod_shape_mono_ = IX_mod_shape_mono(S.moderator,...
                            S.shaping_chopper, S.mono_chopper, S.energy);
                    else
                        obj.mod_shape_mono_ = IX_mod_shape_mono(S.moderator,...
                            S.shaping_chopper, S.mono_chopper);
                    end
                else
                    error('Must give all of moderator, shaping, and monochromating chopper')
                end
                
                % Set divergences
                if present.horiz_div && present.vert_div
                    obj.horiz_div_ = S.horiz_div;
                    obj.vert_div_ = S.vert_div;
                else
                    error('Must give both the horizontal and vertical divergences')
                end
                
            end

        end
        
        % SERIALIZABLE interface
        %---------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end

        function flds = saveableFields(obj)
            baseflds = saveableFields@IX_inst(obj);
            flds = { baseflds{:}, 'mod_shape_mono','moderator','shaping_chopper','mono_chopper',...
                    'horiz_div',     'vert_div', 'energy'};
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
                error('''mod_shape_mono_'' must be an IX_mod_shape_mono object')
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
        function obj=set.mod_shape_mono(obj,val)
            obj.mod_shape_mono_ = val;
        end
        
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
        
        function obj=set.energy(obj,val)
            obj.mod_shape_mono_.energy = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.mod_shape_mono(obj)
            val = obj.mod_shape_mono_;
        end
        
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
        
        function val=get.energy(obj)
            val = obj.mod_shape_mono_.energy;
        end
        
        %------------------------------------------------------------------
    end
    
    methods(Access=protected)
        %------------------------------------------------------------------
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_struct
            % function, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            inputs = convert_old_struct_(obj,inputs);
            % optimization here is possible to not to use the public
            % interface. But is it necessary? its the question
            obj = from_old_struct@serializable(obj,inputs);
            
        end
    end
    
    
    %======================================================================
    % Custom loadobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility
    
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
            obj = IX_inst_DGdisk();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================

    
end

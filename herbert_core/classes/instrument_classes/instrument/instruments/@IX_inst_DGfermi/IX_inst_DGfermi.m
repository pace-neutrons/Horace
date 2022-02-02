classdef IX_inst_DGfermi < IX_inst
    % Instrument with Fermi monochromating chopper
    
    properties (Access=private)
        class_version_ = 1;
        moderator_ = IX_moderator
        aperture_ = IX_aperture
        fermi_chopper_ = IX_fermi_chopper
    end
    
    properties (Dependent)
        moderator       % Moderator (object of class IX_moderator)
        aperture        % Aperture (object of class IX_aperture)
        fermi_chopper   % Monochromating chopper (object of class IX_fermi_chopper)
        energy          % Incident neutron energy (meV)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst_DGfermi (varargin)
            % Create Fermi chopper instrument
            %
            %   obj = IX_inst_DGfermi (moderator, aperture, fermi_chopper)
            %
            % Optionally:
            %   obj = IX_inst_DGfermi (..., energy)
            %
            %  one or both of:
            %   obj = IX_inst_DGfermi (..., '-name', name)
            %   obj = IX_inst_DGfermi (..., '-source', source)
            %
            %   moderator       Moderator (IX_moderator object)
            %   aperture        Aperture defining moderator area (IX_aperture object)
            %   fermi_chopper   Fermi chopper (IX_fermi_chopper object)
            %   energy          Neutron energy (meV)
            %   name            Name of instrument (e.g. 'LET')
            %   source          Source: name (e.g. 'ISIS') or IX_source object
            
            % General case
            % make DGfermi not empty by default
            obj.name_ = '_';
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst_DGfermi.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'moderator','aperture','fermi_chopper','energy',...
                    'name','source'};
                [S, present] = parse_args_namelist (namelist, varargin{:});
                
                % Superclass properties TODO: call superclass to set them
                if present.name
                    obj.name_ = S.name;
                end
                if present.source
                    obj.source_ = S.source;
                end
                
                % Set monochromating components
                if present.moderator && present.fermi_chopper
                    obj.moderator_ = S.moderator;
                    obj.fermi_chopper_ = S.fermi_chopper;
                    if present.energy
                        obj.moderator_.energy = S.energy;
                        obj.fermi_chopper_.energy = S.energy;
                    end
                else
                    error('HERBERT:IX_inst_DGfermi:invalid_argument',...
                        'Must give both moderator and fermi chopper')
                end
                
                % Set aperture
                if present.aperture
                    obj.aperture_ = S.aperture;
                else
                    error('HERBERT:IX_inst_DGfermi:invalid_argument',...
                        'Must give the beam defining aperture after the moderator');
                end
                
            end
        end
        
        % SERIALIZABLE interface
        %-----------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end
        
        function flds = indepFields(obj)
            baseflds = indepFields@IX_inst(obj);
            flds = { baseflds{:},'moderator','aperture', 'fermi_chopper', 'energy'};
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
        
        function obj=set.moderator_(obj,val)
            if isa(val,'IX_moderator') && isscalar(val)
                obj.moderator_ = val;
            else
                error('The moderator must be an IX_moderator object')
            end
        end
        
        function obj=set.aperture_(obj,val)
            if isa(val,'IX_aperture') && isscalar(val)
                obj.aperture_ = val;
            else
                error('The aperture must be an IX_aperture object')
            end
        end
        
        function obj=set.fermi_chopper_(obj,val)
            if isa(val,'IX_fermi_chopper') && isscalar(val)
                obj.fermi_chopper_ = val;
            else
                error('The Fermi chopper must be an IX_fermi_chopper object')
            end
        end
        
        function obj=set.energy(obj,val)
            obj.moderator_.energy = val;
            obj.fermi_chopper_.energy = val;
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.moderator(obj,val)
            obj.moderator_ = val;
        end
        
        function obj=set.aperture(obj,val)
            obj.aperture_ = val;
        end
        
        function obj=set.fermi_chopper(obj,val)
            obj.fermi_chopper_ = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.moderator(obj)
            val = obj.moderator_;
        end
        
        function val=get.aperture(obj)
            val = obj.aperture_;
        end
        
        function val=get.fermi_chopper(obj)
            val = obj.fermi_chopper_;
        end
        
        function val=get.energy(obj)
            val = obj.moderator_.energy;
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
            obj = IX_inst_DGfermi();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

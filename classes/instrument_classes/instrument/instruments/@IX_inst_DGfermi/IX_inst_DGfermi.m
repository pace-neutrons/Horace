classdef IX_inst_DGfermi < IX_inst
    % Instrument with double disk shaping and monochromating choppers
    
    properties (Access=private)
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
            %   obj = IX_inst_DGdisk (..., '-name', name)
            %   obj = IX_inst_DGdisk (..., '-source', source)
            %
            % Input:
            %   moderator       Moderator (IX_moderator object)
            %   aperture        Aperture defining moderator area (IX_aperture object)
            %   fermi_chopper   Fermi chopper (IX_fermi_chopper object)
            %   energy          Neutron energy (meV)
            %   name            Name of instrument (e.g. 'LET')
            %   source          Source: name (e.g. 'ISIS') or IX_source object
            
            % General case
            namelist = {'moderator','aperture','fermi_chopper','energy',...
                'name','source'};
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
            if present.moderator && present.fermi_chopper
                obj.moderator_ = S.moderator;
                obj.fermi_chopper_ = S.fermi_chopper;
                if present.energy
                    obj.moderator_.energy = S.energy;
                    obj.fermi_chopper_.energy = S.energy;
                end
            else
                error('Must give both moderator and fermi chopper')
            end
            
            % Set aperture
            if present.aperture
                obj.aperture_ = S.aperture;
            else
                error('Must give the beam defining aperture after the moderator')
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
end

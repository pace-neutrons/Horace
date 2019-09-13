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
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst_DGfermi.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'moderator','aperture','fermi_chopper','energy',...
                    'name','source'};
                [S, present] = parse_args_namelist (namelist, varargin{:});
                
                % Superclass properties
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
                    error('Must give both moderator and fermi chopper')
                end
                
                % Set aperture
                if present.aperture
                    obj.aperture_ = S.aperture;
                else
                    error('Must give the beam defining aperture after the moderator')
                end
                
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

    
    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

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

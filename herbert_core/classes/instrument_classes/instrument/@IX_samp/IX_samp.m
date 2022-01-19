classdef IX_samp  < serializable
    % Base class for samples to include the null sample case defined from a
    % struct with no fields (IX_null_sample) and the standard IX_sample
    
    properties (Access=protected)
        name_ = '';   % suitable string to identify sample
        alatt_;
        angdeg_;
    end
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
    end
    
    properties
        %
    end
    
    properties (Dependent)
        % Mirrors of private/protected properties
        name;
        alatt;
        angdeg;
    end
    
    methods(Static)
        function isaval = cell_is_class(ca)
            try
                isaval = cellfun(@IX_samp.xxx, ca);
                if all(isaval), isaval = 1; else, isaval = 0; end
            catch
                error('HERBERT:IX_samp:cell_is_class', ...
                      'input could not be converted from cell to logical');
            end
        end
        function rv = xxx(obj)
            rv = isa(obj,'IX_samp');
        end
    end
    methods
        
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_samp (thename)
            % Create base sample object
            %
            %   >> base_sample = IX_samp (name)
            %
            if nargin==0
                obj.name_ = '';
            else
                obj.name_ = thename;
            end
        end
        
        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function vers = classVersion(~)
            vers = 0; % base class function, dummy value
        end
        
        function flds = indepFields(~)
            flds = {'name', 'alatt', 'angdeg'};
        end
        
        %
        % other methods
        %------------------------------------------------------------------
        function iseq = eq(obj1, obj2)
            iseq = strcmp(obj1.name, obj2.name);
            if numel(obj1.alatt)==3 && numel(obj2.alatt)==3
                iseq = iseq && obj1.alatt(1)==obj2.alatt(1);
                iseq = iseq && obj1.alatt(2)==obj2.alatt(2);
                iseq = iseq && obj1.alatt(3)==obj2.alatt(3);
            elseif isempty(obj1.alatt) && isempty(obj2.alatt)
                iseq = iseq && true; % heavyhanded but gets the point across
            else
                iseq = false;
                return
            end
            if numel(obj1.angdeg)==3 && numel(obj2.angdeg)==3
                iseq = iseq && obj1.angdeg(1)==obj2.angdeg(1);
                iseq = iseq && obj1.angdeg(2)==obj2.angdeg(2);
                iseq = iseq && obj1.angdeg(3)==obj2.angdeg(3);
            elseif isempty(obj1.angdeg) && isempty(obj2.angdeg)
                iseq = iseq && true; % heavyhanded but gets the point across
            else
                iseq = false;
                return
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
        
        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                if isempty(val)
                    obj.name_='';
                else
                    error('Sample name must be a character string (or empty string)')
                end
            end
        end
        
        function n=get.name(obj)
            n = obj.name_;
        end
        
        function obj=set.alatt(obj,val)
            if isnumeric(val)
                obj.alatt_=val;
            else
                error('Sample alatt must be a numeric vector')
            end
        end
        
        function n=get.alatt(obj)
            n = obj.alatt_;
        end
        
        function obj=set.angdeg(obj,val)
            if isnumeric(val)
                obj.angdeg_=val;
            else
                error('Sample alatt must be a numeric vector')
            end
        end
        
        function n=get.angdeg(obj)
            n = obj.angdeg_;
        end
    end
    methods(Sealed)
        %{
        function is = isempty(obj)
            % Assume that sample is empty if it was created with
            % empty constructor and has not been modified
            %
            % Assume that if a child is modified, it will also modify some
            % fields of the parent so the method will still work
            if numel(obj)==0
                is = true;
                return;
            end
            is = false(size(obj));
            for i=1:numel(obj)
                if isempty(obj(i).name_) && isempty(obj(i).alatt_)...
                        && isempty(obj(i).angdeg_)
                    is(i) = true;
                end
            end
        end
        %}
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
                S.name_ = '';
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
        %{
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
        %}
    end
    
    %------------------------------------------------------------------
    methods (Static)
        %{
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
        %}
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end


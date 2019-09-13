classdef IX_divergence_profile
    % Divergence profile class definition
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        %
        % We use a trick to cache the probability distribution function for
        % random sampling. It is a private non-dependent property, but is
        % recomputed whenever a public (and in this class) dependent property
        % is changed that could alter it.
        %
        % ***************************************************************
        %    WARNING: Do not change the value of any private property
        %             within a class method. This risks making pdf_
        %             out of synchronisation with the other properties.
        %             Only change the public properties, as this will force
        %             a recalculation.
        % ***************************************************************
        class_version_ = 1;
        name_ = '';
        angles_ = [];
        profile_ = [];
        pdf_ = pdf_table();     % This is effectively a cached dependent variable
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        angles
        profile
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_divergence_profile (varargin)
            % Create fermi chopper object
            %
            %   >> div = IX_divergence_profile (angles,profile)
            %
            %   >> div = IX_divergence_profile (name,...)
            %
            % Required:
            %   angles          Vector of divergences (radians)
            %   profile         Vector with profile. Does not need to be normalised
            %
            % Optional:
            %   name            Name of the divergence profile (e.g. 'LET new vertical')
            %
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the 
            % argument name (including abbreviations) with a preceding hyphen e.g.
            %
            %   div = IX_divergence_profile (angles,'-name','in-pile', '-profile', y)
            
            
            % Original author: T.G.Perring
            
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_divergence_profile.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','angles','profile'};
                [S, present] = parse_args_namelist ({namelist,{'char'}}, varargin{:});
                
                if present.name
                    obj.name_ = S.name;
                end

                if present.angles && present.profile
                    angles_in  = S.angles;
                    profile_in = S.profile;
                    
                    if isnumeric(angles_in) && isvector(angles_in) && numel(angles_in)>=2 && all(diff(angles_in)>=0)
                        obj.angles_=angles_in(:)';  % make a row vector
                    else
                        error('Angle array must be a vector length at least two and monotonic increasing')
                    end
                    
                    if numel(angles_in)~=numel(profile_in)
                        error('The number of values of angles and profile must match')
                    elseif isvector(profile_in) && all(isfinite(profile_in)) && all(profile_in>=0)
                        obj.profile_=profile_in(:)';
                    else
                        error('The profile values must all be finite and greater or equal to zero')
                    end
                    
                else
                    error('Must give both the divergence angles and profile')
                end

                % Compute the pdf
                obj.pdf_ = pdf_table (obj.angles_, obj.profile_);
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        % Currently do not permit any - it only makes sense to change the
        % profile as a whole, which is best done with the constructor
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end
        
        function val=get.angles(obj)
            val=obj.angles_;
        end
        
        function val=get.profile(obj)
            val=obj.profile_;
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

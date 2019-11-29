classdef IX_sample
    % Sample class definition
    
    properties (Constant, Access=private)
        shapes_ = fixedNameList({'point','cuboid'})   % valid sample types
        n_ps_ = containers.Map({'point','cuboid'},[0,3]) % number of parameters for sample description
    end
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        class_version_ = 1;
        name_ = '';
        single_crystal_ = true;
        xgeom_ = [1,0,0];
        ygeom_ = [0,1,0];
        shape_ = 'point';
        ps_ = [];
        eta_ = IX_mosaic();
        temperature_ = 0;
        
        valid_ = true;
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        single_crystal
        xgeom
        ygeom
        shape
        ps
        eta
        temperature
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_sample (varargin)
            % Create sample object
            %
            %   >> sample = IX_sample (xgeom,ygeom,shape,ps)
            %   >> sample = IX_sample (...,eta)
            %   >> sample = IX_sample (...,eta,temperature)
            %
            %   >> sample = IX_sample (name,...)
            %   >> sample = IX_sample (name,single_crystal,...)
            %
            % Required:
            %   xgeom           Direction of x-axis of geometric description
            %                   If single crystal: a vector in reciprocal lattice units
            %                   If powder: a vector in spectrometer coodinates
            %
            %   ygeom           Direction of y-axis of geometric description
            %                   If single crystal: a vector in reciprocal lattice units
            %                   If powder: a vector in spectrometer coodinates
            %
            %   shape           Sample shape (e.g. 'cuboid')
            %                   Default: 'point'
            %
            %   ps              Parameters for the sample shape description
            %                   Numeric row vector; length depends on shape
            %                   cuboid: full widths in m
            %
            % Optional:
            %   eta             Mosaic spread: one of
            %                   - Single number: mosaic spread FWHH (deg) for an
            %                     isotropic Gaussian mosaic distrubution
            %
            %                   - IX_mosaic object: more general description of
            %                     mosaic spread. See the help for  <a href="matlab:help('IX_mosaic');">IX_mosaic</a>]
            %
            %                   Ignored if not single crystal
            %
            %   temperature     Temperature of sample (K)
            %
            %   name            Name of the sample (e.g. 'YBCO 6.6')
            %
            %   single_crystal  true if single crystal, false otherwise
            %                   Default: true (i.e. single crystal)
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the 
            % argument name (including abbrevioations) with a preceding hyphen e.g.
            %
            %   sample = IX_sample (xgeom,ygeom,shape,ps,'-name','FeSi','-temp',273.16)

            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_sample.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','single_crystal','xgeom','ygeom','shape',...
                    'ps','eta','temperature'};
                [S, present] = parse_args_namelist ({namelist,{'char','logical'}}, varargin{:});
                
                if present.name
                    obj.name_ = S.name;
                end
                if present.single_crystal
                    obj.single_crystal_ = S.single_crystal;
                end
                if present.xgeom && present.ygeom && present.shape && present.ps
                    obj.xgeom_ = S.xgeom;
                    obj.ygeom_ = S.ygeom;
                    obj.shape_ = S.shape;
                    obj.ps_ = S.ps;
                else
                    error('Must give all arguments that define geometry and sample shape')
                end
                if present.eta
                    obj.eta_ = S.eta;
                end
                if present.temperature
                    obj.temperature_ = S.temperature;
                end
                
                [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
                if ~ok, error(mess), end
                if numel(obj.ps_)~=obj.n_ps_(obj.shape_)
                    error('The number of shape parameters is not correct for the sample type')
                end
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
        
        function obj=set.name_(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('Sample name must be a character string (or empty string)')
            end
        end
        
        function obj=set.single_crystal_(obj,val)
            if islognumscalar(val)
                obj.single_crystal_=logical(val);
            else
                error('single_crystal must true or false (or 1 or 0)')
            end
        end
        
        function obj=set.xgeom_(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.xgeom_=val(:)';
            else
                error('''xgeom'' must be a three-vector')
            end
        end
        
        function obj=set.ygeom_(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.ygeom_=val(:)';
            else
                error('''ygeom'' must be a three-vector')
            end
        end
        
        function obj=set.shape_(obj,val)
            if is_string(val) && ~isempty(val)
                [ok,mess,fullname] = obj.shapes_.valid(val);
                if ok
                    obj.shape_=fullname;
                else
                    error(['Sample shape: ',mess])
                end
            else
                error('Sample shape must be a non-empty character string')
            end
        end
        
        function obj=set.ps_(obj,val)
            if isnumeric(val) && (isempty(val) || isvector(val))
                if isempty(val)
                    obj.ps_=[];
                else
                    obj.ps_=val(:)';    % make a row vector
                end
            else
                error('Sample parameters must be a numeric vector')
            end
        end
        
        function obj=set.eta_(obj,val)
            if isa(val,'IX_mosaic') && isscalar(val)
                obj.eta_=val;
            elseif isnumeric(val)
                obj.eta_=IX_mosaic(val);
            else
                error('Mosaic spread must be numeric or an IX_mosaic object')
            end
        end
        
        function obj=set.temperature_(obj,val)
            if isnumeric(val) && isscalar(val) && val>=0
                obj.temperature_=val;
            else
                error('Temperature must be numeric scalar greater than or equal to zero')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.name(obj,val)
            obj.name_=val;
        end
        
        function obj=set.single_crystal(obj,val)
            obj.single_crystal_=val;
        end
        
        function obj=set.xgeom(obj,val)
            obj.xgeom_=val;
            [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
            if ~ok, error(mess), end
        end
        
        function obj=set.ygeom(obj,val)
            obj.ygeom_=val;
            [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
            if ~ok, error(mess), end
        end
        
        function obj=set.shape(obj,val)
            % Have to set the shape parameters to an invalid quantity if sample shape changes
            val_old = obj.shape_;
            obj.shape_=val;
            if ~strcmp(obj.shape,val_old)
                obj.ps_ = NaN;
                obj.valid_ = false;
            end
        end
        
        function obj=set.ps(obj,val)
            % Must check the numnber of parameters is consistent with the sample shape
            obj.ps_=val;
            if numel(obj.ps_)==obj.n_ps_(obj.shape_)
                obj.valid_=true;
            else
                error('The number of shape parameters is inconsistent with the shape type')
            end
        end
        
        function obj=set.eta(obj,val)
            obj.eta_=val;
        end
        
        function obj=set.temperature(obj,val)
            obj.temperature_=val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end
        
        function val=get.single_crystal(obj)
            val=obj.single_crystal_;
        end
        
        function val=get.xgeom(obj)
            val=obj.xgeom_;
        end
        
        function val=get.ygeom(obj)
            val=obj.ygeom_;
        end
        
        function val=get.shape(obj)
            val=obj.shape_;
        end
        
        function val=get.ps(obj)
            val=obj.ps_;
        end
        
        function val=get.eta(obj)
            val=obj.eta_;
        end
        
        function val=get.temperature(obj)
            val=obj.temperature_;
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

%------------------------------------------------------------------
% Utility functions to check dependent properties
function [ok,mess] = check_xygeom (x,y)
% assume x, y are each either three-vectors or empty
ok = true;
mess = '';
if ~(isempty(x) || isempty(y))
    if norm(cross(x,y))/(norm(x)*norm(y)) < 1e-5
        ok = false;
        mess='''xgeom'' and ''ygeom'' are colinear, or almost colinear';
    end
end
end

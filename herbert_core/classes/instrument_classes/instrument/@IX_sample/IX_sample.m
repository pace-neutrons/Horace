classdef IX_sample < IX_samp
    % Sample class definition

    properties (Constant, Access=private)
        shapes_ = fixedNameList({'point','cuboid'})   % valid sample types
        n_ps_ = containers.Map({'point','cuboid'},[0,3]) % number of parameters for sample description
    end

    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        hall_symbol_ = '';
        single_crystal_ = true;
        xgeom_ = [1,0,0];
        ygeom_ = [0,1,0];
        shape_ = 'point';
        ps_ = [];
        eta_ = IX_mosaic();
        temperature_ = 0;

        valid_ = true;
        %TODO: this is wrong. Refactor constructor. Temporary disable
        % checks of interdependent properties in constructor
        in_construction_ = false;
    end

    properties(Dependent,Hidden)
        xy_geom;
    end

    properties (Dependent)
        % Mirrors of private properties
        hall_symbol
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
            %   hall_symbol     Symmetry group (e.g. '')
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbrevioations) with a preceding hyphen e.g.
            %
            %   sample = IX_sample (xgeom,ygeom,shape,ps,'-name','FeSi','-temp',273.16)


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==0
                return
            end
            obj.in_construction_ = true;
            if nargin == 2
                obj.alatt = varargin{1};
                obj.angdeg = varargin{2};
            elseif nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_sample.loadobj(varargin{1});

            elseif nargin>0
                namelist = {'name','single_crystal','xgeom','ygeom',...
                    'shape','ps','eta','temperature','hall_symbol'};
                [S, present] = parse_args_namelist ({namelist,{'char','logical'}}, varargin{:});
                is_present = struct2cell(present);
                is_present = [is_present{:}];

                % Superclass properties: TODO: call superclass to set them
                if present.name
                    obj.name = S.name;
                    if sum(is_present)<2 % setting only name
                        obj.in_construction_ = false;
                        return;
                    end
                end

                if present.single_crystal
                    obj.single_crystal = S.single_crystal;
                end
                if present.xgeom && present.ygeom && present.shape && present.ps
                    obj.xgeom = S.xgeom;
                    obj.ygeom = S.ygeom;
                    obj.shape = S.shape;
                    obj.ps = S.ps;
                else
                    error('HERBERT:IX_sample:invalid_argument',...
                        'Must give all arguments that define geometry and sample shape')
                end
                if present.eta
                    obj.eta = S.eta;
                end
                if present.temperature
                    obj.temperature = S.temperature;
                end
                if present.hall_symbol
                    obj.hall_symbol = S.hall_symbol;
                end

                [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
                if ~ok, error(mess), end
                if numel(obj.ps_)~=obj.n_ps_(obj.shape_)
                    error('HERBERT:IX_sample:invalid_argument',...
                        'The number of shape parameters is not correct for the sample type')
                end
                obj.in_construction_ = false;
            end
        end

        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 3;
        end

        function flds = saveableFields(obj)
            baseflds = saveableFields@IX_samp(obj);
            flds = [baseflds, {'hall_symbol', 'single_crystal', ...
                'xy_geom','shape', 'ps', 'eta', 'temperature'}];
        end
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.eta(obj,val)
            if isa(val,'IX_mosaic') && isscalar(val)
                obj.eta_=val;
            elseif isnumeric(val)
                obj.eta_=IX_mosaic(val);
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'Mosaic spread must be numeric or an IX_mosaic object')
            end
        end

        function obj=set.temperature(obj,val)
            if isnumeric(val) && isscalar(val) && val>=0
                obj.temperature_=val;
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'Temperature must be numeric scalar greater than or equal to zero')
            end
        end

        function obj=set.hall_symbol(obj,val)
            if is_string(val)
                obj.hall_symbol_=val;
            else
                if isempty(val)
                    obj.hall_symbol_='';
                else
                    error('HERBERT:IX_sample:invalid_argument',...
                        'Sample Hall symbol must be a character string (or empty string)')
                end
            end
        end
        function obj=set.xgeom(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.xgeom_=val(:)';
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    '''xgeom'' must be a three-vector')
            end
            if ~obj.in_construction_
                [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
                if ~ok, error(mess), end
            end
        end
        function obj=set.ygeom(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.ygeom_=val(:)';
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    '''ygeom'' must be a three-vector')
            end
            if ~obj.in_construction_
                [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
                if ~ok, error('HERBERT:IX_sample:invalid_argument',mess)
                end
            end
        end
        function obj = set.xy_geom(obj,val)
            if isnumeric(val) && all(size(val)==[2,3]) && ~any(all(val'==0))
                obj.xgeom_=val(1,:);
                obj.ygeom_=val(2,:);
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    '''xy_geom'' must be a 2x3 matrix, combining two non-zero 3-vectors as strings')
            end
            [ok,mess] = check_xygeom (obj.xgeom_,obj.ygeom_);
            if ~ok, error('HERBERT:IX_sample:invalid_argument',mess)
            end
        end
        function xy = get.xy_geom(obj)
            xy = [obj.xgeom_;obj.ygeom_];
        end

        function obj=set.single_crystal(obj,val)
            if islognumscalar(val)
                obj.single_crystal_=logical(val);
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'single_crystal must true or false (or 1 or 0)')
            end
        end

        function obj=set.shape(obj,val)
            if is_string(val) && ~isempty(val)
                [ok,mess,fullname] = obj.shapes_.valid(val);
                if ok
                    obj.shape_=fullname;
                else
                    error('HERBERT:IX_sample:invalid_argument',...
                        ['Sample shape: ',mess])
                end
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'Sample shape must be a non-empty character string')
            end

            % Have to set the shape parameters to an invalid quantity if sample shape changes
            %             val_old = obj.shape_;
            %             obj.shape_=val;
            %             if ~strcmp(obj.shape,val_old)
            %                 obj.ps_ = NaN;
            %                 obj.valid_ = false;
            %             end
        end

        function obj=set.ps(obj,val)
            if isnumeric(val) && (isempty(val) || isvector(val))
                if isempty(val)
                    obj.ps_=[];
                else
                    obj.ps_=val(:)';    % make a row vector
                end
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'Sample parameters must be a numeric vector')
            end
            % Must check the numnber of parameters is consistent with the sample shape
            if numel(obj.ps_)==obj.n_ps_(obj.shape_)
                obj.valid_=true;
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'The number of shape parameters is inconsistent with the shape type')
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties

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

        function val=get.hall_symbol(obj)
            val=obj.hall_symbol_;
        end

        %------------------------------------------------------------------
        function is_eq = eq(obj1,obj2)
            s1 = obj1.to_bare_struct;
            s2 = obj2.to_bare_struct;
            is_eq = equal_to_tol(s1,s2);
        end

        function is_neq = ne(obj1, obj2)
            is_neq = ~eq(obj1, obj2);
        end
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
            obj = IX_sample();
            obj = loadobj@serializable(S,obj);
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

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
        mandatory_field_set_ = false(1,4);
        eta_ = IX_mosaic();
        temperature_ = 0;
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
            % argument name (including abbrevioations) e.g:.
            %
            %   sample = IX_sample (xgeom,ygeom,shape,ps,'name','FeSi','temp',273.16)


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==0
                return
            end
            if nargin == 2
                obj.alatt = varargin{1};
                obj.angdeg = varargin{2};
            elseif nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_sample.loadobj(varargin{1});

            elseif nargin>0
                % "name" processed separately in the interface
                % distinguisher
                interface1_par = {'single_crystal','xgeom','ygeom',...
                    'shape','ps','eta','temperature','hall_symbol'};
                interface2_par = {'xgeom','ygeom',...
                    'shape','ps','eta','temperature','hall_symbol'};
                base_par =IX_samp.fields_to_save_;
                % process deprecated interface where the value of "name"
                % property is first among the input arguments
                arg1 = varargin{1};
                if ischar(arg1)&&~strncmp(arg1,'-',1)&&...
                        ~strcmp(arg1,'name')&&~ismember(arg1 ,interface1_par)
                    argi = varargin(2:end);
                    obj.name = arg1;
                    pos_params = [interface1_par(:);base_par(:)]';
                elseif islogical(arg1)
                    pos_params = [interface1_par(:);base_par(:)]';
                    argi = varargin;
                else
                    argi = varargin;
                    pos_params = [interface2_par(:);base_par(:)]';
                end
                [obj,remains] = set_positional_and_key_val_arguments(obj,...
                    pos_params,true,argi{:});
                if ~isempty(remains)
                    error('HERBERT:IX_sample:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_sample constructor: %s',...
                        disp2str(remains));
                end
            end
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
                obj.mandatory_field_set_(1) = true;
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    '''xgeom'' must be a three-vector')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj=set.ygeom(obj,val)
            if isnumeric(val) && numel(val)==3 && ~all(val==0)
                obj.ygeom_=val(:)';
                obj.mandatory_field_set_(2) = true;
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    '''ygeom'' must be a three-vector')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj = set.xy_geom(obj,val)
            if isnumeric(val) && all(size(val)==[2,3]) && ~any(all(val'==0))
                obj.xgeom_=val(1,:);
                obj.ygeom_=val(2,:);
                obj.mandatory_field_set_(1:2) = true;
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    '''xy_geom'' must be a 2x3 matrix, combining two non-zero 3-vectors as strings')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
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
                    obj.mandatory_field_set_(3) = true;
                else
                    error('HERBERT:IX_sample:invalid_argument',...
                        ['Sample shape: ',mess])
                end
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'Sample shape must be a non-empty character string')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end

        function obj=set.ps(obj,val)
            if isnumeric(val) && (isempty(val) || isvector(val))
                if isempty(val)
                    obj.ps_=[];
                else
                    obj.ps_=val(:)';    % make a row vector
                end
                obj.mandatory_field_set_(4) = true;
            else
                error('HERBERT:IX_sample:invalid_argument',...
                    'Sample parameters must be a numeric vector')
            end
            % Must check the numnber of parameters is consistent with the sample shape
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
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
    end
    methods
        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 3;
        end

        function flds = saveableFields(obj,mandatory)
            % If "mandatory" key is provided, return the subset of values
            % necessary for non-empty class to be defined
            if nargin>1
                mandatory = true;
            else
                mandatory = false;
            end
            if mandatory
                flds = {'xgeom','ygeom','shape','ps'};
            else
                baseflds = saveableFields@IX_samp(obj);
                flds = [baseflds(1:2), {'hall_symbol', 'single_crystal', ...
                    'xy_geom','shape', 'ps', 'eta', 'temperature',baseflds{end}}];

            end
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing dependent variables
            %  if requested.

            if any(obj.mandatory_field_set_)
                if ~all(obj.mandatory_field_set_)
                    mandatory_field_names = obj.saveableFields('mandatory');
                    error('HERBERT:IX_sample:invalid_argument', ...
                        'If any of the mandatory properties (%s) is set, all mandatory properties must be set\n. Properties: %s have not been set', ...
                        disp2str(mandatory_field_names),...
                        disp2str(mandatory_field_names(~obj.mandatory_field_set_)));
                end
            end
            %
            if ~(isempty(obj.xgeom_) || isempty(obj.ygeom_))
                if norm(cross(obj.xgeom_,obj.ygeom_))/(norm(obj.xgeom_)*norm(obj.ygeom_)) < 1e-5
                    error('HERBERT:IX_sample:invalid_argument',...
                        '"xgeom=%s" and "ygeom=%s" vectors are colinear, or almost colinear', ...
                        disp2str(obj.xgeom_),disp2str(obj.ygeom_));
                end
            end
            %
            if numel(obj.ps_)~=obj.n_ps_(obj.shape_)
                error('HERBERT:IX_sample:invalid_argument',...
                    'The number of shape parameters is not correct for the sample type')
            end
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
            % function, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
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

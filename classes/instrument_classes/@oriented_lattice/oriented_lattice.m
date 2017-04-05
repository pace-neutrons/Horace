classdef oriented_lattice
    % class describes main properties of a sample with oriented lattice
    % under neutron scattering or x-ray investigation.
    % and contains various service functions to work with such sample
    %
    %
    %
    % $Revision$ ($Date$)
    %
    %
    % On 2017/03 it is far from completeon and have many of its methods
    % dublicated elsewhere.
    %
    properties(Dependent)
        % All angular units set in degrees but can be retrieved indegrees
        % or radians
        alatt     = [];     % Lattice parameters [a,b,c] (Ang^-1)   -- has to be in file or supplied  as  parameters list
        angdeg    = [];     % Lattice angles [alf,bet,gam] (deg)    -- has to be in file or supplied  as  parameters list
        
        % Crystal orientation
        u         = [1,0,0];
        v         = [0,1,0];
        
        % Goniometer parameters
        psi   = [];         %  Angle of u w.r.t. ki (deg)  [Default=0]
        omega = 0;         %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi  = 0;         %  Correction to psi (deg)  [Default=0]
        gl    = 0;         %  Large goniometer arc angle (deg)  [Default=0]
        gs    = 0;         %  Small goniometer arc angle (deg)  [Default=0]
        % what units (deg or rad) all angular units have. (All angular
        % units have to be set in degrees)
        angular_units;
    end
    
    
    properties(Access=private)
        %
        alatt_  = [];
        angdeg_ = [];
        
        % the defaults for these fields are:
        u_    = [1,0,0];
        v_   = [0,1,0];
        % Goniometer parameters
        psi_   = [];         %  Angle of u w.r.t. ki (deg)  [Default=0]
        omega_ = 0;         %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi_  = 0;         %  Correction to psi (deg)  [Default=0]
        gl_    = 0;         %  Large goniometer arc angle (deg)  [Default=0]
        gs_    = 0;         %  Small goniometer arc angle (deg)  [Default=0]
        
        % by default, units used in the class are degree.
        angular_units_= 'deg';
        
        
        % service variable used to help viewing u,v
        uv_cros_=[0,0,1]; % cross(u,v);
        surf_ar_ = 1;  % abs(uv_cros_.*uv_cros_);
    end
    properties(Constant,Access=private)
        % List of fields which have default values and do not have to be always defined by either file or command arguments;
        fields_have_defaults_ = {'omega','dpsi','gl','gs','u','v'};
        % List of the fields which describe lattice.
        lattice_parameters_ = {'alatt','angdeg','psi','omega','dpsi','gl','gs','u','v'}
        % radian to degree transformation constant
        deg_to_rad_=pi/180;
    end
    %
    methods
        % constructor
        function self = oriented_lattice(varargin)
            if(nargin>0)
                if (~(isstruct(varargin{1}) || isa(varargin{1},'oriented_lattice')))
                    error('ORIENTED_LATTICE:invalid_argument','Oriented lattice may be constructed ony with input structure, containing the same fields as public fields of the oriented lattice itself');
                end
                if isa(varargin{1},'oriented_lattice')
                    self = varargin{1};
                else
                    input = varargin{1};
                    field_names = fieldnames(input);
                    for i=1:numel(field_names)
                        self.(field_names{i}) = input.(field_names{i});
                    end
                end
            end
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function units = get.angular_units(this)
            units = this.angular_units_;
        end
        %
        function this = set.angular_units(this,val)
            if val(1) == 'd'
                this.angular_units_ = 'deg';
            elseif val(1) == 'r'
                this.angular_units_ = 'rad';
            else
            end
        end
        %
        function this = set_deg(this)
            this.angular_units_= 'deg';
        end
        %
        function this = set_rad(this)
            this.angular_units_= 'rad';
        end
        %
        function public_struct = struct(this)
            % convert class into structure, containing public-accessible information
            pub_fields = [oriented_lattice.lattice_parameters_,{'angular_units'}];
            public_struct  = struct();
            for i=1:numel(pub_fields)
                public_struct.(pub_fields{i}) = this.(pub_fields{i});
            end
            
        end
        
        %-----------------------------------------------------------------
        function psi = get.psi(this)
            psi = oriented_lattice.transform_and_get_angular(this.angular_units_,this.psi_);
        end
        function omega = get.omega(this)
            omega=oriented_lattice.transform_and_get_angular(this.angular_units_,this.omega_);
        end
        function dpsi = get.dpsi(this)
            dpsi=oriented_lattice.transform_and_get_angular(this.angular_units_,this.dpsi_);
        end
        function gl=get.gl(this)
            gl=oriented_lattice.transform_and_get_angular(this.angular_units_,this.gl_);
        end
        function gs=get.gs(this)
            gs=oriented_lattice.transform_and_get_angular(this.angular_units_,this.gs_);
        end
        function this = set.psi(this,val)
            this.psi_=oriented_lattice.check_angular_set(val);
        end
        function this = set.omega(this,val)
            this.omega_=oriented_lattice.check_angular_set(val);
        end
        function this  = set.dpsi(this,val)
            this.dpsi_=oriented_lattice.check_angular_set(val);
        end
        function this =set.gl(this,val)
            this.gl_=oriented_lattice.check_angular_set(val);
        end
        function this =set.gs(this,val)
            this.gs_=oriented_lattice.check_angular_set(val);
        end
        %-----------------------------------------------------------------
        function u=get.u(this)
            if this.surf_ar_<1.e-6
                u=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u_,this.v_);
            else
                u=this.u_;
            end
        end
        function v=get.v(this)
            if this.surf_ar_<1.e-6
                v=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u_,this.v_);
            else
                v=this.v_;
            end
        end
        function this=set.u(this,u)
            this.u_=oriented_lattice.check_3Dvector(u);
            %
            this.uv_cros_=cross(this.u_,this.v_);
            this.surf_ar_ = sum(this.uv_cros_.*this.uv_cros_);
        end
        function this=set.v(this,v)
            this.v_=oriented_lattice.check_3Dvector(v);
            %
            this.uv_cros_=cross(this.u_,this.v_);
            this.surf_ar_ = sum(this.uv_cros_.*this.uv_cros_);
        end
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function alat=get.alatt(this)
            alat = this.alatt_;
        end
        function angdeg=get.angdeg(this)
            %angdeg= oriented_lattice.transform_and_get_angular(this.angular_units_,this.angdeg_);
            angdeg= this.angdeg_;
        end
        %
        function this=set.alatt(this,val)
            this.alatt_ = oriented_lattice.check_3Dvector(val);
            
        end
        function this=set.angdeg(this,val)
            this.angdeg_ = oriented_lattice.check_3DAngles_correct(val);
        end
        %---
        function undef_fields=get_undef_fields(obj)
            % return list of lattice fiels which should be defined but
            % still not
            function is=undef_field(obj,field)
                if isempty(obj.(field))
                    is=true;
                else
                    is=false;
                end
            end
            uf=cellfun(@(fld)(undef_field(obj,fld)),obj.lattice_parameters_);
            undef_fields = obj.lattice_parameters_(uf);
        end
    end
    %---------------------------------------------------------------------
    %---------------------------------------------------------------------
    methods(Static)
        function fields = lattice_fields()
            % fields which belong to lattice
            fields = oriented_lattice.lattice_parameters_;
        end
        function fields = fields_with_defaults()
            % lattice fields which have default values
            fields =oriented_lattice.fields_have_defaults_;
        end
        function val=check_angular_set(val)
            % function checks if single angular value one tries to set is correct
            %
            if ~isnumeric(val)
                error('ORIENTED_LATTICE:set_angular_value','angular value has to be numeric but it is not');
            end
            if numel(val)>1
                error('ORIENTED_LATTICE:set_angular_value','angular value has to have a single value but it is array of %d elements',numel(val));
            end
            if abs(val)>360
                error('ORIENTED_LATTICE:set_angular_value','angular value should be in the range of +-360 deg but it equal to: %f',val);
            end
        end
        function angle = transform_and_get_angular(unit,value)
            % method checks if transformation into radians is defined and
            % returns either value in degrees (as provided) or transformed
            % into radians
            if strcmp(unit,'deg')
                angle = value;
            else
                angle =value*oriented_lattice.deg_to_rad_;
            end
        end
        function val =  check_3DAngles_correct(val)
            % check correct angular values for lattice angles
            %
            if isempty(val)
                val = [];
                return;
            end
            if numel(val)==1
                val = [val,val,val];
            end
            %
            if numel(val) ~= 3
                error('ORIENTED_LATTICE:set_lattice_angles',' lattice angles have to be either 3-element vector, or a single value')
            end
            if ~all(isnumeric(val))
                error('ORIENTED_LATTICE:set_lattice_angles',' attempt to set non-numeric lattice angles')
            end
            %
            if size(val,2)==1
                val = val';
            end
            if max(val) >= 180 || min(val)<=0
                error('ORIENTED_LATTICE:set_lattice_angles',...
                    ' lattice angle has to be angles in degree in the range 0-180 deg but tried: [%f,%f,%f]',...
                    val(1),val(2),val(3))
            end
            
            % check correct angular values for lattice
            if (val(1)>=(val(2)+val(3)))||...
                    (val(2)>=(val(3)+val(1)))||...
                    (val(3)>=(val(1)+val(2)))
                
                error('ORIENTED_LATTICE:set_lattice_angles','lattice angles do not define correct 3D lattice');
            end
        end
        %-----------------------------------------------------------------
        function vector = check_3Dvector(val)
            % function verifies if 3D vector is correct and transforms single value (if
            % provider) into 3D vector;
            if isempty(val)
                vector = [];
                return;
            end
            vector = val;
            if numel(val)==1
                vector = [val,val,val];
            end
            if numel(vector) ~= 3
                error('ORIENTED_LATTICE:set_lattice_param',' lattice parameters have to be either 3-element vector, or single value')
            end
            if ~all(isnumeric(vector))
                error('ORIENTED_LATTICE:set_lattice_param',' attempt to set non-numeric  lattice parameter')
            end
            if size(vector,2)==1
                vector = vector';
            end
        end
    end
end

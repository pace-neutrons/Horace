classdef oriented_lattice
    % class describes main properties of a sample with oriented lattice
    % under neutron scattering or x-ray investigation.
    % and contains various service functions to work with such sample
    %
    % Usage:
    %>>lat = oriented_lattice() -- build oriented lattice with default
    %                             parameters. Some parameters of such
    %                             lattice can be considered undefined and
    %                             some -- have default values
    % or:
    %>>lat = oriented_lattice(alatt)                --!
    %>>lat = oriented_lattice(alatt,angdeg)           !
    %>>lat = oriented_lattice(alatt,angdeg,psi)       !- build lattice using
    %>>lat = oriented_lattice(alatt,angdeg,psi,u)     ! default positional
    %>>lat = oriented_lattice(alatt,angdeg,psi,u,v)   ! parameters
    %>>lat = oriented_lattice(....,key,value)       --!
    % or:
    % Constructor which defines all lattice parameters in the positions,
    % specified as below:
    %>>lat = oriented_lattice(alatt,angdeg,psi,u,v,omega,dpsi,gl,gs)
    % or:
    %>>lat = oriented_lattice(struct) -- build oriented lattice from
    %                  structure with field names, corresponding to names
    %                  of oriented_lattice structure
    %
    %
    % where:
    %   alatt           Lattice parameters (Ang^-1)        [row or column vector]
    %   angdeg          Lattice angles (deg)               [row or column vector]
    %   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
    %   u               First vector (1x3) defining scattering plane (r.l.u.)
    %   v               Second vector (1x3) defining scattering plane (r.l.u.)
    %
    %   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
    %   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
    %   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
    %   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
    
    %
    % All angular units set in degrees but can be retrieved in degrees
    % or radians.
    %
    % $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
    %
    %
    % On 2017/03 it is far from completion and have many of its methods
    % duplicated elsewhere.
    %
    properties(Dependent)
        % Lattice parameters [a,b,c] (Ang^-1)
        alatt
        % Lattice angles [alf,bet,gam] (deg)
        angdeg
        
        % Crystal orientation wrt the beam direction
        % u -- vector along beam direction
        u
        % v -- together with u vector defines the rotation plane,
        v
        % Goniometer parameters
        %  Angle of u w.r.t. ki (deg)  [Default=nan]
        psi   = nan;
        %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        omega = 0;
        %  Correction to psi (deg)  [Default=0]
        dpsi  = 0;
        %  Large goniometer arc angle (deg)  [Default=0]
        gl    = 0;
        %  Small goniometer arc angle (deg)  [Default=0]
        gs    = 0;
        % what units (deg or rad) used for all angular units. (All angular
        % units have to be set in degrees, but can be retrieved as radians)
        angular_units;
    end
    
    
    properties(Access=private)
        %
        alatt_  = [1,1,1];
        angdeg_ = [90,90,90];
        
        % the defaults for these fields are:
        u_   = [1,0,0];
        v_   = [0,1,0];
        % Goniometer parameters
        psi_   = 0;         %  Angle of u w.r.t. ki (deg)  [Default=0]
        omega_ = 0;         %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi_  = 0;         %  Correction to psi (deg)  [Default=0]
        gl_    = 0;         %  Large goniometer arc angle (deg)  [Default=0]
        gs_    = 0;         %  Small goniometer arc angle (deg)  [Default=0]
        
        % by default, units used in the class are degree.
        angular_units_= true %'deg';
        
        % service variable used to help checking u and v
        uv_cros_=[0,0,1]; % cross(u,v);
        surf_ar_ = 1;  % abs(uv_cros_.*uv_cros_);
        % the boolean used to check if field has been set up (defined). The
        % field names correspond to  fields_to_define_
        undef_fields_ = true(3,1);
    end
    properties(Constant,Access=private)
        % fields to set up for loader considered to be defined
        fields_to_define_ = {'alatt','angdeg','psi'};
        % List of fields which have default values and do not have to be always defined by either file or command arguments;
        fields_have_defaults_ = {'omega','dpsi','gl','gs','u','v'};
        % List of all fields to describe lattice. Provided in order a
        % lattice constructor with parameters
        lattice_parameters_ = {'alatt','angdeg','psi','u','v','omega','dpsi','gl','gs'}
        % radian to degree transformation constant
        deg_to_rad_=pi/180;
        % the minimal norm for two vectors considered to be parallell or 0
        tol_  = 1.e-9
    end
    %
    methods
        % constructor
        function self = oriented_lattice(varargin)
            if nargin>0
                self = build_oriented_lattice_(oriented_lattice,varargin{:});
            end
        end
        %------------------------------------------------------------------
        % interface to file-based properties
        %
        % calcualate b-matrix
        [b, arlu, angrlu] = bmatrix(obj)
        % calculate u and ub matrix
        [ub,umat] = ubmatrix (obj,varargin)
        % Calculate matrix that convert momentum from coordinates in spectrometer frame
        % to crystal Cartesian system
        [spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix (obj)
        % convert class into structure, containing public-accessible information
        public_struct = struct(obj,varargin)
        %------------------------------------------------------------------
        function units = get.angular_units(this)
            if this.angular_units_
                units = 'deg';
            else
                units = 'rad';
            end
        end
        %
        function this = set.angular_units(this,val)
            if val(1) == 'd'
                this.angular_units_ = true;
            elseif val(1) == 'r'
                this.angular_units_ = false;
            else
                error('ORIENTED_LATTICE:invalid_argument',...
                    'Angular units can be set to ''degree''(d) or ''radian''(r)')
            end
        end
        %
        function this = set_deg(this)
            this.angular_units_=true;
        end
        %
        function this = set_rad(this)
            this.angular_units_= false;
        end
        %------------------------------------------------------------------
        function is=is_defined(this,field_name)
            % check if field, which should be defined as do not have
            % meaningful defaults is actually defined.
            % input:
            % field_name :: the name of the field to check
            mem = ismember(oriented_lattice.fields_to_define_,field_name);
            if any(mem)
                is = ~this.undef_fields_(mem);
            else
                is = true;
            end
        end
        
        %-----------------------------------------------------------------
        function psi = get.psi(this)
            psi = transform_and_get_angular_(this,this.psi_);
        end
        function omega = get.omega(this)
            omega=transform_and_get_angular_(this,this.omega_);
        end
        function dpsi = get.dpsi(this)
            dpsi=transform_and_get_angular_(this,this.dpsi_);
        end
        function gl=get.gl(this)
            gl=transform_and_get_angular_(this,this.gl_);
        end
        function gs=get.gs(this)
            gs=transform_and_get_angular_(this,this.gs_);
        end
        %
        function this = set.psi(this,val)
            this.psi_=check_angular_set_(val);
            % psi is third in the list of fields to be defined
            if isnan(this.psi_)
                this.undef_fields_(3) = true;
            else
                this.undef_fields_(3) = false;
            end
        end
        %
        function this = set.omega(this,val)
            this.omega_=check_angular_set_(val);
        end
        function this  = set.dpsi(this,val)
            this.dpsi_=check_angular_set_(val);
        end
        function this =set.gl(this,val)
            this.gl_=check_angular_set_(val);
        end
        function this =set.gs(this,val)
            this.gs_=check_angular_set_(val);
        end
        %-----------------------------------------------------------------
        function u=get.u(this)
            if this.surf_ar_<this.tol_
                u=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u_,this.v_);
            else
                u=this.u_;
            end
        end
        %
        function v=get.v(this)
            if this.surf_ar_<this.tol_
                v=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u_,this.v_);
            else
                v=this.v_;
            end
        end
        %
        function this=set.u(this,u)
            this.u_=check_3Dvector_correct_(this,u);
            %
            this.uv_cros_=cross(this.u_,this.v_);
            this.surf_ar_ = sum(this.uv_cros_.*this.uv_cros_);
        end
        function this=set.v(this,v)
            this.v_=check_3Dvector_correct_(this,v);
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
            angdeg= this.angdeg_;
        end
        %
        function this=set.alatt(this,val)
            this.alatt_ = check_3Dvector_correct_(this,val);
            % alatt is first in the list of fields to be defined
            this.undef_fields_(1) = false;
        end
        function this=set.angdeg(this,val)
            this.angdeg_ =check_3DAngles_correct_(val);
            % angdeg is second in the list of fields to be defined
            this.undef_fields_(2) = false;
        end
        %---
        function undef_fields=get_undef_fields(obj)
            % return list of lattice fiels which requested to be explicitly defined
            % but in fact have been not
            undef_fields = obj.fields_to_define_(obj.undef_fields_);
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
    end
end

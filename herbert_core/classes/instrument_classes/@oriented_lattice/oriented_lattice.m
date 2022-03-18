classdef oriented_lattice < serializable
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
    %>>lat = oriented_lattice(alatt,angdeg,psi,u,v,omega,dpsi,gl,gs,['deg'|'rad'])
    %
    %        where optional 'deg'|'rad' key specifies degree or radian
    %        units used for angular parameters. Default is 'degree'
    % or:
    %>>lat = oriented_lattice(struct) -- build oriented lattice from
    %                  structure with field names, corresponding to names
    %                  of oriented_lattice structure
    %
    %
    % where:
    %   alatt           [1x3] vector of Lattice parameters (Ang^-1)
    %   angdeg          [1x3] vector of Lattice angles (deg)
    %   psi             Angle of u w.r.t. ki (deg) - The rotation angle
    %                   between the beam direction and the selected
    %                   orientation of the crystal defined by vector u
    %   u               First vector (1x3) defining scattering plane (r.l.u.)
    %   v               Second vector (1x3) defining scattering plane (r.l.u.)
    %
    %   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
    %   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
    %   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
    %   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
    %
    %  angular_units    deg|rad -- the angular units values are expressed
    %                   in degrees or radians
    %
    % All  angular values are set in degrees or radians depending on angular_units
    % property values. They are retrieved in units of degrees or radians
    % depending on the angular_units property value
    %
    %
    properties(Dependent)
        alatt    % Lattice parameters [a,b,c] (Ang^-1)
        angdeg   % Lattice angles [alf,bet,gam] (deg)

        % Crystal orientation wrt the beam direction
        u % vector along beam direction when psi = 0

        v % together with u vector defines the rotation plane,

        % Goniometer parameters
        psi;    %  Angle between u w.r.t. ki (deg)  [Default=nan]
        omega;  %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi;   %  Correction to psi (deg)  [Default=0]
        gl;     %  Large goniometer arc angle (deg)  [Default=0]
        gs;     %  Small goniometer arc angle (deg)  [Default=0]

        % what units (deg or rad) used for all angular units. (All angular
        % units have to be set in degrees, but can be retrieved as radians)
        angular_units;
    end
    properties(Dependent,Hidden)
        angular_is_degree;
        undef_fields;
    end


    properties(Access=private)
        %
        alatt_  = [2*pi,2*pi,2*pi];
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
        angular_is_degree_= true %'deg';

        % the boolean used to check if field has been set up (defined). The
        % field names and number defined by fields_to_define_ private
        % property
        undef_fields_ = true(3,1);
        isvalid_ = false; % the variable which indicates if the object is valid or
        % not. Used in checks for interdependent properties validity
        % (e.g. u is not parallel to v)
    end
    properties(Constant,Access=private)
        % fields to set up for loader considered to be defined
        fields_to_define_ = {'alatt','angdeg','psi'};
        % List of fields which have default values and do not have to be always defined by either file or command arguments;
        fields_have_defaults_ = {'omega','dpsi','gl','gs','u','v'};
        % List of all fields to describe lattice. Provided in order a
        % lattice constructor with positional parameters uses them
        % The order is used in providing meanings to the positional parameters
        % of the constructor. The same parameters, except the last one are
        % the input parameters for serializable indepFiels
        lattice_parameters_ = {'alatt','angdeg','psi','u','v',...
            'omega','dpsi','gl','gs','angular_units'}
        % radian to degree transformation constant
        deg_to_rad_=pi/180;
        % the minimal norm for two vectors considered to be parallell or 0
        tol_  = 1.e-9
    end
    %
    methods
        % constructor
        function self = oriented_lattice(varargin)
            if nargin == 0
                return;
            end
            self = self.init(varargin{:});
        end
        %------------------------------------------------------------------
        % interface to file-based properties
        %
        % calcualate b-matrix
        [b, arlu, angrlu] = bmatrix(obj)
        % calculate u and ub matrix
        [ub,umat] = ubmatrix(obj,varargin)
        % Calculate matrix used to convert momentum from coordinates in
        % spectrometer frame to crystal Cartesian system.
        [spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix (obj)
        %------------------------------------------------------------------
        function obj = init(obj,varargin)
            if nargin == 1
                return;
            end
            [obj,rem] = build_oriented_lattice_(obj,varargin{:});
            if ~isempty(rem)
                error('HERBERT:oriented_lattice:invalud_argument',...
                    'Unrecognized oriented_lattice parameters: %s',...
                    evalc('disp(rem)'));
            end
        end
        %
        function units = get.angular_units(obj)
            if obj.angular_is_degree_
                units = 'deg';
            else
                units = 'rad';
            end
        end
        function obj = set.angular_units(obj,val)
            old_val = obj.angular_is_degree_;
            if val(1) == 'd'
                obj.angular_is_degree_ = true;
            elseif val(1) == 'r'
                obj.angular_is_degree_ = false;
            else
                error('HERBERT:oriented_lattice:invalid_argument',...
                    'Angular units can be set to ''degree''(d) or ''radian''(r)')
            end
            obj = recalculate_angular_units_values_(obj,old_val);
        end
        %
        function obj = set_deg(obj)
            old_val = obj.angular_is_degree_;
            obj.angular_is_degree_=true;
            obj = recalculate_angular_units_values_(obj,old_val);
        end
        %
        function obj = set_rad(obj)
            old_val = obj.angular_is_degree_;
            obj.angular_is_degree_=false;
            obj = recalculate_angular_units_values_(obj,old_val);
        end
        function is = get.angular_is_degree(obj)
            is = obj.angular_is_degree_;
        end
        function obj = set.angular_is_degree(obj,val)
            obj.angular_is_degree_ = logical(val);
        end
        %------------------------------------------------------------------
        function is=is_defined(obj,field_name)
            % check if field, which should be defined as do not have
            % meaningful defaults is actually defined.
            % input:
            % field_name :: the name of the field to check
            mem = ismember(oriented_lattice.fields_to_define_,field_name);
            if any(mem)
                is = ~obj.undef_fields_(mem);
            else
                is = true;
            end
        end
        %
        function udf = get.undef_fields(obj)
            udf  = obj.fields_to_define_(obj.undef_fields_);
        end
        %-----------------------------------------------------------------
        function psi = get.psi(obj)
            psi = obj.psi_;
        end
        function omega = get.omega(obj)
            omega=obj.omega_;
        end
        function dpsi = get.dpsi(obj)
            dpsi=obj.dpsi_;
        end
        function gl=get.gl(obj)
            gl=obj.gl_;
        end
        function gs=get.gs(obj)
            gs=obj.gs_;
        end
        %
        function obj = set.psi(obj,val)
            obj.psi_=check_angular_set_(obj,val);
            % psi is third in the list of fields to be defined
            if isnan(obj.psi_)
                obj.undef_fields_(3) = true;
            else
                obj.undef_fields_(3) = false;
            end
            [~,~,obj] = check_combo_arg(obj);                        
        end
        %
        function obj = set.omega(obj,val)
            obj.omega_=check_angular_set_(obj,val);
        end
        function obj  = set.dpsi(obj,val)
            obj.dpsi_=check_angular_set_(obj,val);
        end
        function obj =set.gl(obj,val)
            obj.gl_=check_angular_set_(obj,val);
        end
        function obj =set.gs(obj,val)
            obj.gs_=check_angular_set_(obj,val);
        end
        %-----------------------------------------------------------------
        function u=get.u(obj)
            u = obj.u_;
        end
        function obj=set.u(obj,u)            
            obj = check_and_set_uv_(obj,'u',u);
        end
        %
        function v=get.v(obj)
            v = obj.v_;
        end
        function obj=set.v(obj,v)
            obj = check_and_set_uv_(obj,'v',v);
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function alat=get.alatt(obj)
            alat = obj.alatt_;
        end
        function angdeg=get.angdeg(obj)
            angdeg= obj.angdeg_;
        end
        %
        function obj=set.alatt(obj,val)
            obj.alatt_ = check_3Dvector_correct_(obj,val);
            % alatt is first in the list of fields to be defined
            obj.undef_fields_(1) = false;
            [~,~,obj] = check_combo_arg(obj);            
        end
        function obj=set.angdeg(obj,val)
            obj.angdeg_ =check_3DAngles_correct_(obj,val);
            % angdeg is second in the list of fields to be defined
            obj.undef_fields_(2) = false;
            [~,~,obj] = check_combo_arg(obj);                        
        end

        %------------------------------------------------------------------
        % SERIALIABLE INTERFACE:
        %------------------------------------------------------------------
        function   ver  = classVersion(~)
            ver = 1;
        end
        function flds = indepFields(obj)
            call_stack = dbstack;
            for_saving = strncmp(call_stack(2).name,'to',2);
            flds = oriented_lattice.lattice_parameters_;
            if for_saving % do not save undefined fields
                udf = obj.undef_fields;
                is_udf = ismember(flds,udf);
                if any(is_udf)
                    flds = flds(~is_udf);
                end
            end
            % place angular units properties first to set up contest
            % for saveable properties
            flds = ['angular_is_degree',flds(1:end-1)];

        end
        function [ok,mess,obj] = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained lattice object
            [ok,mess,obj] = check_combo_arg_(obj);
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
        %------------------------------------------------------------------
        function obj = loadobj(input)
            obj = oriented_lattice();
            obj = loadobj@serializable(input,obj);
        end
    end
    methods(Access = protected)
        function is = check_validity(obj)
            % return the validity of the oriented lattice object,
            % calculated during interface settings
            is = obj.isvalid_;
        end

    end
end

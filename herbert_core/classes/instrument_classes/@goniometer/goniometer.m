classdef goniometer < serializable
    % class describes main properties of a goniometer used to orient
    % sample in a spectrometer for neutron scattering or x-ray investigation.
    % and contains various service functions to work with such goniometer
    %
    % Usage:
    %>>lat = oriented_lattice() -- build oriented lattice with default
    %                             parameters. Some parameters of such
    %                             lattice can be considered undefined and
    %                             some -- have default values
    % or:
    %>>lat = oriented_lattice(psi)       !- build goniometer using
    %>>lat = oriented_lattice(psi,u)     ! default positional
    %>>lat = oriented_lattice(psi,u,v)   ! parameters
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


    properties(Access=protected)
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
        psi_defined_      = false;

        % radian to degree transformation constant
        deg_to_rad_=pi/180;
        % the minimal norm for two vectors considered to be parallell or 0
        tol_  = 1.e-9
    end
    %
    methods
        % constructor
        function self = goniometer(varargin)
            if nargin == 0
                return;
            end
            self = self.init(varargin{:});
        end
        function [obj,rem] = init(obj,varargin)
            if nargin == 1
                return;
            end
            [obj,rem] = init_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        function uf = get.undef_fields(obj)
            uf = get_undef_fields(obj);
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
            % the hidden method to change the meaning
            % of the angular units. Should be used only as a part of the
            % serializable interface, as does not do any checks and does
            % not modify actual values.
            % To change the class behaviour, use public property
            % "angular_units" = ['deg'|'rad'] or method set_deg/set_rad;
            obj.angular_is_degree_ = logical(val);
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
                obj.psi_defined_ = false;
            else
                obj.psi_defined_ = true;
            end
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
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
        %-----------------------------------------------------------------
        function is=is_defined(obj,field_name)
            % check if field, which should be defined as do not have
            % meaningful defaults is actually defined.
            % input:
            % field_name :: the name of the field to check
            is = ismember(field_name,obj.get_fields_to_define());
        end

    end
    methods(Access=protected)
        function uf = get_undef_fields(obj)
            % get list of undefined fields
            if obj.psi_defined_
                uf = {};
            else
                uf = {'psi'};
            end
        end
        function [is,val,argi] = check_angular_units_present(obj,varargin)
            % analyze input parameters in all reasonable forms and extract
            % angular units value from them if it is present.
            % Necessary for construction, as it has to be set first not to
            % change parameter values when it set
            [is,val,argi] = check_angular_units_present_(obj,varargin{:});
        end
        function flds = get_fields_to_define(~)
            flds = {'psi'};
        end

    end
    %----------------------------------------------------------------------
    % SERIALIABLE INTERFACE:
    %----------------------------------------------------------------------
    methods
        function   ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = {'psi','u','v',...
                'omega','dpsi','gl','gs','angular_units'};
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained lattice object
            obj = check_combo_arg_(obj);
        end
        function obj = from_bare_struct (obj, S)
            % 
            [is,val,S] = obj.check_angular_units_present(S);
            if is
                obj.angular_units = val;
            end
            obj = from_bare_struct@serializable(obj,S);
        end
    end
    %---------------------------------------------------------------------
    methods(Static)
        function obj = loadobj(input)
            obj = goniometer();
            obj = loadobj@serializable(input,obj);
        end
    end
end
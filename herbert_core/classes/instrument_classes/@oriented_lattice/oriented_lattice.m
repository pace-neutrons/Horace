classdef oriented_lattice < goniometer
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

        % fully defined oriented lattice need at least alatt, angdeg and
        % psi to be defined. When data loaded from nxspe, alatt, angdeg,
        % and may be psi can remain undefined and need to be defined
        % later. In this case, lattice is invalid
        isvalid
        reason_for_invalid;
    end
    properties(Constant,Hidden)
        % fields defined in lattice
        lattice_fields = [goniometer.gon_fields_(:);oriented_lattice.lat_fields_(:)];
    end

    properties(Access=private)
        %
        alatt_  = [2*pi,2*pi,2*pi];
        angdeg_ = [90,90,90];


        % the boolean used to check if field has been set up (defined). The
        % field names and number defined by fields_to_define_ private
        % property
        undef_fields_ = true(2,1);
        isvalid_ = false; % empty lattice is invalid
        reason_for_invalid_ = 'empty lattice is invalid';
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
            [obj,rem] = init@goniometer(obj,varargin{:});
            if ~isempty(rem)
                error('HERBERT:oriented_lattice:invalud_argument',...
                    'Unrecognized oriented_lattice parameters: %s',...
                    disp2str(rem));
            end
        end
        %
        %
        %------------------------------------------------------------------
        %
        %-----------------------------------------------------------------
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
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        function obj=set.angdeg(obj,val)
            obj.angdeg_ =check_3DAngles_correct_(obj,val);
            % angdeg is second in the list of fields to be defined
            obj.undef_fields_(2) = false;
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
    end
    methods(Access=protected)
        function uf = get_undef_fields(obj)
            % get list of undefined fields
            fld_l = {'alatt','angdeg'};
            uf_ = fld_l(obj.undef_fields_);
            fld_b = get_undef_fields@goniometer(obj);
            uf  = [uf_(:);fld_b(:)];
        end
        function flds = get_fields_to_define(~)
            flds =  oriented_lattice.fields_to_define_;
        end
    end
    properties(Constant,Access=private)
        lat_fields_ = {'alatt','angdeg'}
        % fields to set up for loader considered to be defined
        fields_to_define_ = {'alatt','angdeg','psi'};
        % List of all fields to describe lattice. Provided in order a
    end
    %======================================================================
    % SERIALIABLE INTERFACE:
    %----------------------------------------------------------------------
    methods
        function   ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(obj)
            fld_l = {'alatt';'angdeg'};
            fld_b = saveableFields@goniometer(obj);
            flds = [fld_l(:);fld_b(:)];
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained lattice object
            try
                obj = check_combo_arg@goniometer(obj);
            catch ME
                obj.isvalid_ = false;
                obj.reason_for_invalid_ = ME.message;
                return;
            end
            obj = check_combo_arg_(obj);
        end
        function is = get.isvalid(obj)
            is = obj.isvalid_;
        end
        function is =  get.reason_for_invalid(obj)
            is = obj.reason_for_invalid_;
        end

    end
    %---------------------------------------------------------------------
    methods(Static)
        function obj = loadobj(input)
            obj = oriented_lattice();
            obj = loadobj@serializable(input,obj);
        end
    end
end

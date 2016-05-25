classdef oriented_lattice
    % class describes main properties of a sample with oriented lattice
    % under neutron scattering or x-ray investigation.
    %
    % and contains various service functions to work with such sample
    %
    %
    % $Revision: 348 $ ($Date: 2014-03-05 20:30:22 +0000 (Wed, 05 Mar 2014) $)
    %
    %
    % On 2014/03 it is far from completeon and have many of its methods are
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
        alatt__  = [];
        angdeg__ = [];
        
        % the defaults for these fields are:
        u__    = [1,0,0];
        v__   = [0,1,0];
        % Goniometer parameters
        psi__   = [];         %  Angle of u w.r.t. ki (deg)  [Default=0]
        omega__ = 0;         %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi__  = 0;         %  Correction to psi (deg)  [Default=0]
        gl__    = 0;         %  Large goniometer arc angle (deg)  [Default=0]
        gs__    = 0;         %  Small goniometer arc angle (deg)  [Default=0]
        
        % by default, units used in the class are degree.
        angular_units__= 'deg';
        
        
        % service variable used to help viewing u,v
        uv_cros__=[0,0,1]; % cross(u,v);
        surf_ar__ = 1;  % abs(uv_cros__.*uv_cros__);
    end
    properties(Constant,Access=private)
        % List of fields which have default values and do not have to be always defined by either file or command arguments;
        fields_have_defaults__ = {'omega','dpsi','gl','gs','u','v'};
        % List of the fields which describe lattice.
        lattice_parameters__ = {'alatt','angdeg','psi','omega','dpsi','gl','gs','u','v'}
        % radian to degree transformation constant
        deg_to_rad__=pi/180;
        
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
            units = this.angular_units__;
        end
        function this = set.angular_units(this,val)
            if val(1) == 'd'
                this.angular_units__ = 'deg';
            elseif val(1) == 'r'
                this.angular_units__ = 'rad';
            else
            end
        end        
        function this = set_deg(this)
            this.angular_units__= 'deg';
        end
        function this = set_rad(this)
            this.angular_units__= 'rad';
        end
%        
        function public_struct = struct(this)
            % convert class into structure, containing public-accessible information
            pub_fields = [oriented_lattice.lattice_parameters__,{'angular_units'}];
            public_struct  = struct();
            for i=1:numel(pub_fields)
                public_struct.(pub_fields{i}) = this.(pub_fields{i});
            end
            
        end
        
        %-----------------------------------------------------------------
        function psi = get.psi(this)
            psi = oriented_lattice.transform_and_get_angular(this.angular_units__,this.psi__);
        end
        function omega = get.omega(this)
            omega=oriented_lattice.transform_and_get_angular(this.angular_units__,this.omega__);
        end
        function dpsi = get.dpsi(this)
            dpsi=oriented_lattice.transform_and_get_angular(this.angular_units__,this.dpsi__);
        end
        function gl=get.gl(this)
            gl=oriented_lattice.transform_and_get_angular(this.angular_units__,this.gl__);
        end
        function gs=get.gs(this)
            gs=oriented_lattice.transform_and_get_angular(this.angular_units__,this.gs__);
        end
        function this = set.psi(this,val)
            this.psi__=oriented_lattice.check_angular_set(val);
        end
        function this = set.omega(this,val)
            this.omega__=oriented_lattice.check_angular_set(val);
        end
        function this  = set.dpsi(this,val)
            this.dpsi__=oriented_lattice.check_angular_set(val);
        end
        function this =set.gl(this,val)
            this.gl__=oriented_lattice.check_angular_set(val);
        end
        function this =set.gs(this,val)
            this.gs__=oriented_lattice.check_angular_set(val);
        end
        %-----------------------------------------------------------------
        function u=get.u(this)
            if this.surf_ar__<1.e-6
                u=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u__,this.v__);
            else
                u=this.u__;
            end
        end
        function v=get.v(this)
            if this.surf_ar__<1.e-6
                v=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u__,this.v__);
            else
                v=this.v__;
            end
        end
        function this=set.u(this,u)
            this.u__=oriented_lattice.check_3Dvector(u);
            %
            this.uv_cros__=cross(this.u__,this.v__);
            this.surf_ar__ = sum(this.uv_cros__.*this.uv_cros__);
        end
        function this=set.v(this,v)
            this.v__=oriented_lattice.check_3Dvector(v);
            %
            this.uv_cros__=cross(this.u__,this.v__);
            this.surf_ar__ = sum(this.uv_cros__.*this.uv_cros__);
        end
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function alat=get.alatt(this)
            alat = this.alatt__;
        end
        function angdeg=get.angdeg(this)
            %angdeg= oriented_lattice.transform_and_get_angular(this.angular_units__,this.angdeg__);
            angdeg= this.angdeg__;
        end
        %
        function this=set.alatt(this,val)
            this.alatt__ = oriented_lattice.check_3Dvector(val);
        end
        function this=set.angdeg(this,val)
            this.angdeg__ = oriented_lattice.check_3DAngles_correct(val);
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
            uf=cellfun(@(fld)(undef_field(obj,fld)),obj.lattice_parameters__);
            undef_fields = obj.lattice_parameters__(uf);            
        end
    end
    %---------------------------------------------------------------------
    %---------------------------------------------------------------------
    methods(Static)
        function fields = lattice_fields()
            % fields which belong to lattice
            fields = oriented_lattice.lattice_parameters__;
        end        
        function fields = fields_with_defaults()
            % lattice fields which have default values
            fields =oriented_lattice.fields_have_defaults__;
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
                angle =value*oriented_lattice.deg_to_rad__;
            end
        end
        function val =  check_3DAngles_correct(val)
            % check correct angular values for lattice angles
            %
            if isempty(val);    return;
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
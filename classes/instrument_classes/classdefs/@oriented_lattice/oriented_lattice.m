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
    % On 2014/03 it is far from completeon and have many of its methods
    % dublicated elsewhere. 
    %
    properties(Dependent)
        %
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
        % Crystal parameters:
        is_crystal  ;    % true if any of parameters describing single are defined, false if no so a powder assumed        
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
        fields_have_defaults = {'omega','dpsi','gl','gs','u','v'};
        % List of the fields which describe lattice.
        lattice_parameters = {'alatt','angdeg','psi','omega','dpsi','gl','gs','u','v'}
        % radian to degree transformation constant
        deg_to_rad__=pi/180;
        
    end
    %
    methods(Static)
        function fields = fields_with_defaults()
            fields =oriented_lattice.fields_have_defaults;
        end
    end    
    methods
        % constructor
        function self = oriented_lattice()
        end
        %------------------------------------------------------------------
        % PROPERTIES WITH DEFAULTS
        %------------------------------------------------------------------
        function psi = get.psi(this)
            if strcmp(this.angular_units__,'deg')
                psi = this.psi__;
            else
                psi = this.psi__*rundata.deg_to_rad__;
            end
            
        end
        function omega = get.omega(this)
            if strcmp(this.angular_units__,'deg')
                omega  = this.omega__;
            else
                omega  = this.omega__*rundata.deg_to_rad__;
            end
        end
        function dpsi = get.dpsi(this)
            if strcmp(this.angular_units__,'deg')
                dpsi = this.dpsi__;
            else
                dpsi = this.dpsi__*rundata.deg_to_rad__;
            end
        end
        function gl=get.gl(this)
            if strcmp(this.angular_units__,'deg')
                gl= this.gl__;
            else
                gl= this.gl__*rundata.deg_to_rad__;
            end
        end
        function gs=get.gs(this)
            if strcmp(this.angular_units__,'deg')
                gs= this.gs__;
            else
                gs= this.gs__*rundata.deg_to_rad__;
            end
        end
        function this = set.psi(this,val)
            this.psi__=check_angular_set(val);
        end
        function this = set.omega(this,val)
            this.omega__=check_angular_set(val);
        end
        function this  = set.dpsi(this,val)
            this.dpsi__=check_angular_set(val);
        end
        function this =set.gl(this,val)
            this.gl__=check_angular_set(val);
        end
        function this =set.gs(this,val)
            this.gs__=check_angular_set(val);
        end
        %----------------------------
        function u=get.u(this)
            if this.surf_ar_stor<1.e-6
                u=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u__,this.v__);
            else
                u=this.u__;
            end
        end
        function v=get.v(this)
            if this.surf_ar_stor<1.e-6
                v=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u__,this.v__);
            else
                v=this.v__;
            end
        end
        function this=set.u(this,u)
            if numel(u) ~= 3
                error('RUNDATA:invalid_argument',' vector u has to be a vector of 3 elements')
            end
            if size(u,2)==1;
                u=u';
            end
            this.u__=u;
            this.uv_cros__=cross(u,this.v__);
            this.surf_ar__ = sum(this.uv_cros__.*this.uv_cros__);
        end
        function this=set.v(this,v)
            if numel(v) ~= 3
                error('RUNDATA:invalid_argument',' vector v has to be a vector of 3 elements')
            end
            if size(v,2)==1;
                v=v';
            end
            this.v__=v;
            this.uv_cros__=cross(this.u__,v);
            this.surf_ar__ = sum(this.uv_cros__.*this.uv_cros__);
        end
   
        %------------------------------------------------------------------
        % PROPERTIES WITH DEFAULTS -- END;
        %------------------------------------------------------------------
        %---
        function alat=get.alatt(this)
            alat = this.alatt__;
        end
        function angdeg=get.angdeg(this)
            angdeg= this.angldeg__;
        end
        %
        function this=set.alatt(this,val)
            this.alatt__ = check_3Dvector(val);
        end
        function this=set.angdeg(this,val)
            this.angldeg__ = check_3DAngles_correct(val);
        end
        %---
        
    end
end
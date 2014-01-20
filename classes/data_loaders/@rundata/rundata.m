classdef rundata
    % The class describes single processed run used in Horace and Mslice
    % It used as an interface to load processed run data from any file format
    % supported and to verify that all data necessary for the run
    % are available either from the file itself or from the parameters,
    % supplied with the file.
    %
    % If some parameters, which describe the run are missing from the
    % file format used, the user have to provide these parameters to the
    % constructor, or set them later (e.g. rundata.efix=10);
    %
    % The data availability is not verified by the class constructor
    % -- the class method % "get_rundata"
    % used to verify if data are availible and to actually load data from the
    % file.
    %
    % IF the data are not defined by the user, can not be found in the file and
    % do not have default, the method get_rundata will fail
    %
    %
    % $Revision$ ($Date$)
    %
    properties(Dependent)
        n_detectors = [];   % Number of detectors, used when dealing with masked detectors  -- will be derived
        % Detector parameters:
        det_par     = [];   % Horace structure of par-values, describing detectors angular positions   -- usually obtained from parFile or equivalent
        % Helper variables used to display data file name and redefine
        % loader
        data_file_name='';
        % par file name defined in loader
        par_file_name ='';
        %
        alatt     = [];     % Lattice parameters [a,b,c] (Ang^-1)   -- has to be in file or supplied  as  parameters list
        angldeg   = [];     % Lattice angles [alf,bet,gam] (deg)    -- has to be in file or supplied  as  parameters list
        
        % Experiment parameters;
        efix      = [];     % Fixed energy (meV)   -- has to be in file or supplied in parameters list
        emode     = 1;     % Energy transfer mode [Default=1 (direct geometry)]
        %
        S         = [];     % Array of signal [ne x ndet]   -- obtained from speFile or equivalent
        ERR       = [];     % Array of errors  [ne x ndet]  -- obtained from speFile or equivalent
        en        = [];     % Column vector of energy bin boundaries   -- obtained from speFile or equivalent
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
        is_crystal  = 1;    % true if single crystal (default), false if powder
        
        
        loader ='';         % visual representation of a loader
    end
    
    properties(Constant,Access=private)
        % List of fields which have default values and do not have to be always defined by either file or command arguments;
        fields_have_defaults = {'omega','dpsi','gl','gs','is_crystal','u','v'};        
    end
    properties(Access=private)
        % energy transfer mode
        emode_internal=[];
        %  incident energy or crystal analyzer energy
        efix_stor = [];
        %
        % list of the fields by default are defined in any loader
        loader_dependent_fields={'S','ERR','en','det_par','n_detectors'};
        % INTERNAL SERVICE PARAMETERS: (private read, private write in new Matlab versions)
        % The class which provides actual data loading:
        loader_stor = [];
        %
        alat_stor = [];
        angldeg_stor=[];
        % the defaults for these fields are:
        u_stor    = [1,0,0];
        v_stor    = [0,1,0];
        % Goniometer parameters
        psi_stor   = [];         %  Angle of u w.r.t. ki (deg)  [Default=0]
        omega_stor = 0;         %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi_stor  = 0;         %  Correction to psi (deg)  [Default=0]
        gl_stor    = 0;         %  Large goniometer arc angle (deg)  [Default=0]
        gs_stor    = 0;         %  Small goniometer arc angle (deg)  [Default=0]
        % default value for crystal (true) and stored value of this
        % property
        is_crystal_stor = 1;
        
        % service variable used to help veiwing u,v
        uv_cros_stor=[0,0,1]; % cross(u,v);
        surf_ar_stor = 1;  % abs(uv_cros_stor.*uv_cros_stor);
        
    end
    methods(Static)
        function fields = fields_with_defaults()
            fields =rundata.fields_have_defaults;
        end
    end
    
    methods
        function this=rundata(varargin)
            % rundata class constructor
            %
            %   >> run = rundata (nxspe_file_name);
            %   >> run = rundata (nxspe_file_name, keyword, value, keyword, value,...);
            %               nxspe_file_name -- the name of nxspe file with data
            %
            %   >> run = rundata (spe_file_name, par_file_name, keyword, value, keyword, value,...);
            %   >> run = rundata (spe_file_name, par_file_name, keyword, value, keyword, value,...);
            %               spe_file_name  -- Full file name of ASCII spe file
            %               par_file_name  -- Full file name of detector parameter file (Tobyfit format)
            %
            %   >> run = rundata(rundata, keyword, value, keyword, value,...)
            %               where the 'keyword', 'value' are the pairs of keywords from the list
            %               described below and corresponding values to which the fields are set
            %
            %   >> run = rundata(run_data, data_structure)
            %               where the data structure has fields with values, equivalend to the above
            %
            % The keywords (i.e. names of the fields) which can be present are:
            %
            % Experiment parameters;
            %   S           % Array of signals [ne x ndet]
            %   ERR         % Array of errors [ne x ndet]
            %   efix        % Input beam energy (meV)
            %   en          % Energy bin boundaries
            %   emode       % energy mode (1=direct geometry, 2=indirect geometry)
            %
            % Detectors parameters:
            %   n_detectors % Number of detectors, used when dealing with masked detectors
            %   det_par     % Array of par-values, describing detectors angular positions
            %
            % Crystal parameters:
            %   is_crystal  % true if single crystal, false if powder
            %   alatt       % Lattice parameters [a,b,c] (Ang^-1
            %   angldeg     % Lattice angles [alf,bet,gam] (deg)
            %
            % Crystal orientation:
            %   u           % first vector defining scattering plane
            %   v           % second vector defining scattering plane
            %
            % Goniometer parameters:
            %   psi         %  Angle of u w.r.t. ki (deg)
            %   omega       %  Angle of axis of small goniometer arc w.r.t. notional u (deg)
            %   dpsi        %  Correction to psi (deg)
            %   gl          %  Large goniometer arc angle (deg)
            %   gs          %  Small goniometer arc angle (deg)
            
            if nargin>0
                if isstring(varargin{1})
                    this=select_loader(this,varargin{1},varargin{2:end});
                else
                    this=set_param_recursively(this,varargin{1},varargin{2:end});
                end
            end
        end
        %------------------------------------------------------------------
        % PROPERTIES WITH DEFAULTS
        %------------------------------------------------------------------
        function psi = get.psi(this)
            psi = this.psi_stor;
        end
        function omega = get.omega(this)
            omega  = this.omega_stor;
        end
        function dpsi = get.dpsi(this)
            dpsi = this.dpsi_stor;
        end
        function gl=get.gl(this)
            gl= this.gl_stor;
        end
        function gs=get.gs(this)
            gs= this.gs_stor;
        end
        function this = set.psi(this,val)
            this.psi_stor=check_angular_set(val);
        end
        function this = set.omega(this,val)
            this.omega_stor=check_angular_set(val);
        end
        function this  = set.dpsi(this,val)
            this.dpsi_stor=check_angular_set(val);
        end
        function this =set.gl(this,val)
            this.gl_stor=check_angular_set(val);
        end
        function this =set.gs(this,val)
            this.gs_stor=check_angular_set(val);
        end
        %----------------------------
        function u=get.u(this)
            if this.surf_ar_stor<1.e-6
                u=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u_stor,this.v_stor);
            else
                u=this.u_stor;
            end
        end
        function v=get.v(this)
            if this.surf_ar_stor<1.e-6
                v=sprintf('u || v where u= [%d,%d,%d]; v= [%d,%d,%d]',this.u_stor,this.v_stor);
            else
                v=this.v_stor;
            end
        end
        function this=set.u(this,u)
            if numel(u) ~= 3
                error('RUNDATA:invalid_argument',' vector u has to be a vector of 3 elements')
            end
            if size(u,2)==1;
                u=u';
            end
            this.u_stor=u;
            this.uv_cros_stor=cross(u,this.v_stor);
            this.surf_ar_stor = sum(this.uv_cros_stor.*this.uv_cros_stor);
        end
        function this=set.v(this,v)
            if numel(v) ~= 3
                error('RUNDATA:invalid_argument',' vector v has to be a vector of 3 elements')
            end
            if size(v,2)==1;
                v=v';
            end
            this.v_stor=v;
            this.uv_cros_stor=cross(this.u_stor,v);
            this.surf_ar_stor = sum(this.uv_cros_stor.*this.uv_cros_stor);
        end
        %----
        function mode = get.emode(this)
            % method to check emode and verify its defaults
            if isempty(this.emode_internal)
                mode = 1;
            else
                mode = this.emode_internal;
            end
        end
        function this = set.emode(this,val)
            % method to check emode and verify its defaults
            if val>-1 && val <3
                this.emode_internal = val;
            else
                error('RUNDATA:set_emode','unsupported emode %d',val);
            end
        end
        %----
        function is = get.is_crystal(this)
            is = logical(this.is_crystal_stor);
        end
        function this = set.is_crystal(this,val)
            if val<0 || val > 1
                error('RUNDATA:set_is_crystal',' is crystal can be only 0 or 1 (true or false)');
            end
            this.is_crystal_stor = val;
        end
        %------------------------------------------------------------------
        % PROPERTIES WITH DEFAULTS -- END;
        %------------------------------------------------------------------
        %---
        function alat=get.alatt(this)
            alat = this.alat_stor;
        end
        function angdeg=get.angldeg(this)
            angdeg= this.angldeg_stor;
        end
        %
        function this=set.alatt(this,val)            
            this.alat_stor = check_3Dvector(val);
        end
        function this=set.angldeg(this,val)
            this.angldeg_stor = check_3DAngles_correct(val);
        end                
        %---
        function loader=get.loader(this)
            if isempty(this.loader_stor)
                loader=[];
            else
                loader=this.loader_stor;
            end
        end
        %------------------------------------------------------------------
        % A LOADER RELATED PROPERTIES
        %------------------------------------------------------------------
        function ndet = get.n_detectors(this)
            % method to check number of detectors defined in rundata
            ndet = get_loader_field(this,'n_detectors');
        end
        function S=get.S(this)
            S = get_loader_field(this,'S');
        end
        function this = set.S(this,val)
            this=set_loader_field(this,'S',val);
        end
        function ERR=get.ERR(this)
            ERR = get_loader_field(this,'ERR');
        end
        function this = set.ERR(this,val)
            this=set_loader_field(this,'ERR',val);
        end
        function det=get.det_par(this)
            det = get_loader_field(this,'det_par');
        end
        function this = set.det_par(this,val)
            this=set_loader_field(this,'det_par',val);
        end
        function en=get.en(this)
            en=get_loader_field(this,'en');
        end
        function this=set.en(this,val)
            this=set_loader_field(this,'en',val);
        end
        %--- LESS LOADER LOCATED BUT STILL DEFINED THERE and DEFINING
        %    LOADER
        function this = set.data_file_name(this,val)
            % method to change data file for a run data class
            this = rundata(this,'data_file_name',val);
        end
        function fname = get.data_file_name(this)
            % method to query what data file a rundata class uses
            fname = get_loader_field(this,'file_name');
        end
        %---
        function this = set.par_file_name(this,val)
            % method to change par file on defined loader
            data_fname = this.data_file_name;
            this = rundata(this,'data_file_name',data_fname,'par_file_name',val);
        end
        function fname = get.par_file_name(this)
            % method to query what par file a rundata class uses. May be empty
            % for some data loaders, which have det information inside.
            fname = get_loader_field(this,'par_file_name');
        end
        %------------------------------------------------------------------
        % A LOADER RELATED PROPERTIES -- END
        %------------------------------------------------------------------
        function efix = get.efix(this)
            efix = check_efix_defined_correctly(this);
        end
        function this = set.efix(this,val)
            if isempty(this.loader_stor)
                this.efix_stor=val;
            else
                if ismember('efix',loader_can_define(this.loader_stor))
                    this.loader_stor.efix = val;
                else
                    this.efix_stor = val;
                end
            end
        end
        %-----------------------------------------------------------------------------
        function this=saveNXSPE(this,filename)
            if isempty(this.loader)
                warning('RUNDATA:invalid_argument','nothing to save');
                return
            else
                ld=this.loader;
                this.loader_stor=ld.saveNXSPE(filename,this.efix,this.psi);
            end
            
        end
    end
end

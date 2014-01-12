classdef rundata
    % The class describes single processed run used in Horace and Mslice
    % It used as an interface to load processed run data from any file format
    % supported and to verify that all data necessary for the run
    % are availible either from the file itself or from the parameters,
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
    properties
        % Experiment parameters;
        S         = [];     % Array of signal [ne x ndet]   -- obtained from speFile or equivalent
        ERR       = [];     % Array of errors  [ne x ndet]  -- obtained from speFile or equivalent
        efix      = [];     % Fixed energy (meV)   -- has to be in file or supplied in parameters list
        en        = [];     % Column vector of energy bin boundaries   -- obtained from speFile or equivalent
        
        % Detector parameters:
        det_par     = [];   % Horace structure of par-values, describing detectors angular positions   -- usually obtained from parFile or equivalent
        
        % Crystal parameters:
        is_crystal  = [];   % true if single crystal (default), false if powder
        alatt     = [];     % Lattice parameters [a,b,c] (Ang^-1)   -- has to be in file or supplied  as  parameters list
        angldeg   = [];     % Lattice angles [alf,bet,gam] (deg)    -- has to be in file or supplied  as  parameters list
        
        % Crystal orientation
        u         = [];
        v         = [];
        
        % Goniometer parameters
        psi   = [];         %  Angle of u w.r.t. ki (deg)  [Default=0]
        omega = [];         %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        dpsi  = [];         %  Correction to psi (deg)  [Default=0]
        gl    = [];         %  Large goniometer arc angle (deg)  [Default=0]
        gs    = [];         %  Small goniometer arc angle (deg)  [Default=0]
        
        % INTERNAL SERVICE PARAMETERS: (private read, private write in new Matlab versions)
        % The class which provides actual data loading:
        loader = [];
        
        % List of fields which have default values and do not have to be always defined by either file or command arguments;
        fields_have_defaults = {'omega','dpsi','gl','gs','is_crystal','u','v'};
        
        % The default values for these fields are as follows:
        the_fields_defaults  = {0,0,0,0,true,[1,0,0],[0,1,0]};
    end
    properties(Dependent)
        n_detectors = [];   % Number of detectors, used when dealing with masked detectors  -- will be derived
        data_file_name;
        par_file_name;
        emode     = 1;     % Energy mode [Default=1 (direct geometry)]
    end
    properties(Access=private)
        emode_internal=[];
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
            % Set default type to crystal if it has not been defined by input parameters;
            if isempty(this.is_crystal)
                this.is_crystal=get_defaults(this,'is_crystal');
            end
        end
        %------------------------------------------------------------------
        function this = set.det_par(this,val)
            if ~isstruct(val)
                this.det_par = get_hor_format(val,'');
            else
                this.det_par = val;
            end
        end
        function this = set.data_file_name(this,val)
            % method to change data file for a run data class
            this = rundata(this,'data_file_name',val);
        end
        function fname = get.data_file_name(this)
            % method to query what data file a rundata class uses
            if isempty(this.loader)
                fname = [];
            else
                fname = this.loader.file_name;
            end
        end
        function this = set.par_file_name(this,val)
            % method to change par file on defined loader
            data_fname = this.data_file_name;
            this = rundata(this,'data_file_name',data_fname,'par_file_name',val);
        end
        function fname = get.par_file_name(this)
            % method to query what par file a rundata class uses. May be empty
            % for some data loaders, which have det information inside.
            if isempty(this.loader)
                fname = [];
            else
                fname = this.loader.par_file_name;
            end
        end
        function ndet = get.n_detectors(this)
            % method to check number of detectors defined in rundata
            if isempty(this.det_par)
                if isempty(this.loader)
                    ndet = [];
                else
                    ndet = this.loader.n_detectors;
                end
            else
                det = this.det_par;
                ndet = numel(det.phi);
            end
        end
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
        
        %-----------------------------------------------------------------------------
        function [rez,this]=subsref(this,S)
            % overloaded subsref loads data from the file if the data were
            % not already loaded
            rez=builtin('subsref',this,S);
            if S.type == '.'
                if any(ismember(S.subs,fieldnames(this)))
                    if isempty(rez)
                        this=get_rundata(this,S.subs,'-this');
                        rez=builtin('subsref',this,S);
                    end
                end
            end
        end
        
        function saveNXSPE(this,filename)
            if isempty(this.loader)
                ld=loader_nxspe();
            else
                ld=this.loader;
            end
            ld.S = this.S;
            ld.ERR=this.ERR;
            ld.en = this.en;
            ld.det_par = this.det_par;
            ls.saveNXSPE(filename,this.efix,this.psi);
        end
    end
end

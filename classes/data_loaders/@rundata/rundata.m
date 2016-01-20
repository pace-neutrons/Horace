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
    % used to verify if data are available and to actually load data from the
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
        %
        S         = [];     % Array of signal [ne x ndet]   -- obtained from speFile or equivalent
        ERR       = [];     % Array of errors  [ne x ndet]  -- obtained from speFile or equivalent
        en        = [];     % Column vector of energy bin boundaries   -- obtained from speFile or equivalent
        %
        % Detector parameters:
        det_par     = [];   % Horace structure of par-values, describing detectors angular positions   -- usually obtained from parFile or equivalent
        % Helper variables used to display data file name and redefine
        % loader
        data_file_name='';
        % par file name defined in loader
        par_file_name ='';
        
        % Experiment parameters;
        efix    ;     % Fixed energy (meV)   -- has to be in file or supplied in parameters list
        emode  ;     % Energy transfer mode [Default=1 (direct geometry)]
        
        % accessor to verify if the oriented lattice is present (and the
        % rundata describe crystal)
        is_crystal;
        % accessor to access the oriented lattice
        lattice;
        % visual representation of a loader
        loader ;
    end
    
    properties(Constant,Access=private)
        % list of the fields defined in any loader
        loader_dependent_fields__={'S','ERR','en','det_par','n_detectors'};
        % minimal set of fields, defining reasonable run
        min_field_set__ = {'efix','en','emode','n_detectors','S','ERR','det_par'};
    end
    properties(Access=private)
        % energy transfer mode
        emode__=1;
        %  incident energy or crystal analyser energy
        efix__ = [];
        %
        % INTERNAL SERVICE PARAMETERS: (private read, private write in new Matlab versions)
        % The class which provides actual data loading:
        loader__ = [];
        
        % oriented lattice which describes crytsal (present if run describes crystal)
        oriented_lattice__ =[];
        
    end
    methods(Static)
        function fields = main_data_fields()
            fields = rundata.min_field_set__;
        end
        function run = from_string(str)
            % build rundata object from its string representation obrained earlier by
            % serialize function
            run = rundata_from_string(str);
        end
        function [run,size] = deserialize(iarr)
            % build rundata object from its string representation obrained earlier by
            % serialize function
            % returns rudata object and the byte size of array used to store
            % this object (minus 8 bytes spent on storing the object size itself)
            [run,size] = deserialize_(iarr);
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
            
            if nargin>0
                if ischar(varargin{1})
                    this=select_loader(this,varargin{1},varargin{2:end});
                else
                    this=set_param_recursively(this,varargin{1},varargin{2:end});
                end
            end
        end
        
        function fields = fields_with_defaults(this)
            % method returns data fields, which have default values
            fields = {'emode'};
            if ~isempty(this.oriented_lattice__)
                lattice_fields = oriented_lattice.fields_with_defaults();
                fields ={fields{:},lattice_fields{:}};
            end
        end
        %         function val = subsref(this,S)
        %         end
        
        %----
        function mode = get.emode(this)
            % method to check emode and verify its default
            mode = this.emode__;
        end
        function this = set.emode(this,val)
            % method to check emode and verify its defaults
            if val>-1 && val <3
                this.emode__ = val;
            else
                error('RUNDATA:set_emode','unsupported emode %d, only 0 1 and 2 are supported',val);
            end
        end
        %----
        function is = get.is_crystal(this)
            if isempty(this.oriented_lattice__)
                is = false;
            else
                is = true;
            end
        end
        %
        function this = set.is_crystal(this,val)
            if val == 0
                this.oriented_lattice__ = [];
            elseif val == 1
                if isempty(this.oriented_lattice__)
                    this.oriented_lattice__ = oriented_lattice();
                end
            elseif isa(val,'oriented_lattice')
                this.oriented_lattice__ = val;
            else
                error('RUNDATA:set_is_crystal',' you can either remove crystal information or set oriented lattice to define crystal');
            end
        end
        %
        function lattice = get.lattice(this)
            lattice = this.oriented_lattice__;
        end
        %
        function this = set.lattice(this,val)
            if isa(val,'oriented_lattice')
                this.oriented_lattice__ = val;
            elseif isemtpy(val)
                this.oriented_lattice__ =[];
            else
                error('RUNDATA:set_lattice','set lattice parameter can be oriented_lattice only')
            end
        end
        %
        %
        function loader=get.loader(this)
            loader=this.loader__;
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
        %
        function this = set.efix(this,val)
            if isempty(this.loader__)
                this.efix__=val;
            else
                if ismember('efix',loader_can_define(this.loader__))
                    this.loader__.efix = val;
                else
                    this.efix__ = val;
                end
            end
        end
        function str = to_string(this)
            % convert class into linear string representation usable for
            % reverse conversion
            str = convert_to_string(this);
        end
        function iarr = serialize(this)
            % convert class into arry of bytes suitable for reverse
            % transformation by deserialize function
            % 
            % expects main data to be on a HDD, so no data loaded in memory are
            % serialized except memory only data
            iarr = serialize_(this);
        end
        
        
        
        %-----------------------------------------------------------------------------
        
        function this=saveNXSPE(this,filename,varargin)
            if isempty(this.loader)
                warning('RUNDATA:invalid_argument','nothing to save');
                return
            else
                ld=this.loader;
                if this.is_crystal
                    psi = this.lattice.psi;
                else
                    psi = nan;
                end
                this.loader__=ld.saveNXSPE(filename,this.efix,psi,varargin{:});
            end
            
        end
    end
end

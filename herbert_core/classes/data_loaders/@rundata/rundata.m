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
    % $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
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
        % instrument model
        instrument;
        % sample model
        sample;
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
        
        % instrument model holder;
        instrument_ = struct();
        % sample model holder
        sample_ = struct();
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
        function [runfiles_list,defined]=gen_runfiles(spe_files,varargin)
            % Returns array of rundata objects created by the input arguments.
            %
            %   >> [runfiles_list,file_exist] = gen_runfiles(spe_file,[par_file],arg1,arg2,...)
            %
            % Input:
            % ------
            %   spe_file        Full file name of any kind of supported "spe" file
            %                  e.g. original ASCII spe file, nxspe file etc.
            %                   Character string or cell array of character strings for
            %                  more than one file
            %^1 par_file        [Optional] full file name of detector parameter file
            %                  i.e. Tobyfit format detector parameter file. Will override
            %                  any detector inofmration in the "spe" files
            %
            % Addtional information can be included in the rundata objects, or override
            % if the fields are in the rundata object as follows:
            %
            %^1 efix            Fixed energy (meV)   [scalar or vector length nfile] ^1
            %   emode           Direct geometry=1, indirect geometry=2
            %^1 alatt           Lattice parameters (Ang^-1)  [vector length 3, or array size [nfile,3]]
            %^1 angdeg          Lattice angles (deg)         [vector length 3, or array size [nfile,3]]
            %   u               First vector defining scattering plane (r.l.u.)  [vector length 3, or array size [nfile,3]]
            %   v               Second vector defining scattering plane (r.l.u.) [vector length 3, or array size [nfile,3]]
            %^1 psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
            %^2 omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
            %^2 dpsi            Correction to psi (deg)            [scalar or vector length nfile]
            %^2 gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
            %^2 gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
            %
            % additional control keywords could modify the behaviour of the routine, namely:
            %  -allow_missing   - if such keyword is present, routine allows
            %                     some or all spe files to be missing. resulting
            %                     rundata class would contain runfile with undefined
            %                     loader. Par file(s) if provided, still have always be
            %                     defined
            %
            %
            % Output:
            % -------
            %   runfiles        Array of rundata objects
            %   file_exist   boolean array  containing true for files which were found
            %                   and false for which have been not. runfiles list
            %                   would then contain members, which do not have loader
            %                   defined. Missing files are allowed only if -allow_missing
            %                   option is present as input
            %
            % Notes:
            % ^1    This parameter is optional for some formats of spe files. If
            %       provided, overides the information contained in the the "spe" file.
            % ^2    Optional parameter. If absent, the default value defined by
            %       is used instead;
            [runfiles_list,defined]= rundata.gen_runfiles_of_type('rundata',spe_files,varargin{:});
        end
    end
    methods(Static,Access=protected)
        function [runfiles_list,defined]= gen_runfiles_of_type(type_name,spe_files,varargin)
            % protected function to access private rundata routine.
            % Generates files of the named type type_name, with rundata interface.
            [runfiles_list,defined]=gen_runfiles_(type_name,spe_files,varargin{:});
        end
    end
    
    methods
        %------------------------------------------------------------------
        % PUBLIC METHODS SIGNATURES:
        %------------------------------------------------------------------
        % Method verifies if all necessary run parameters are defined by the class
        [undefined,fields_from_loader,fields_undef] = check_run_defined(run,fields_needed);
        % Get a named field from an object, or a structure with all
        % fields.
        %
        %   >> val = get(object)           % returns structure of object contents
        %   >> val = get(object, 'field')  % returns named field, or an array of values
        %                                  % if input is an array
        varargout = get(this, index);
        
        % method returns default values, defined by default fields of
        % the class
        default_values =get_defaults(this,varargin);
        
        % Returns detector parameter data from properly initiated data loader
        [par,this]=get_par(this,format);
        
        % Returns whole or partial data from a rundata object
        [varargout] =get_rundata(this,varargin);
        % Load all data, defined by loader in memory. Do not overload by default                
        this = load(this,varargin);
        
        % Load in memory if not yet there all auxiliary data defined for
        % run except big array e.g. S, ERR, en and detectors
        [this,ok,mess,undef_list] = load_metadata(this,varargin);
        % Returns the name of the file which contains experimental data
        [fpath,filename,fext]=get_source_fname(this);
        
        % Check fields for data_array object
        [ok, mess,this] = isvalid (this);
        % method removes failed (NaN or Inf) data from the data array and deletes
        % detectors, which provided such signal
        [S_m,Err_m,det_m]=rm_masked(this);
        
        % method sets a field of  lattice if the lattice
        % present and initates the lattice first if it is not present
        this = set_lattice_field(this,name,val,varargin);
        
        % Returns the list data fields which have to be defined by the run for cases
        % of crystal or powder experiments
        [data_fields,lattice_fields] = what_fields_are_needed(this,varargin);
        %------------------------------------------------------------------        
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
                this = initialize(this,varargin{:});
            end
        end
        %
        function this = initialize(this,varargin)
            % part of non-default rundata constructor, allowing to
            % cunstruct rundata from different arguments
            if ~isempty(varargin)
                if ischar(varargin{1})
                    this=select_loader(this,varargin{1},varargin{2:end});
                else
                    this=set_param_recursively(this,varargin{1},varargin{2:end});
                end
            end
        end
        %
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
        %
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
            elseif isempty(val)
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
            %classname = class(this);
            %this = feval(classname);
            %this = this.initialize('data_file_name',val);
            this = this.select_loader(val);
            %this = rundata(this,'data_file_name',val);
        end
        function fname = get.data_file_name(this)
            % method to query what data file a rundata class uses
            fname = get_loader_field(this,'file_name');
        end
        %---
        function this = set.par_file_name(this,val)
            % method to change par file on defined loader
            data_fname = this.data_file_name;
            classname = class(this);
            out = feval(classname);%(this,'data_file_name',data_fname,'par_file_name',val));
            if isempty(data_fname)
                [~,~,fext] = fileparts(val);
                if strcmpi(fext,'.nxspe') %HACK assumes that par can be loaded from nxspe only! 
                    this = out.initialize(val,this); % shoule be fixed by 
                else
                    if isempty(this.loader__)
                        this.loader__ = memfile();
                    end
                    this.loader__.par_file_name = val;
                end
            else
                this = out.initialize(data_fname,val,this);
            end
            %this = this.select_loader('data_file_name',data_fname,'par_file_name',val);
        end
        function fname = get.par_file_name(this)
            % method to query what par file a rundata class uses. May be empty
            % for some data loaders, which have det information inside.
            fname = get_loader_field(this,'par_file_name');
        end
        function inst = get.instrument(this)
            % return instrument
            inst = this.instrument_;
        end
        %---
        function this = set.instrument(this,val)
            % set-up instrument (template)
            this.instrument_ = val;
        end
        function sam = get.sample(this)
            % return sample
            sam = this.sample_;
        end
        function this = set.sample(this,val)
            % set-up sample (template)
            this.sample_ = val;
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
        %------------------------------------------------------------------                
        %------------------------------------------------------------------
        
        function this=saveNXSPE(this,filename,varargin)
            % Saves current rundata in nxspe format.
            %
            % if some data are necessary for nxspe format have not yet been
            % loaded in memory, loads them in memory first.
            %
            % -reload  -- provide this option if you want to reload data
            %             from source files brfore saving them on hdd
            %             discarding anything already in the memory first.
            %
            %             psi and efix are not reloaded (BUG?)
            %
            % w, a,w+ and a+  options define readwrite or write access to the
            %               file. (see Matlab manual for details of these options)
            %              Adding to existing nxspe file is not
            %              currently supported, so the only difference
            %              between the options is that method will thow
            %              if the file, opened in read-write mode exist.
            %              Existing file in write mode will be silently
            %              overwritten.
            %  readwrite mode is assumed by  default
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


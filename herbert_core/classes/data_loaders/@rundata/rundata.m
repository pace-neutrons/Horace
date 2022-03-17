classdef rundata < serializable
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
    properties(Dependent)
        n_detectors ;   % Number of detectors, used when dealing with masked detectors  -- will be derived
        %
        S         ;     % Array of signal [ne x ndet]   -- obtained from speFile or equivalent
        ERR       ;     % Array of errors  [ne x ndet]  -- obtained from speFile or equivalent
        en        ;     % Column vector of energy bin boundaries   -- obtained from speFile or equivalent
        %
        % Detector parameters:
        det_par   ;   % Horace structure of par-values, describing detectors angular positions   -- usually obtained from parFile or equivalent
        % Helper variables used to display data file name and redefine
        % loader
        data_file_name;
        % par file name defined in loader
        par_file_name;

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
        % the number (id) uniquely identyfying the particular experiment
        % (run) which is the source of this object data.
        run_id;
    end

    properties(Constant,Access=private)
        % list of the fields defined in any loader
        loader_dependent_fields_={'S','ERR','en','det_par','n_detectors'};
        % minimal set of fields, defining reasonable run
        min_field_set_ = {'efix','en','emode','n_detectors','S','ERR','det_par'};

        % rundata may be filebased or memory based object, describing
        % crystal or powder. These are the fields which are defined in any
        % situation. Additional fields will become defined as
        serial_fields_ = {'loader','lattice','efix','emode','run_id','instrument','sample'};
    end
    properties(Access=protected)
        % energy transfer mode
        emode_=1;
        %  incident energy or crystal analyser energy
        efix_ = [];
        %
        % INTERNAL SERVICE PARAMETERS: (private read, private write in new Matlab versions)
        % The class which provides actual data loading:
        loader_ = [];

        % oriented lattice which describes crytsal (present if run describes crystal)
        lattice_ =[];

        % instrument model holder;
        instrument_ = IX_null_inst();
        % sample model holder
        sample_ = IX_null_sample();
        %
        run_id_ = [];
    end
    methods(Static)
        function fields = main_data_fields()
            fields = rundata.min_field_set_;
        end
        %
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
        %
        function id = extract_id_from_filename(file_name)
            % method used to extract run id from a filename, if runnumber is
            % present in the filename, and is first number among all other
            % numbers
            %
            [~,filename] = fileparts(file_name);
            [l_range,r_range] = regexp(filename,'\d+');
            if isempty(l_range)
                id = 1;
                return;
            end
            id = str2double(filename(l_range(1):r_range(1)));
        end
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = rundata();
            obj = loadobj@serializable(S,obj);
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
        % Load all data, defined by loader in memory. By default, not relpace
        % data which are already in memory
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
        [S_m,Err_m,det_m,non_masked]=rm_masked(this,varargin);

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
        function obj = initialize(obj,varargin)
            % part of non-default rundata constructor, allowing to
            % cunstruct rundata from different arguments
            if ~isempty(varargin)
                if ischar(varargin{1})
                    obj=select_loader_(obj,varargin{1},varargin{2:end});
                else
                    obj=set_param_recursively(obj,varargin{1},varargin{2:end});
                end
            end
        end
        %
        function fields = fields_with_defaults(this)
            % method returns data fields, which have default values
            fields = {'emode'};
            if ~isempty(this.lattice_)
                lattice_fields = oriented_lattice.fields_with_defaults();
                fields = [fields, lattice_fields];
            end
        end
        %----
        function mode = get.emode(this)
            % method to check emode and verify its default
            mode = this.emode_;
        end
        function this = set.emode(this,val)
            % method to check emode and verify its defaults
            if val>-1 && val <3
                this.emode_ = val;
            else
                error('HERBERT:rundata:invalid_argument',...
                    'unsupported emode %d, only 0 1 and 2 are supported',val);
            end
        end
        %----
        function is = get.is_crystal(this)
            if isempty(this.lattice_)
                is = false;
            else
                is = true;
            end
        end
        %
        function this = set.is_crystal(this,val)
            if val == 0
                this.lattice_ = [];
            elseif val == 1
                if isempty(this.lattice_)
                    this.lattice_ = oriented_lattice();
                end
            elseif isa(val,'oriented_lattice')
                this.lattice_ = val;
            else
                error('HERBERT:rundata:invalid_argument',...
                    ' you can either remove crystal information or set oriented lattice to define crystal');
            end
        end
        %
        function lattice = get.lattice(this)
            lattice = this.lattice_;
        end
        %
        function obj = set.lattice(obj,val)
            if isa(val,'oriented_lattice')
                obj.lattice_ = val;
            elseif isempty(val)
                obj.lattice_ =[];
            else
                error('HERBERT:rundata:invalid_argument',...
                    'lattice can be set as oriented_lattice instance object only')
            end
            % TODO: sample and lattice should be the same object
            lat = obj.lattice_;
            if ~isempty(lat)
                lat.angular_units = 'deg';
                if isa(obj.sample_,'IX_null_sample')
                    if is_defined(lat,'alatt') && is_defined(lat,'angdeg')
                        obj.sample_ = IX_samp('',lat.alatt,lat.angdeg);
                    end
                else
                    if is_defined(lat,'alatt')
                        obj.sample_.alatt = lat.alatt;
                    end
                    if is_defined(lat,'angdeg')
                        obj.sample_.angdeg = lat.angdeg;
                    end
                end
            end
        end
        %
        function id = get.run_id(obj)
            % return the index (numerical id which uniquely identifies
            % the experiment)
            % of the data used as the source of the rundata
            if ~isempty(obj.run_id_)
                id = obj.run_id_;
                return
            end
            id = find_run_id_(obj);
        end
        function obj = set.run_id(obj,val)
            if ~isnumeric(val)
                error('HERBERT:rundata:invalid_argument',...
                    ' run_id can be only numeric')
            end
            obj.run_id_ = val;
        end

        %
        function loader=get.loader(obj)
            loader=obj.loader_;
        end
        function obj = set.loader(obj,val)
            if isempty(val)
                obj.loader_ = [];
                return
            end
            if ~isa(val,'a_loader')
                error('HERBERT:rundata:invalid_argument',...
                    'The loader can be assigned by instance of a_loader object only. Actually it is %s',...
                    class(val))
            end
            obj.loader_ = val;
        end
        %------------------------------------------------------------------
        % A LOADER RELATED PROPERTIES
        %------------------------------------------------------------------
        function is = is_loaded(obj)
            % check if rundata are already loaded in memory
            is = false;
            if isempty(obj.loader_)
                return;
            end
            is = obj.loader_.is_loaded();
        end
        %
        function obj = unload(obj)
            % remove all rundata fields from memory and delete loader
            %
            if isempty(obj.efix_) && ~isempty(obj.loader_) && ...
                    ismember('efix',obj.loader_.defined_fields())
                obj.efix_ = obj.loader_.efix;
            end
            obj.loader_ = [];
        end
        %
        function ndet = get.n_detectors(this)
            % method to check number of detectors defined in rundata
            ndet = get_loader_field_(this,'n_detectors');
        end
        function S=get.S(this)
            S = get_loader_field_(this,'S');
        end
        function this = set.S(this,val)
            this=set_loader_field(this,'S',val);
        end
        function ERR=get.ERR(this)
            ERR = get_loader_field_(this,'ERR');
        end
        function this = set.ERR(this,val)
            this=set_loader_field(this,'ERR',val);
        end
        function det=get.det_par(this)
            det = get_loader_field_(this,'det_par');
        end
        function this = set.det_par(this,val)
            this=set_loader_field(this,'det_par',val);
        end
        function en=get.en(this)
            en=get_loader_field_(this,'en');
        end
        function this=set.en(this,val)
            this=set_loader_field(this,'en',val);
        end
        %
        function this = set.data_file_name(this,val)
            % Sets new data file name, and as the method to change data file for a run data class
            this = this.select_loader_(val);
        end
        function fname = get.data_file_name(this)
            % method to query what data file a rundata class uses
            fname = get_loader_field_(this,'file_name');
        end
        %---
        function obj = set.par_file_name(obj,val)
            % method to change par file on a defined loader
            if isempty(obj.loader_) % assuming both data and parameters are taken from
                % the same nxspe file (or will be stored in
                % it)
                obj.loader_ = loader_nxspe('',val);
            else
                obj.loader_.par_file_name = val;
            end
        end
        %
        function fname = get.par_file_name(this)
            % method to query what par file a rundata class uses. May be empty
            % for some data loaders, which have det information inside.
            fname = get_loader_field_(this,'par_file_name');
        end
        function inst = get.instrument(this)
            % return instrument
            inst = this.instrument_;
        end
        %---
        function this = set.instrument(this,val)
            % set-up instrument (template)
            if isa(val,'IX_inst')
                this.instrument_ = val;
            elseif isempty(val)
                this.instrument_  = IX_null_inst();
            else
                error('HERBERT:rundata:invalid_argument',...
                    'only instance of IX_inst class can be set as rundata instrument. You are setting %s',...
                    class(val))
            end
        end
        function sam = get.sample(this)
            % return sample
            sam = this.sample_;
        end
        function obj = set.sample(obj,val)
            % set-up sample (template)
            if isa(val,'IX_samp')
                obj.sample_ = val;
            elseif isempty(val)
                obj.sample_  = IX_null_sample();
            else
                error('HERBERT:rundata:invalid_argument',...
                    'only instance of IX_samp class can be set as rundata sample. You are setting %s',...
                    class(val))
            end
            if ~isa(obj.sample_,'IX_null_sample') %TODO: reconsile oriented lattice and sample
                sam = obj.sample;
                lat = obj.lattice;
                ou = lat.angular_units;
                lat.angular_units = 'deg';
                if ~isempty(sam.alatt)
                    lat.alatt = sam.alatt;
                end
                if ~isempty(sam.angdeg)
                    lat.angdeg = sam.angdeg;
                end
                lat.angular_units = ou;
                obj.lattice_ = lat;
            end
        end
        function is = eq(obj,other)
            if ~(isstruct(other) || isa(other,'rundata'))
                error('HERBERT:rundata:invalid_argument',...
                    'Can compare only two rundata objects or rundata object and structure. In fact other object is %s',...
                    class(other));
            end
            is= eq_(obj,other);
        end

        %------------------------------------------------------------------
        % A LOADER RELATED PROPERTIES -- END
        %------------------------------------------------------------------
        function efix = get.efix(this)
            efix = check_efix_defined_correctly(this);
        end
        %
        function this = set.efix(this,val)
            % always correct local efix, regardless of the state of the
            % loader
            this.efix_=val;
            if ~isempty(this.loader_)
                if ismember('efix',loader_define(this.loader_))
                    this.loader_.efix = val;
                end
            end
        end
        %------------------------------------------------------------------
        function ver  = classVersion(~)
            ver = 1;
        end
        function flds = indepFields(~)
            flds = rundata.serial_fields_;
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------

        function this=saveNXSPE(this,filename,varargin)
            % Saves current rundata in nxspe format.
            % usage:
            %>> rd.saveNXSPE(filename,[options]);
            %
            % Inputs:
            % filename -- the name of the nxspe file to save data to.
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
            % w, a, w+ and a+  options define readwrite or write access to the
            %             file. (see Matlab manual for details of these options)
            %              Adding to existing nxspe file is not
            %              currently supported, so the only difference
            %              between the options is that method will throw
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
                this.loader_=ld.saveNXSPE(filename,this.efix,psi,varargin{:});
            end
        end

    end
end

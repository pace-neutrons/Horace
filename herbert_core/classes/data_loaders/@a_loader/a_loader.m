classdef a_loader < a_detpar_loader_interface
    % Base class for all data loaders used by the rundata class and
    % loaders_factory
    %
    % Defines the interface for all common methods, used by loaders
    %
    % A new particular loader should define all abstract methods defined by this
    % loader and register new loader with the loaders_factory class.
    %
    % If the main data file contains detector information, new loader should also
    % overload methods responsible for loading detector's information to work
    % both with ASCII par files and the detector information containing in
    % the main data file (if the later intended to be used). These methods
    % are defined in asciipar_loader.
    %
    % When overloading abstract methods, a new loader should use (set/get)
    % protected data properties as public properties for
    % data variables ensure integrity of variables (waste of time when
    % loading from file)
    %
    %
    % the properties common for all data loaders.
    properties(Dependent)
        % number of detectors in par file or in data file (should be
        % consistent if both are present;
        n_detectors
        % signal
        S
        % error
        ERR
        % energy boundaries
        en
        % the variable which describes the file from which main part or
        % all data should be loaded
        file_name
    end
    properties(Dependent,Hidden)
        % property exposing detpar loader and giving possibility to set it
        % up to appropriate value
        detpar_loader;
    end

    properties(Access=protected)
        % number of detectors defined by data file (e.g. second dimension
        % of SPE Signal array)
        n_detindata_=[];
        % Internal Signal array
        S_=[];
        % Internal Error array
        ERR_=[];
        % internal energy bins array
        en_=[];
        % name of data file to load data from
        file_name_='';
        % the data fields which are defined by the main data file
        loader_define_={};
        % holder to keep appropriate class, responsible for loading the
        % detectors parameters
        detpar_loader_ = [];
        % the service property, whcih describes the validity of a_loader
        % object
        isvalid_ = true;
    end
    properties(Constant,Access=protected)
        fext_to_parloader_map_ = containers.Map({'.par','.phx','.nxspe'},...
            {asciipar_loader(),asciipar_loader(),nxspepar_loader()});
    end

    %
    methods(Abstract, Static)
        [ok,fh] = can_load(file_name);
        % method checks if the file_name can be processed by this file loader
        %
        %>>[is,fh]=loader.can_load(file_name)
        % Input:
        % file_name -- the name of the file to check
        % Output:
        %
        % is -- True if the file can be processed by the loader
        % fh -- (optional) the information which accelerates work with file
        %        recognized as suitable for a loader e.g. open file handle
        %        for an ASCII file to load. This information is used by
        %        loader's init function.
        [ndet,en,varargout]=get_data_info(file_name);
        % get information about spe-part of data defined in the data file
        % namely number of detectors and the energy bins
        %
        descr=get_file_description();
        % get the description of the file format, (e.g. used in GUI)
        %
        fext=get_file_extension();
        % returns the file extension used by this loader
    end
    %------------------------------------------------------------------
    % A_LOADER Interface:
    %------------------------------------------------------------------
    methods(Abstract)
        % Load main data defined for the loader. (e.g. Signal and Error)
        % Expected interface:
        %>>obj=load_data(obj,varargin);             1)
        %>>[S,ERR]=load_data(obj,varargin);          2)
        %>>[S,ERR,en]=load_data(obj,varargin);       3)
        %>>[S,ERR,en,obj]=load_data(obj,varargin);  4)
        %
        % the class instance has to be present in the RHS of the load_data statement in form 1 or 4
        % if one wants to load data into the the class memory itself.
        % forms 2) and 3) just load and return signal, error and energy bins if possible.
        [varargout]=load_data(obj,varargin);

        % the method performs the initialization of the main part of the constructor.
        %
        % Invoked separately it initializes a loader, defined by empty constructor.
        %
        % Common constructor of a specific loader the_loader should have the form similar to
        % the following:
        %
        % function obj = the_loader(data_file,par_file,varargin)
        %   obj =the_loader@a_loader(par_file);
        %   obj=obj.init(data_file,varargin);
        % end
        % See loader_ascii or loader_nxspe for actual example of init method and the constructor.
        obj=init(obj,data_file_name,varargin);

        % method sets internal file information obtained for appropriate file
        % by get_data_info method into internal class memory.
        obj=set_data_info(obj,file_name);
    end

    methods
        % constructor;
        function obj=a_loader(varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>obj=a_loader();
            %   constructor, which specifies par file name:
            %>>obj=a_loader(par_file_name);
            %   copy constructor:
            %>>obj=a_loader(other_loader);
            %
            if(nargin>0)
                if isa(varargin{1},'a_loader')
                    obj = varargin{1};
                else
                    obj.detpar_loader = varargin{1};
                end
            end
        end
        %
        function [ndet,en,obj]=get_run_info(obj)
            % Get number of detectors and energy boundaries defined by the data files
            % and detector files processed by obj class instance
            %
            % The definition can be both in data and detector part of the file
            % and this method checks if these data are consistent.
            %
            % >> [ndet,en] = get_par_info(the_loader)

            %  the_loader     -- is the instance of  a particular loader with initiated file.
            %  ndet            -- number of detectors defined in par&data file
            %  en              -- energy boundaries, defined in data file (e.g. spe file);
            %
            %

            [ok,mess,ndet,en] = is_loader_valid(obj);
            if ok<1
                error('A_LOADER:runtime_error',mess);
            end

            if isempty(obj.en)
                obj.en_ = en;
            end
            if isempty(obj.n_detectors)
                obj.n_detectors = ndet;
            end
        end
        %
        function fields = loader_define(obj)
            % what fields loader can actually define
            fields = obj.loader_define_;
            if ~isempty(obj.detpar_loader_)
                par_fields = obj.detpar_loader_.loader_define();
                not_in_loader = ~ismember(par_fields,fields);
                fields = [fields,par_fields{not_in_loader}];
            end
        end
        %
        function is = is_loaded(obj)
            % function checks if the run data are already located in memory
            %
            non_ldd = isempty(obj.S_)|| isempty(obj.ERR_)||isempty(obj.en_);
            if non_ldd
                is = false;
            else
                is = obj.valid_;
            end
        end
        %
        function fields = defined_fields(obj)
            % the method returns the cellarray of fields names,
            % which are defined by current instance of loader class
            %
            % e.g. loader_ascii defines {'S','ERR','en','n_detectrs} if par file is not defined and
            % {'S','ERR','en','det_par'} if it is defined and loader_nxspe defines
            % {'S','ERR','en','det_par','efix','psi'}(if psi is set up)
            %usage:
            %>> fields= defined_fields(loader);
            %   loader -- the specific loader constructor
            %

            % the method returns the cellarray of fields names, which are
            % defined by ascii spe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = check_defined_fields_(obj);
        end
        %
        function obj=delete(obj)
            % delete all memory demanding data/fields from memory and close all
            % open files (if any)
            %
            % loader class has to be present in RHS to propagate the changes
            % Deleter is generic until loaders fields are generic. Any specific
            % deleter should be overloaded
            %
            %
            obj.S_ = [];
            obj.ERR_ = [];
            if isempty(obj.file_name_)
                obj.en_=[];
                obj.n_detindata_=[];
            end
            if ~isempty(obj.detpar_loader_)
                obj.detpar_loader_ = obj.detpar_loader_.delete();
            end
            obj.isvalid_ = true;
        end
        %
        function [ok,mess,ndet,en]=is_loader_valid(obj)
            % method checks if a loader is fully defined and valid
            %Usage:
            %[ok,message,ndet,en]=loader.is_loader_valid();
            %
            %ok =  -1 if loader is undefined,
            %         0 if it is incosistant (e.g size(S) ~= size(ERR)) or size(en,1)
            %         ~=size(S,2) etc...
            %
            % if ok =1, intenal ndet and en fields are defined. This method can not
            % be invoked for a_loader, as uses abstract class methods,
            % defined by particular loaders
            [ok,mess,ndet,en] = is_loader_valid_internal(obj);
        end
        %
        function obj=load(obj,varargin)
            % load all information, stored in data and par files into
            % memory
            %usage:
            %loader = load(loader,['-keepexisting'])
            %
            %presumes that data file name and par file name (if necessary)
            %are already set up
            % -keepexisting  if option is present, method does not load/overwrite
            %                data, already loaded in memory if these data are consistent with
            %                the data defined by the file.
            %
            options = {'-keepexisting'};
            [ok,mess,keepexising]=parse_char_options(varargin,options);
            if ~ok
                error('HERBERT:a_loader:invalid_argument',mess);
            end


            if keepexising
                [s_empty,err_empty,dat_empty,det_empty] = data_empty_(obj);
                if dat_empty
                    [Sl,ERRl,enl]=obj.load_data();
                    obj.en_ = enl;
                    if s_empty
                        obj.S_ = Sl;
                    end
                    if err_empty
                        obj.ERR_ = ERRl;
                    end
                    obj.n_detindata_ = size(Sl,2);
                end
                if det_empty
                    [~,obj]=obj.load_par();
                end
                [ok,mess]=is_loader_valid(obj);
                if ~ok
                    error('HERBERT:a_loader:runtime_error',mess);
                end
            else
                obj=obj.load_data();
                [~,obj]=obj.load_par();
            end
        end
        %
        function obj=saveNXSPE(obj,filename,efix,psi,varargin)
            % method to save loaders data stored in memory as nxspe file

            % filename -- the name of the file to write data to. Should not exist
            % efix     -- incident energy for direct or indirect instrument. Only
            %             direct is currently supported through NEXUS instrument
            % Optional variables:
            % psi      -- the rotation angle of crystal. will be NaN if absent
            %
            % -reload  -- by default, saveNXSPE saves whatever is in memory
            %             and loads data from source file only if they are
            %             not already in the memory.
            %             provide this option if you want to reload data
            %             from source files brfore saving them on hdd
            %             discarding anything already in the memory.
            % w, a,w+ and a+  options define readwrite or write access to the
            %               file. (see Matlab manual for details of these options)
            %              Adding to existing nxspe file is not
            %              currently supported, so the only difference
            %              between the options is that method will thow
            %              if the file, opened in read-write mode exist.
            %              Existing file in write mode will be silently
            %              overwritten.
            %  readwrite mode is assumed by  default
            options = {'-reload'};
            % rw_mode is default, just for the future, it is not currently used
            [ok,mess,reload,remaining]=parse_char_options(varargin,options);
            if ~ok
                error('HERBERT:a_loader:invalid_argument',mess);
            end
            if reload
                obj=obj.load();
            else
                obj=obj.load('-keep');
            end

            save_nxspe_internal(obj,filename,efix,psi,remaining{:});
        end
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR CLASS PROPERTIES     -------------------
        % -----------------------------------------------------------------
        function obj=set.file_name(obj,new_name)
            % method checks if a file with the name file_name exists
            %
            % Then it sets this file name as the source data file name,
            % reads file info, calculates all dependent information and
            % clears all previously loaded run information
            % (if any) inconsistent with the new file or occupying substantial
            % memory.
            obj = set_data_file_name(obj,new_name);
        end
        %
        function filename = get.file_name(obj)
            % returns actual data file name, which is the source of the data,
            % this class instance is responsible for.

            filename = obj.file_name_;
        end
        %
        function ndet = get.n_detectors(obj)
            % method to get number of detectors, consistent between
            % data and detectors information
            if ~isempty(obj.detpar_loader_)
                ndet = obj.detpar_loader_.n_det_in_par;
            else
                ndet = [];
            end
            if isempty(ndet)
                ndet = obj.n_detindata_;
            else
                if ~isempty(obj.n_detindata_)
                    if obj.n_detindata_ ~= ndet
                        ndet = sprintf(...
                            'n_det from par file (%d) ~= n_det from data file (%d)',...
                            ndet,obj.n_detindata_);
                    end
                end
            end
        end
        %
        function S = get.S(obj)
            % get signal if all signal&error&energy fields are well defined
            S =obj.S_;
        end
        %
        function obj = set.S(obj,value)
            % set signal value consistent with error value
            obj = set_consistent_array(obj,'S_',value);
        end
        %
        function ERR = get.ERR(obj)
            % get error if all signal&error&energy fields are well defined
            ERR = obj.ERR_;
        end
        %
        function obj = set.ERR(obj,value)
            % set error consistent with signal value
            % disabled: and break connection between the error and the
            % data file if any
            obj = set_consistent_array(obj,'ERR_',value);
        end
        %
        function en = get.en(obj)
            % get energy bins
            en = obj.en_;
        end
        %
        function obj = set.en(obj,value)
            % set energy bin boundaries.
            value = value(:);            
            obj = set_consistent_array(obj,'en_',value);
        end
        %------------------------------------------------------------------
        % PAR file public interface
        %------------------------------------------------------------------
        function par_ldr = get.detpar_loader(obj)
            par_ldr  = obj.detpar_loader_;
        end
        function obj = set.detpar_loader(obj,val)
            obj  = set_detpar_loader(obj,val);
        end
        % ------------------------------------------------------------------
        function [ok,mess,f_name]=check_file_exist(obj,new_name)
            % method to check if file with extension correspondent to the
            % loader exists. Make public for easy overloading and work with memfiles.
            [ok,mess,f_name] = check_file_exist(new_name,obj.get_file_extension());
        end
        %
        function fields = par_can_define(obj)
            if isempty(obj.detpar_loader_)
                fields ={};
            else
                fields = par_can_define(obj.detpar_loader_);
            end
        end

        function [par,obj] = load_par(obj,varargin)
            % load detectors info from the previously defined or newly
            % set-up detector parameters file.
            options = {'-array','-forcereload','-getphx'};
            if numel(varargin)>0
                present = false(numel(options),1);
                [present(1),present(2),present(3) ,~,filename]=parse_loadpar_arguments(obj,varargin{:});
                argi = options(present);
            else
                filename = '';
                argi = {};
            end

            if isempty(filename)
                if isempty(obj.detpar_loader_)
                    error('HERBERT:a_loader:runtime_error',...
                        'Requested to load detectors parameters but the file-source of the parameters is not defined')
                end
            else
                % set new par file name and define new loader for this par
                % file
                obj.par_file_name = filename;
                if numel(varargin) >1
                    argi= varargin{2:end};
                end
            end
            %
            if nargout>1
                [par,obj.detpar_loader_] = obj.detpar_loader_.load_par(argi{:});
            else
                par = obj.detpar_loader_.load_par(argi{:});
            end
        end
        %------------------------------------------------------------------
        function flds = saveableFields(obj)
            flds = {'file_name','detpar_loader'};
            call_stack = dbstack;
            for_saving = strncmp(call_stack(2).name,'to',2);
            if for_saving
                if ~isempty(obj.en_)
                    flds = [flds(:)','en'];
                end
                if ~isempty(obj.S_)
                    flds = [flds(:)',{'S','ERR'}];
                end
            else
                flds = [flds(:)',{'en','S','ERR'}];
            end
        end

        function [ok,mess,obj] = check_combo_arg(obj)
            % verify if S,ERR and en  the validity of the
            % obtained serializable object. Return the result of the check
            %
            [ok,mess,obj] = check_combo_arg_(obj);
        end


    end
    %
    methods(Access=protected)
        function is = check_validity(obj)
            % overload this property to verify validity of interdependent
            % properties
            is = obj.isvalid_;
            if ~is
                [~,~,obj] = check_combo_arg(obj);
                is = obj.isvalid_;
            end
        end

        function obj = set_data_file_name(obj,filename)
            % protected method to call private set file name procedure
            %
            % protected to allow overloading by children
            obj = set_file_name_(obj,filename);
        end
        %------------------------------------------------------------------
        % A par_loader interface:
        %------------------------------------------------------------------
        function det_par= get_det_par(obj)
            % get method for dependent property det_par
            if isempty(obj.detpar_loader_)
                det_par = [];
            else
                det_par = obj.detpar_loader_.det_par;
            end
        end
        %
        function fname = get_par_file_name(obj)
            % get method for dependent property par_file_name
            if isempty(obj.detpar_loader_)
                fname = '';
            else
                fname = obj.detpar_loader_.par_file_name;
            end
        end
        %
        function ndet = get_n_det_in_par(obj)
            %method to retrieve number of detectors, defined by
            %parameters file
            if isempty(obj.detpar_loader_)
                ndet = [];
            else
                ndet = obj.detpar_loader_.n_det_in_par;
            end
        end
        %
        function obj=set_det_par(obj,value)
            %method checks and sets detector parameters from memory.
            %
            % normaly it sets up the existing detpar loader, but if one is
            % not defined, nxspepar_loader is used as a default
            if isempty(obj.detpar_loader_)
                obj.detpar_loader_ = nxspepar_loader();
                obj.detpar_loader_.det_par = value;
            else
                obj.detpar_loader_ = set_det_par(obj.detpar_loader_,value);
            end
        end
        function obj = set_detpar_loader(obj,val)
            if isempty(val)
                obj.detpar_loader_  = [];
            elseif isa(val,'a_detpar_loader_interface')
                obj.detpar_loader_  = val;
            elseif ischar(val) || isstring(val)
                obj = set_par_file_name(obj,val);
            else
                error('HERBERT:a_loader:invalid_argument',...
                    'The loader to set may be empty or should be a_detpar_loder_class or name of file to read detector parameters from. Actually it is %s',...
                    class(val))
            end
        end
        %
        function obj = set_par_file_name(obj,par_f_name)
            % Method sets this par file name as the source of the detector
            % parameters.
            %
            % If loader is not defined, the method also selects and initiates
            % appropriate par file loader depending on the file extension.
            %
            % If parameter's loader is already defined, the file should
            % have extension, appropriate for the loader selected.
            %
            % An empty filename clears the loader and removes detector info
            % from memory.
            if isempty(par_f_name)
                obj.detpar_loader_ = [];
                return;
            end
            if ~ischar(par_f_name) && ~isstring(par_f_name)
                error('HERBERT:a_loader:invalid_argument',...
                    ' A par file name, should be a string, defining the full path to the detectors parameter file');
            end

            if strcmp(obj.par_file_name,par_f_name)
                return; % nothing to do -- existing file requested
            end

            [~,~,fext] = fileparts(par_f_name);
            ldr = a_loader.fext_to_parloader_map_(lower(fext));
            ldr.par_file_name = par_f_name;
            obj.detpar_loader_ = ldr;
        end
        %------------------------------------------------------------------
    end
    methods(Static)
        function [ndet,varargout]=get_par_info(par_file_name)
            % get number of detectors and other detrcotrs methadata defined by
            % par,phx nxspe or other supported file
            if ~ischar(par_file_name)
                error('HERBERT:a_loader:invalid_argument',...
                    ' A par file name, should be a string, defining the full path to the detectors parameter file');
            end
            [~,~,fext] = fileparts(par_f_name);
            ldr = a_loader.fext_to_parloader_map_(lower(fext));
            nout = max(nargout,1) - 1;
            switch(nout)
                case -1
                    return;
                case 0
                    ndet = ldr.get_par_info(par_file_name);
                case 1
                    [ndet,varargout{1}] = ldr.get_par_info(par_file_name);
                case 2
                    [ndet,varargout{1},varargout{2}] = ldr.get_par_info(par_file_name);
                case 3
                    [ndet,varargout{1},varargout{2},varargout{3}]...
                        = ldr.get_par_info(par_file_name);
                case 4
                    error('A_LOADER:invalid_argument',...
                        'invalid numner of output arguments');
            end
        end
    end
    %
end


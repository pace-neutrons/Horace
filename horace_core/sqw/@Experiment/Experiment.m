classdef Experiment < serializable
    %EXPERIMENT Container object for all data describing the Experiment

    properties(Access=private)
        % String input here (a) invalid value so should be caught if not
        % redefined later (b) describes what the construction process is.
        instruments_ = 'initialised in constructor';
        detector_arrays_ = 'initialised in constructor';
        samples_ = 'initialised in constructor';
        samples_set_ = false; % Two prperties used to harmonize lattice
        expdata_set_ = false; % which stored both in sample and in expdata
        %holder to store old sample lattice if the new lattice is set
        old_lattice_holder_ = [];
        % NOTE: Not yet implemented
        % if both sample and expdata are set, all conain lattice and
        % lattices are different, expdata_ lattice takes priority
        expdata_ = [];

        %
        runid_map_ = [];   % the property defines the relationship between
        % the runid, contained in expdata and the position of the object
        % with this runid in the appropriate container (e.g. expdata
        % container but also correspondent samples instrument and (TODO:)
        % detector_arrays

        % True, if runid contained in expdata are inconsistent, and were
        % recalculated to make them consistent. If this have happened, it
        % is certainly old file, with runid_headers not defined correctly.
        % unfortunately, if it does not happen, it still may be old file
        % with incorrect header->pixel.run_indx connection.
        runid_recalculated_ = false;
    end

    properties (Dependent)
        n_runs;  % return the number of runs, this class contains
        % Mirrors of private properties
        instruments
        detector_arrays
        samples
        expdata
        % the property defines the relationship between
        % the runid, contained in expdata and the position of the object
        % with this runid in the appropriate container (e.g. expdata
        % container but also correspondent samples instrument and (TODO:)
        % detector_arrays
        runid_map;
        %
    end
    properties(Dependent,Hidden)
        % property providing compatibility with old header interface and
        % returning array of structures, with information used to written
        % in binary sqw file header.
        header
        % True, if runid contained in expdata are inconsistent, and were
        % recalculated to make them consistent. If this have happened, it
        % is certainly old file, with runid_headers not defined correctly.
        % unfortunately, if it does not happen, it still may be an old file
        % with incorrect header->pixel.run_indx connection.
        runid_recalculated
    end
    %----------------------------------------------------------------------
    % CONSTRUCTOR AND PROPERTIES ACCESSORS
    %----------------------------------------------------------------------
    methods
        function obj = Experiment(varargin)
            % Create a new Experiment object.
            %
            %   obj = Experiment()
            %   obj = Experiment(special_struct)
            %   obj = Experiment(detector_array[s], instrument[s], sample[s],expdata[s])
            %
            %
            %
            % Inputs:
            % 1) special_struct -- the structure, obtained from
            %                      experiment by to_struct or to_bare_struct methods
            %
            % 2)
            %   detector_array --  Detector array (IX_detector_array objects)
            %   instrument     --  cellarray of Instrument (Concrete class inheriting IX_inst)
            %   sample         --  cellarray of Sample data (IX_sample objects)
            %   expdata        --  Array of IX_experiment (instr_proj?)
            %                      objects.
            %   The number of elements in instrument sample and expdata
            %   containers have to be equal
            % 3)
            %    The set of key-value pairs where the key is the name of the
            %    property and the value -- its value.
            %    force_runid_recalculation, if used must be the last input
            %    and can  not be preceded with key.
            %
            % Returns:
            % obj       -- valid initialized instance of the Experiment
            %              object.
            %
            % Each argument can be a single object or array of objects.
            
            obj = obj@serializable();
            
            % initialising the compressed component containers.
            % these may be overwritten if they are passed in as arguments
            % below
            obj.instruments_ = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            obj.detector_arrays_ = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER','IX_detector_array');
            obj.samples_ = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER','IX_samp');
            % expdata is not compressed and has been initialised as an
            % empty array
            
            if nargin == 0 || (nargin == 1 && isempty(varargin{1}))
                % no components in initialising arguments
                % so finish
                return;
                
            elseif nargin == 4
                % arguments are the component arrays, 
                % initialise them
                detector_arrays = varargin{1};
                instruments     = varargin{2};
                samples         = varargin{3};
                expdata         = varargin{4};

                % define expdata first, as the size of this determines the
                % number of runs which obj will hold
                if isa(expdata, 'IX_experiment')
                    % add to default compressed container
                    % this must be of the right size to define number of
                    % runs for the experiment - the other fields can handle
                    % adding duplicates once they know this numberval,
                    obj.expdata_ = expdata;
                elseif isempty(expdata)
                    % do nothing, leave default array container empty
                else
                    error('HORACE:Experiment:invalid_argument', ...
                          'input is not empty or IX_experiment');
                end
                                
                obj = obj.add_input_with_checks(detector_arrays, 'IX_detector_array');
                
                obj = obj.add_input_with_checks(instruments,     'IX_inst');
                
                obj = obj.add_input_with_checks(samples,         'IX_samp');
                
                                
            elseif nargin == 1 
                arg = varargin{1};
                if ~iscell(arg)
                    % make arg a cell so that it is a cell array regardless
                    % of whether it is a single header struct or a cell
                    % array of header structs
                    arg = { arg };
                end
                if ~obj.isoldheader(arg{1})
                    error('HORACE:Experiment:invalid_argument', ...
                           ['single argument is not an oldstyle header struct', ...
                            ' or cell of such structs']);
                end
                % now have cell array of headers, init_ will process
                varargin{1} = arg;
                
            else
                error('HORACE:Experiment:invalid_argument', ...
                      ['the other cases do not yet have examples ',...
                       'so catching them here until we can do them ',...
                       'properly']);
            end
            obj = init_(obj,varargin{:});
        end
        
        %
        function obj = init(obj,varargin)
            % initialize Experiment object using various possible forms of inputs,
            % provided to Experiment constructor.
            if nargin == 1
                return;
            end
            obj = init_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function val=get.detector_arrays(obj)
            val=obj.detector_arrays_;
        end
        function obj=set.detector_arrays(obj, val)
            if isempty(val)
                % many inputs have unset detectors, leave container as-is
                % from default initialisation
                return
            end
            std_form = check_si_input(obj,val,'IX_detector_array');
            obj.detector_arrays_ = std_form;
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        function obj=set.instruments(obj, val)
            std_form = check_si_input(obj,val,'IX_inst');
            obj.instruments_ = std_form;

            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function val=get.samples(obj)
            val=obj.samples_;
        end
        function obj=set.samples(obj, val)
            std_form = check_si_input(obj,val,'IX_samp');
            %
            [obj,std_form] = check_lattice_defined_(obj,std_form);
            obj.samples_ = std_form;
            obj.samples_set_ = true;

            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end

        end
        %
        function val=get.expdata(obj)
            val=obj.expdata_;
        end
        function obj=set.expdata(obj, val)
            %check and set the classes, containing main
            %information about every run of the experiment
            %
            % Input should contain one or array of such classes
            obj = check_and_set_expdata_(obj,val);
        end
        %
        function map = get.runid_map(obj)
            % deep copy handle class, to maintain consistent behaviour
            if isempty(obj.runid_map_)
                map = [];
            else % copy existing map as containers.Map is handle now.
                map = containers.Map(obj.runid_map_.keys,obj.runid_map_.values);
            end
        end
        function obj = set.runid_map(obj,val)
            % Check and set runid_map, connecting run-id, describing the
            % experiment and the number of the experiment information
            % header in the list of all experiment descriptors.
            %
            obj = set_runid_map_(obj,val);
        end
        %------------------------------------------------------------------
        function nr = get.n_runs(obj)
            nr = numel(obj.expdata_);
        end
        function is = get.runid_recalculated(obj)
            is  = obj.runid_recalculated_;
        end
        function obj = set.runid_recalculated(obj,val)
            % Do not normally use, except for tests. This is internal
            % property, which inform about the behaviour of runid map
            obj.runid_recalculated_ = logical(val);
        end
    end
    %----------------------------------------------------------------------
    % legacy instrument methods interface
    %----------------------------------------------------------------------
    methods
        %Change fields in the experiment with corrections related to aligned
        %crystal lattice parameters and orientation
        obj=change_crystal(obj,alignment_info,varargin)

        % add or reset instrument, related to the given experiment object
        % array of instruments, or function, which defines the instrument
        % with its possible parameters
        obj = set_instrument(obj,instrument,varargin)
        % set moderator pulse on every instrument contributing to the
        % object
        obj = set_mod_pulse(obj,pulse_model,pm_par)
        % Return array of incident energies from all contributing runs
        en = get_efix(obj);
        function emode = get_emode(obj)
            % Return array of instrument modes provided in all contributing runs
            emode = arrayfun(@(x)x.emode,obj.expdata_,'UniformOutput',true);
        end
        function obj = set_efix_emode(obj,efix,emode)
            % change efix and (optionally) emode in all experiment descriptions
            % if emode is absent or described by any character string,
            % the emode is kept unchanged
            if nargin == 2
                emode = '-keep_emode';
            elseif isempty(emode)
                emode = '-keep_emode';
            end
            obj = set_efix_emode_(obj,efix,emode);
        end

        function [pulsemodel,pm_par,present] = get_mod_pulse(obj)
            % Get moderator pulse model names and array of pulse parameters
            % from all runs, contributing to the class
            % if present is false, all or some instruments in runs do not
            % have defined moderator
            %
            [pulsemodel,pm_par,present] = get_mod_pulse_(obj);
        end
        %
        function expi = get_aver_experiment(obj)
            % some, presumably average, run-data. Naive implementation,
            % all data are the same
            expi = obj.expdata(1);
        end
        %
        function is = is_same_ebins(obj)
            % return true if all energy bins of all runs are the
            % same
            is=true;
            en=obj.expdata(1).en;
            for i=2:obj.n_runs
                if numel(en)~=numel(obj.expdata(i).en) || ~all(en==obj.expdata(i).en)
                    is=false;
                    break
                end
            end
        end
        function [inst, all_inst] = get_inst_class (obj)
            % Retrieve the main instrument instance from the collection of
            % instruments.
            % TODO: Confusing. See ticket #917 for modification/clarification
            %
            [inst, all_inst] = get_inst_class_(obj);
        end
        %
        function instr = get_unique_instruments(obj)
            % compatibility fields with old binary file formats
            instr = obj.instruments_.unique_objects;
        end
        %
        function samp = get_unique_samples(obj)
            % compatibility fields with old binary file formats
            samp = obj.samples_.unique_objects;
        end
        %
        function obj = set_sample(obj,val)
            % compartibility with sqw interface
            obj.samples = val;
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function [efix,emode,ok,mess,en] = calc_efix_avrgs(efix_arr,emode_arr,tol)
            % calculate specific (emode dependent) average of efix array
            [efix,emode,ok,mess,en] = calc_efix_avrgs_(efix_arr,emode_arr,tol);
        end
        function [pulse_model,pm_par_avrg,ok,mess,p] =calc_mod_pulse_avrgs(pm_par,pm_list,tol)
            %calculates average parameters of the pulse model provided
            [pulse_model,pm_par_avrg,ok,mess,p] =calc_mod_pulse_avrgs_(pm_par,pm_list,tol);
        end
    end
    %----------------------------------------------------------------------
    methods
        %
        function exp = get_experiments(obj,ind)
            % return experiment info, which corresponds to the appropriate
            % experiment indexes provided.
            %
            % Inputs:
            % obj -- the instance of the experiment
            % ind -- array of the indexes, to select experiments for.
            %
            % Returns:
            % exp -- the Experiment class instance containing information,
            %        corresponding to the run indexes provided as input.
            exp = get_experiments_(obj,ind);
        end
        %
        function subexper = get_subobj(obj,runids_to_keep,varargin)
            % Return Experiment object containing subset of experiments,
            % requested by the method.
            %
            % Input:
            % obj       -- initialized instance of the Experiment, containing
            %              information about experiments(runs) contributed into sqw
            %              object.
            % runids_to_keep
            %            -- run_id-s,which identify particular experiments(runs)
            %              to include the  experiments(runs) contributing
            %              into the final subset  of experiments.
            % Optional switches:
            % '-indexes'   - if provided, tread input runids_to_keep as
            %              direct indexes of the experiments to keep rather
            %              then run_id(s). Mainly used for debugging.
            % '-modify_runid'
            %          -- if present redefine final runid_map and run_ind of
            %             the expdata to count from 1 to n_experiments(runs)
            % Returns:
            % subexper  -- the Experiment object, containing information
            %              about experiments(runs) defined by
            %              runids_to_keep.
            %
            opt = {'-indexes'};
            [ok,mess,indexes_provided] = parse_char_options(varargin,opt);
            if ~ok
                error('HORACE:Experiment:invalid_argument',mess);
            end
            subexper = get_subobj_(obj,runids_to_keep,indexes_provided);
        end
        %
        % GEN_SQW interface
        %------------------------------------------------------------------
        function [avh,ebins_are_the_same] = header_average(obj)
            % very crude implementation for the header, average over all
            % runs.
            %
            if isempty(obj.expdata)
                avh = [];
            else
                avh = obj.expdata_(1);
            end
            if nargout>1
                ebins_are_the_same = obj.is_same_ebins();
            else
                ebins_are_the_same=[];
            end
            if isempty(avh)
                avh = struct();
            else
                avh = avh.to_bare_struct();
            end
            sampl = obj.samples_{1};
            if ~isempty(sampl)
                avh.alatt = sampl.alatt;
                avh.angdeg = sampl.angdeg;
            else
                avh.alatt  = [];
                avh.angdeg = [];
            end
        end
        %------------------------------------------------------------------
        % REDUNDANT AND OLD FILE FORMAT COMPARTIBILITY METHOS
        %------------------------------------------------------------------
        function head = get.header(obj)
            head = obj.convert_to_old_headers();
            head = [head{:}];
            head = rmfield(head,{'instrument','sample'});
        end
        function oldhdrs = convert_to_old_headers(obj,varargin)
            % convert Experiment into the structure suitable to be
            % stored in old binary sqw files (up to version 3.xxx)
            %
            % this structure is also used in number of places of the old
            % code where, e.g., structure sorting is implemented but this
            % usage is deprecated and will be removed in a future.
            %
            % Optional Inputs:
            % header_num -- if provided, convert only experiment data
            %               corresponding to header number provided
            % '-nomangle'-- if provided, do not modify filename with
            %               additional run_id information (normally assumed
            %               "false" when writing new file or "true" when
            %               upgrading file format
            %
            [ok,mess,nomangle,remains] = parse_char_options(varargin,{'-nomangle'});
            if ~ok
                error('HORACE:Experiment:invalid_argument',mess);
            end
            oldhdrs = convert_to_old_headers_(obj,nomangle,remains{:});
        end
    end
    %
    methods(Access=private)
        % copy non-empty contents to the contents of this class
        [obj,n_added] = check_and_copy_contents_(obj,other_cont,field_name);
        %
        function std_form = check_si_input(~,sample_or_instrument,class_base)
            % The function is the common part of the checks to set sample
            % or instrument methods.
            %
            % check if input is sample or instrument type input and return
            % standard form of the class, to store within the class method.
            % Inputs:
            % sample_or_instrument --object or collection of objects in any
            %                        standard form acceptable
            % class_base           --base class for samples or instruments
            %                        depending on sample or instrument is
            %                        verified
            % Output:
            % std_form -- the standard form of sample or instrument
            %             collection to store within the container
            % Throws 'HORACE:Experiment:invalid_argument' if the input can
            % not be converted into the standard form
            std_form = check_sample_or_inst_array_and_return_std_form_(...
                sample_or_instrument,class_base);
        end
        
        function obj = add_input_with_checks(obj, val,type)
            % ADD_INPUT_WITH_CHECKS
            % Add val to one of the unique_reference_container properties.
            % This makes sure that the right thing is added and any
            % duplicates are handled.
            %
            % Input
            % -----
            % - obj:   the Experiment object to which val is being added
            % - val:   the object or container of objects which is being
            %          added. this could be a unique_references_container
            %          or unique_objects_container with baseclass 'type'
            %          or an object which 'isa(,type)'
            % - type:  string naming the baseclass to which val should
            %          belong
            %
            % Output
            % ------
            % - obj:   the modified Experiment object where the value of
            %          the field named by the calling form of val (using
            %          inputname(val#argnum) is modified by adding val if
            %          val is not a unique_references-container or setting
            %          it if it is a unique_references_container

            % get the name of the calling variable which enters as 'val'
            field = [inputname(2) '_'];

            if isa(val, 'unique_references_container') && ...
                   strcmp(val.stored_baseclass,type)
                % if size is right, overwrite default compressed container
                if val.n_runs == obj.n_runs
                    obj.(field) = val;
                else
                    error('HORACE:Experiment:invalid_argument', ...
                          'input %d size must match number of runs',obj.n_runs);
                end


            elseif ( isa(val, type) &&                       ...
                     numel(val) == obj.n_runs )              ...
                   ||                                        ...                   
                   ( isa(val, 'unique_objects_container') && ...
                     val.n_runs == obj.n_runs             && ...
                     strcmp(val.baseclass, type) )           ...
                   ||                                        ...
                   ( iscell(val)                          && ...
                     numel(val) == obj.n_runs             && ...
                     isa(val{1}, type) )

                % add to default compressed container
                obj.(field) = obj.(field).add(val);

            elseif ( isa(val, type) &&                       ...
                     numel(val) == 1 )                       ...
                   ||                                        ...
                   ( iscell(val)                          && ...
                     numel(val) == 1                      && ...
                     isa(val{1}, type) )
                % assume we're adding n_runs identical copies
                % 
                % add to default compressed container
                %{
                for i=1:obj.n_runs
                    obj.(field) = obj.(field).add(val);
                end
                %}
                obj.(field) = obj.(field).add_copies_(val, obj.n_runs);

            elseif isempty(val)
                % do nothing, leave default compressed container empty
                ;
            else
                error('HORACE:Experiment:invalid_argument', ...
                      ['input is not empty, does not have the right number ' ...
                       'of runs, or is not of type %s'], type);
            end
        end
    end
    %
    methods(Static)
        function obj = build_from_binfile_headers(headers)
            % restore basic experiment info from old style headers,
            % stored on hdd.
            %
            obj = build_from_binfile_headers_(headers);
        end
        function [args,npar] = check_and_expand_function_args(varargin)
            % Check arguments have one of the permitted forms below
            %
            %   >> argout=check_and_expand_function_args(arg1,arg2,...)
            %
            % Input:
            % ------
            %   arg1,arg2,...  Input arguments
            %                  Each argument can be a 2D array with 0,1 or more rows
            %                  If more than one row in an argument, then this gives the
            %                  number of argument sets.
            %
            % Output:
            % -------
            %   argout         Cell array of arguments, each row a cell array
            %                  with the input arguments
            %
            % Checks arguments have one of following forms:
            %	- scalar, row vector (which can be numerical, logical,
            %     structure, cell array or object), or character string
            %
            %   - Multiple arguments can be passed, one for each run that
            %     constitutes the sqw object, by having one row per run
            %   	i.e
            %       	scalar      ---->   column vector (nrun elements)
            %           row vector  ---->   2D array (nrun rows)
            %        	string      ---->   cell array of strings
            %
            % Throws if not valid form
            [args,npar] = check_and_expand_function_args_(varargin{:});
        end

        function [exp,nspe] = combine_experiments(exp_cellarray,allow_equal_headers,keep_runid)
            % take cellarray of experiments (e.g., generated from each runfile build
            % during gen_sqw generation)
            % and combine then together into single Experiment info class
            %
            %This is the HACK, providing only basic functionality. Previous
            %header-s on the basis of sqw_header and part, present in
            %write_nsqw_to_sqw implementation offers much more.
            %
            %TODO: Do proper optimization on the way. See
            % sqw_header.header_combine(header,allow_equal_headers,drop_subzone_headers)
            %TODO: use allow_equal_headers,drop_subzone_headers variables
            %      appropriately
            %TODO: repeat at least the logic within sqw_header helper class
            %      and write_nsqw_to_sqw combine/check headers operation
            n_contrib = numel(exp_cellarray);
            nspe = zeros(n_contrib,1);
            for i=1:n_contrib
                nspe(i) = exp_cellarray{i}.n_runs;
            end
            n_tot = sum(nspe);
            instr  = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER', ...
                                                 'IX_inst'); %cell(1,n_tot);
            sampl  = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER', ...
                                                 'IX_samp'); %cell(1,n_tot);
            detectors = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER', ...
                                                    'IX_detector_array');
            %warning('stop here so you can check that instr and sampl should no longer be set as cells');
            expinfo= repmat(IX_experiment(),1,n_tot);
            ic = 1;
            %TODO: combine instruments using unique_objects_container
            %      rather than doing a complete unpack and repack
            for i=1:n_contrib
                if exp_cellarray{i}.n_runs ~= 1
                   error('HORACE:Experiment:combine_experiments', ...
                         'input data is for more than one run per input');
                end
                for j=1:exp_cellarray{i}.n_runs
                    instr{ic}  = exp_cellarray{i}.instruments{j};
                    sampl{ic}  = exp_cellarray{i}.samples{j};
                    expinfo(ic)= exp_cellarray{i}.expdata(j);
                    detectors(ic) = exp_cellarray{i}.detector_arrays{j};
                    if ~keep_runid
                        expinfo(ic).run_id = ic;
                    end                    
                    ic = ic+1;
                end
            end
            exp = Experiment(detectors, instr, sampl,expinfo);
        end
    end
    %======================================================================
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    properties(Constant,Access=private)
        % the order is important as in this order the component will be set
        % during deserialization, so this order is chosen to avoid
        % repetitive unnecessary checks
        fields_to_save_ = { 'expdata','detector_arrays','instruments','samples'};
    end
    
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
        %
        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = Experiment.fields_to_save_;
        end
        %
        function obj = check_combo_arg(obj)
            % verify consistency of Experiment containers
            %
            % Inputs:
            % obj  -- the initialized instance of Experiment obj
            %
            % Returns: unchanged object if Experiment components are
            %          consistent.
            %          Throws HORACE:Experiment:invalid_argument with
            %          details of the issue if they are not
            obj = check_combo_arg_(obj);
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            %
            if isfield(inputs,'filename') && isfield(inputs,'efix') % this is probably old single header
                obj = build_from_old_headers_(obj,{inputs});
            elseif iscell(inputs) && isfield(inputs{1},'filename') && isfield(inputs{1},'efix')
                % build from cellarray of headers
                obj = build_from_old_headers_(obj,inputs);
            else
                if isfield(inputs,'array_dat')
                    obj = obj.from_bare_struct(inputs.array_dat);
                else
                    obj = obj.from_bare_struct(inputs);
                end
            end
        end
    end
    methods(Static)
        function ishdr = isoldheader(val)
            ishdr = isstruct(val) && ...
                    all(isfield(val,{'alatt','angdeg','efix','emode'}));
        end
        
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = Experiment();
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
end


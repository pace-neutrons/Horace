classdef Experiment < serializable
    %EXPERIMENT Container object for all data describing the Experiment

    properties(Access=private)
    	% the vanilla constructor will give instruments_ one IX_null_inst
    	% if no other instrument input is provided - see constructor
        instruments_ = unique_objects_container('type','{}','baseclass','IX_inst'); %{}; %IX_inst.empty;
        detector_arrays_ = []
        samples_ = {IX_null_sample()}; % IX_samp.empty;
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
    properties(Constant,Access=private)
        % the order is important as in this order the component will be set
        % during deserialization, so this order is chosen to avoid
        % repetitive unnecessary checks
        fields_to_save_ = {'detector_arrays','instruments','samples',...
            'expdata'};
    end


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
            %   expdata        --  Array of IX_experinent (instr_proj?)
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
            if nargin == 0
            	% add one null instrument if using the vanilla constructor
            	% to satisfy the requirements of subsequent initialisation
                inst = IX_null_inst();
                obj.instruments = obj.instruments.add(inst);
                return;
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
        %
        function val=get.detector_arrays(obj)
            val=obj.detector_arrays_;
        end
        function obj=set.detector_arrays(obj, val)
            if isa(val,'IX_detector_array') || isempty(val)
                obj.detector_arrays_ = val;
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Detector array must be one or an array of IX_detector_array object')
            end
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end            
        end
        %
        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        function obj=set.instruments(obj, val)
            [is,std_form] = check_si_input(obj,val,'IX_inst');
            if is
                obj.instruments_ = std_form; %(:)';
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'instruments must be a cellarray or array of IX_inst objects . In fact it is %s',...
                    class(val));
            end
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function val=get.samples(obj)
            val=obj.samples_;
        end
        function obj=set.samples(obj, val)
            [is,std_form] = check_si_input(obj,val,'IX_samp');
            if is
                obj.samples_ = std_form(:)';
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Samples must be a cellarray or array of IX_samp objects . In fact it is %s',...
                    class(val));
            end
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end

        end
        %
        function val=get.expdata(obj)
            val=obj.expdata_;
        end
        function obj=set.expdata(obj, val)
            if all(isempty(val))
                if ~isa(val,'IX_experiment')
                    obj.expdata_ = [];
                    obj.runid_map_ = [];
                    return;
                end
            end
            if ~isa(val,'IX_experiment')
                error('HORACE:Experiment:invalid_argument', ...
                    'Sample must be one or an array of IX_experiment objects or empty. Actually it is: %s',...
                    class(val))
            end
            obj.expdata_ = val(:)';
            obj = build_runid_map_(obj);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end

        end
        %
        function map = get.runid_map(obj)
            % deep copy handle class, to maintain consistent behaviour
            if isempty(obj.runid_map_)
                map = [];
            else
                map = containers.Map(obj.runid_map_.keys,obj.runid_map_.values);
            end
        end
        function obj = set.runid_map(obj,val)
            % set runid or runid map and
            %
            if isa(val,'containers.Map')
                obj.runid_map_ = val;
                keys = val.keys;
                keys = [keys{:}];
            elseif isnumeric(val) && numel(val) == obj.n_runs
                keys = val(:)';
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'input for runid_map should be map, defining connection between run-ids and headers(expdata), describing these runs or array of runid-s to set. It is %s', ...
                    class(val))
            end
            obj = set_runids_map_and_synchonize_headers_(obj,keys);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end

        end
        %------------------------------------------------------------------
        function is = get.runid_recalculated(obj)
            is  = obj.runid_recalculated_;
        end
        function obj = set.runid_recalculated(obj,val)
            % Do not normally use, except for tests. This is internal
            % property, which inform about the behaviour of runid map
            obj.runid_recalculated_ = logical(val);
        end
        %------------------------------------------------------------------
        function nr = get.n_runs(obj)
            nr = numel(obj.expdata_);
            if nr == 1
                if isempty(obj.expdata_(1))
                    nr = 0;
                end
            end
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
        % instrument methods interface
        %------------------------------------------------------------------
        function obj = set_efix_emode(obj,efix,emode)
            % change efix and (optionally) emode in all experiment descriptions
            % if emode is absent or described by any character string,
            % the emode is kept unchanged
            if nargin == 2
                emode = '-keep_emode';
            end
            obj = set_efix_emode_(obj,efix,emode);
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
            avh = avh.to_bare_struct();
            sampl = obj.samples_{1};
            avh.alatt = sampl.alatt;
            avh.angdeg = sampl.angdeg;
        end
        %
        function instr = get_unique_instruments(obj)
            % compatibility fields with old binary file formats
            % TODO: needs proper implementation
            instr = obj.instruments_;
            error("should not be using this any more");
        end
        %
        function samp = get_unique_samples(obj)
            % compatibility fields with old binary file formats
            % TODO: needs proper implementation
            samp = obj.samples_;
        end
        %
        function head = get.header(obj)
            head = obj.convert_to_old_headers();
            head = [head{:}];
            head = rmfield(head,{'instrument','sample'});
        end
        %
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
            if ~isempty(remains)
                header_num = remains{:};
            else
                header_num = [];
            end
            samp = obj.get_unique_samples();
            if iscell(samp) && numel(samp) == obj.n_runs
                different_samples = true;
            else
                different_samples = false;
                if iscell(samp)
                    samp = samp{1};
                end
            end
            if ~isempty(header_num)
                oldhdrs = obj.expdata_(header_num).convert_to_binfile_header( ...
                    samp.alatt,samp.angdeg,nomangle);
            else
                nruns = obj.n_runs;
                oldhdrs = cell(nruns,1);
                for i=1:nruns
                    if different_samples
                        alatt = samp{i}.alatt;
                        angdeg = samp{i}.angdeg;
                    else
                        alatt = samp.alatt;
                        angdeg = samp.angdeg;
                    end
                    oldhdrs{i} = obj.expdata_(i).convert_to_binfile_header( ...
                        alatt,angdeg,nomangle);
                end
            end
        end

        % SERIALIZABLE interface
        %------------------------------------------------------------------
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

    methods(Access=protected)
        %------------------------------------------------------------------
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
            %if isfield(inputs,'version')
            %      do check for previous versions
            %      and appropriate code
            %end
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
    %
    methods(Access=private)
        % copy non-empty contents to the contents of this class
        [obj,n_added] = check_and_copy_contents_(obj,other_cont,field_name);
        %
        function [is,std_form] = check_si_input(obj,sample_or_instrument,class_base)
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
            % is       -- true, if sample_or_instrument input is convertible to
            %             the standard form.
            % std_form -- the standard form of sample or instrument
            %             collection to store within the container
            [is,std_form] = check_sample_or_inst_array_and_return_std_form_(...
                obj,sample_or_instrument,class_base);
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
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = Experiment();
            obj = loadobj@serializable(S,obj);
        end
        function [exp,nspe] = combine_experiments(exp_cellarray,allow_equal_headers,drop_subzone_headers)
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
            instr  = cell(1,n_tot);
            sampl  = cell(1,n_tot);
            expinfo= repmat(IX_experiment(),1,n_tot);
            ic = 1;
            %TODO: combine instruments using unique_objects_container
            %      rather than doing a complete unpack and repack
            for i=1:n_contrib
                for j=1:exp_cellarray{i}.n_runs
                    %instr{ic}  = exp_cellarray{i}.instruments{j};
                    sampl{ic}  = exp_cellarray{i}.samples{j};
                    expinfo(ic)= exp_cellarray{i}.expdata(j);
                    ic = ic+1;
                end
            end
            if isa(exp_cellarray{1}.instruments,'unique_objects_container')
                instr = exp_cellarray{1}.instruments;
                for i=2:n_contrib
                    for j = 1:exp_cellarray{i}.n_runs
                        instr = instr.add(exp_cellarray{i}.instruments{j});
                    end
                end
            else
                error('should be only uocs here');
            end
            exp = Experiment([], instr, sampl,expinfo);
        end
    end
    %======================================================================
end


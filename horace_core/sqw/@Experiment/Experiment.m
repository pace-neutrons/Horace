classdef Experiment < serializable
    %EXPERIMENT Container object for all data describing the Experiment

    properties(Access=protected)
        instruments_ = {IX_null_inst()};
        detector_arrays_ = []
        samples_ = {IX_null_sample()}; % IX_samp.empty;
        expdata_ = IX_experiment();

        % TODO: rebuild sqw object to use runid_map stored in the Experiment
        runid_map_ = [];   % the property defines the relationship between
        % the runid, contained in expdata and the position of the object
        % with this runid in the appropriate container (e.g. expdata
        % container but also correspondent samples instrument and (TODO:)
        % detector_arrays

        % True, if runid contained in expdata are inconsitent, and were
        % recalculated to make them consistent.
        runid_recalculated_ = false;
        % if true, runid map is always recalculated on change in
        % expdata regardless of the consistency of the runid-s stored in
        % expdata
        force_runid_recalculation_ = false;

        % property which informs about experiment class validity
        isvalid_ = true;
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
        % True, if runid contained in expdata are inconsitent, and were
        % recalculated to make them consistent.
        runid_recalculated
        % if set to true, runid map is recalculated regardless of the
        % consistency of the run_id(s) conteined in expdatas
        force_runid_recalculation;
    end
    properties(Constant,Access=private)
        fields_to_save_ = {'detector_arrays','instruments','samples','expdata'};
    end


    methods
        function obj = Experiment(varargin)
            % Create a new Experiment object.
            %
            %   obj = Experiment()
            %   obj = Experiment(special_struct)
            %   obj = Experiment(detector_array[s], instrument[s], sample[s],expdata[s])
            %   obj = Experiment(___,force_runid_recalculation )
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
            %
            %   The number of elements in instrument sample and expdata
            %   containers have to be equal
            % Optional:
            % force_runid_recalculation -- if true,recalculate runid map
            %              regardless of the consistency of the runid-s
            %              stored in expdata property.
            %
            %
            % Returns:
            % obj       -- initialized instance of the Experiment object.
            % runid_map -- Temporary property. The map, which makes
            %              correspondence between IX_experiment run_id and
            %              the position of particular IX_experiment (and other
            %              particular objects, i.e. sample and instrument)
            %              in the container.
            % TODO: runid_map will be internal property of Experiment
            %             object
            %
            % Each argument can be a single object or array of objects.
            if nargin == 0
                return;
            end
            if isnumeric(varargin{end}) || islogical(varargin{end})
                argi = varargin(1:end-1);
                obj.force_runid_recalculation = varargin{end};
            else
                argi = varargin;
            end
            if isempty(argi)
                return;
            end

            S = argi{1};
            narg = numel(argi);
            if narg  == 1
                if isa(S,'Experiment')
                    obj = S;
                    return;
                elseif isstruct(S)
                    if isfield(S,'efix') && isfield(S,'emode')
                        obj = build_from_old_headers_(obj,{S});
                    elseif isempty(fieldnames(S))
                        obj = Experiment(); % empty object
                    else
                        obj =Experiment.from_struct(S);
                    end
                elseif iscell(S)
                    obj = build_from_old_headers_(obj,S);
                else
                    error('HORACE:Experiment:invalid_argument',...
                        'unrecognised Experiment constructor type: %s',class(varargin{1}));
                end
            else
                flds = obj.saveableFields();
                if narg > numel(flds)
                    error('HORACE:Experiment:invalid_argument',...
                        'Experiment constructor accepts only %d input arguments. Actually it has %d inputs',...
                        numel(flds),narg);
                end
                input = cell2struct(argi,flds(1:narg),2);
                obj = obj.from_bare_struct(input);
            end
            [ok,mess,obj] = obj.check_combo_arg();
            if ~ok
                error('HORACE:Experiment:invalid_argument',mess);
            end
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
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        function obj=set.instruments(obj, val)
            if isempty(val)
                obj.instruments_ = {IX_null_inst()};
                return;
            elseif isa(val,'IX_inst')
                val = num2cell(val);
            end
            %
            if ~IX_inst.cell_is_class(val)
                error('HORACE:Experiment:invalid_argument', ...
                    'Instruments must be a cell array or array of instruments. In fact it is %s',...
                    class(val));
            else
                obj.instruments_ = val(:)';
            end
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function val=get.samples(obj)
            val=obj.samples_;
        end
        function obj=set.samples(obj, val)
            if isempty(val)
                obj.samples_ = {IX_null_sample()};
                return
            elseif ~iscell(val)
                val = num2cell(val);
            end

            if ~IX_samp.cell_is_class(val)
                error('HORACE:Experiment:invalid_argument', ...
                    'Samples must be a cellarray or array of IX_samp objects . In fact it is %s',...
                    class(val));
            else
                obj.samples_ = val(:)';
            end
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function val=get.expdata(obj)
            val=obj.expdata_;
        end
        function obj=set.expdata(obj, val)
            if ~isa(val,'IX_experiment') && all(isempty(val)) % empty IX_experiment may have shape
                val = IX_experiment();
            end
            if isa(val,'IX_experiment')
                if size(val,1) > 1 % do rows, they are more compact at serialization
                    val = reshape(val,1,numel(val));
                end
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Sample must be one or an array of IX_experiment objects. Actually it is: %s',...
                    class(v))
            end
            obj.expdata_ = val(:)';
            obj = obj.check_and_calculate_runid_map();
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function map = get.runid_map(obj)
            map = obj.runid_map_;
        end
        function is = get.runid_recalculated(obj)
            is  = obj.runid_recalculated_;
        end
        %
        function is = get.force_runid_recalculation(obj)
            is = obj.force_runid_recalculation_;
        end
        function obj = set.force_runid_recalculation(obj,val)
            if ~(isnumeric(val) || islogical(val))
                error('HORACE:Experiment:invalid_argument',...
                    'force_runid_recalculatrion input to set can be logical value or value convertable to logical value. Actually its type is %s', ...
                    class(val));
            end
            if isempty(val)
                val = false;
            end
            obj.force_runid_recalculation_ = logical(val);
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
            % return experiment info, which corresponds to appropriate
            % experiment indexes
            % Inputs:
            % obj -- the instance of the experiment
            % ind -- array of the indexes, to select experiments for
            %
            % Returns:
            % exp -- the Experiment class instance, containing information,
            %        correspoinding to the run indexes provided as input.
            exp = get_experiments_(obj,ind);
        end
        %
        function [subexper,runid_map] = get_subobj(obj,indexes,...
                runid_map,modify_runid)
            % return Experiment object, containing subset of experiments,
            % requested by the method.
            %
            % Input:
            % indexes   -- the array of indexes, which identify particular
            %              experiments to include asof the runs to contribute
            %              into the final subset of experiment
            % Optional:
            % runid_map -- if provided, the map run_id->index, containing
            %              information about run_id to select as the final
            %              experiment info. If it is provided, first
            %              argument is treated as runid-s, which are the
            %              keys of the runid_map rather then direct indexes
            %              of the map.
            %
            %              TODO: this map will be part of the Experiment
            %              object, so the argument will be removed in a
            %              future.
            % modify_runid- if true, change run_id(s) present as the
            %               indexes of the runds into the indexes of the
            %               pixels, really present in PixelData array
            % Returns:
            % subexper  -- the Experiment object, containing information
            %              about runs defined by indexes and optionally,
            %              runid_map.
            % runid_map -- the map, which associates runindexes with the
            %              numbers of the headers in the subexper object
            %
            %              TODO: this map will be part of the Experiment
            %              object, so the argument will be removed in a
            %              future.
            %
            if ~exist('runid_map','var')
                runid_map = [];
            end
            if ~exist('modify_runid','var')
                modify_runid = false;
            end
            [subexper,runid_map] = get_subobj_(obj,indexes,runid_map,modify_runid);
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
            if iscell(samp)
                samp = samp{1};
            end
            if ~isempty(header_num)
                oldhdrs = obj.expdata_(header_num).convert_to_binfile_header( ...
                    samp.alatt,samp.angdeg,nomangle);
            else
                nruns = obj.n_runs;
                oldhdrs = cell(nruns,1);
                for i=1:nruns
                    oldhdrs{i} = obj.expdata_(i).convert_to_binfile_header( ...
                        samp.alatt,samp.angdeg,nomangle);
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
        function [ok,mess,obj] = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Overload to obtain information about the validity of
            % interdependent properties and information about issues with
            % interdependent properties
            ok = true;
            mess = '';
            nruns = numel(obj.expdata_);
            if numel(obj.instruments_) ~= nruns
                ok = false;
                mess = sprintf(...
                    'Number of instruments: %d is not equal to number of runs: %d; ',...
                    numel(obj.instruments_),nruns);
            end
            if numel(obj.samples_) ~= nruns 
                ok = false;
                mess = sprintf(...
                    '%s Number of samples %d is not equal to number of runs: %d; ',...
                    mess,numel(obj.samples_),nruns);
            end
            obj.isvalid_ = ok;
        end
        function obj = check_and_calculate_runid_map(obj,varargin)
            % Builds runid_map and sets  runid_map_ and runid_recalculated_
            % properties using contents of expdata property.
            %
            % Optional inputs:
            % force_runid_recalculation -- If present and true, recalculate
            %                   runid regardless of consistency of runid
            %                   stored in the expdata.
            if nargin == 1
                force_runid_recalc  = obj.force_runid_recalculation_;
            else
                obj.force_runid_recalculation = varargin{1};
                force_runid_recalc   = obj.force_runid_recalculation;
            end
            obj = check_and_calculate_runid_map_(obj,force_runid_recalc);
        end

    end

    methods(Access=protected)
        function is = check_validity(obj)
            is = obj.isvalid_;
        end

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
    end
    methods(Static)
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
            for i=1:n_contrib
                for j=1:exp_cellarray{i}.n_runs
                    instr{ic}  = exp_cellarray{i}.instruments{j};
                    sampl{ic}  = exp_cellarray{i}.samples{j};
                    expinfo(ic)= exp_cellarray{i}.expdata(j);
                    ic = ic+1;
                end
            end
            exp = Experiment([], instr, sampl,expinfo);
        end
    end
    %======================================================================
end


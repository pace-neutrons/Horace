classdef Experiment < serializable
    %EXPERIMENT Container object for all data describing the Experiment

    properties(Access=private)
        instruments_ = {}; %IX_inst.empty;
        detector_arrays_ = []
        samples_ = {}; % IX_samp.empty;
        expdata_ = IX_experiment();
    end

    properties (Dependent)
        n_runs;  % return the number of runs, this class contains
        % Mirrors of private properties
        instruments
        detector_arrays
        samples
        expdata
    end
    properties(Dependent,Hidden)
        % property providing compatibility with old header interface
        header
    end
    properties(Constant,Access=private)
        fields_to_save_ = {'instruments','detector_arrays','samples','expdata'};
    end


    methods
        function obj = Experiment(varargin)
            % Create a new Experiment object.
            %
            %   obj = Experiment()
            %   obj = Experiment(detector_array[s], instrument[s], sample[s])
            %
            % Required:
            %   detector_array  Detector array (IX_detector_array objects)
            %   instrument      Instrument (Concrete class inheriting IX_inst)
            %   sample          Sample data (IX_sample object)
            %
            % Each argument can be a single object or array of objects.
            if nargin == 0
                return;
            end

            S = varargin{1};
            if nargin==1
                if isa(S,'Experiment')
                    obj = S;
                    return;
                elseif isstruct(S)
                    obj =Experiment.loadobj(S);
                elseif iscell(S)
                    obj = build_from_old_headers_(obj,S);
                else
                    error('HORACE:Experiment:invalid_argument',...
                        'unrecognised Experiment constructor type: %s',class(varargin{1}));
                end
            elseif nargin==3
                obj.detector_arrays = S;
                if isempty(varargin{2})
                    % do nothing, instruments is already empty on construction
                else
                    instruments = varargin{2};
                    if ~iscell(instruments)
                        instruments = num2cell(instruments);
                    end
                    if IX_inst.cell_is_class(instruments)
                        obj.instruments =  instruments;
                    else
                        error('HORACE:Experiment:invalid_argument',...
                            'bad type for instruments on construction');
                    end
                end
                if isempty(varargin{3})
                    % do nothing, samples is already empty on construction
                else
                    samples = varargin{3};
                    if ~iscell(samples)
                        samples = num2cell(samples);
                    end
                    if IX_samp.cell_is_class(samples)
                        obj.samples = samples;
                    else
                        error('HORACE:Experiment:invalid_argument',...
                            'bad type for samples on construction');
                    end
                end
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Must give all of detector_array, instrument and sample or the structure representing them')
            end
        end
        %
        function oldhdrs = convert_to_old_headers(obj,header_num)
            % convert Experiment into the structure suitable to be
            % stored in old binary sqw files (up to version 3.xxx)
            %
            % this structure is also used in number of places of the old
            % code where, e.g., structure sorting is implemented but this
            % usage is deprecated and will be removed in a future.
            %
            samp = obj.get_unique_samples();
            if iscell(samp)
                samp = samp{1};
            end
            if nargin == 2
                oldhdrs = obj.expdata_(header_num).to_bare_struct();
                oldhdrs.alatt = samp.alatt;
                oldhdrs.angdeg = samp.angdeg;
                oldhdrs.instrument = struct();
                oldhdrs.sample = struct();
            else
                nruns = obj.n_runs;
                oldhdrs = cell(nruns,1);
                for i=1:nruns
                    old_hdr = obj.expdata_(i).to_bare_struct();
                    old_hdr.alatt = samp.alatt;
                    old_hdr.angdeg = samp.angdeg;

                    old_hdr.instrument = struct();
                    old_hdr.sample = struct();
                    oldhdrs{i} = old_hdr;
                end
            end
        end
        %
        function val=get.detector_arrays(obj)
            val=obj.detector_arrays_;
        end
        %
        function obj=set.detector_arrays(obj, val)
            if isa(val,'IX_detector_array') || isempty(val)
                obj.detector_arrays_ = val;
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Detector array must be one or an array of IX_detector_array object')
            end
        end
        %
        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        %
        function obj=set.instruments(obj, val)
            if ~iscell(val)
                if isa(val,'IX_inst')
                    val = num2cell(val);
                else
                    error('HORACE:Experiment:invalid_argument', ...
                        'Instruments must be a cell array. In fact it is %s',...
                        class(val));
                end
            end
            if isempty(val)
                obj.instruments_ = {};
            elseif ~IX_inst.cell_is_class(val)
                error('HORACE:Experiment:invalid_argument', ...
                    'Instruments cell must be all of base class IX_inst.');
            else
                obj.instruments_ = val;
            end
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
        function expi = get_aver_experiment(obj)
            % some, presumably average, run-data. Naive implementation,
            % all data are the same
            expi = obj.expdata(1);
        end

        function val=get.samples(obj)
            val=obj.samples_;
        end
        %
        function obj=set.samples(obj, val)
            if ~iscell(val)
                if isa(val,'IX_samp')
                    val = num2cell(val);
                else
                    error('HORACE:Experiment:invalid_argument', ...
                        'Samples must be a cell array. In fact it is %s',...
                        class(val));
                end
            end
            if isempty(val)
                obj.samples_ = {};
            elseif ~IX_samp.cell_is_class(val)
                error('HORACE:Experiment:invalid_argument', ...
                    'Instruments cell must be all of base class IX_samp.');
            else
                obj.samples_ = val;
            end
        end
        %
        function val=get.expdata(obj)
            val=obj.expdata_;
        end
        %
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
            obj.expdata_ = val;
        end
        %
        function nr = get.n_runs(obj)
            nr = numel(obj.expdata_);
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
        function flds = indepFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = Experiment.fields_to_save_;
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
            instr = obj.instruments_(1);
        end
        %
        function samp = get_unique_samples(obj)
            % compatibility fields with old binary file formats
            % TODO: needs proper implementation
            samp = obj.samples_(1);
        end
        %
        function head = get.header(obj)
            head = obj.convert_to_old_headers();
            head = [head{:}];
            head = rmfield(head,{'instrument','sample'});
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
            instr  = repmat({IX_null_inst()},1,n_tot );
            sampl  = repmat({IX_null_sample()},1,n_tot);
            expinfo= repmat(IX_experiment(),1,n_tot);
            ic = 1;
            for i=1:n_contrib
                for j=1:exp_cellarray{i}.n_runs
                    instr{i} = exp_cellarray{i}.instruments{j};
                    sampl{ic} = exp_cellarray{i}.samples{j};
                    expinfo(ic) =exp_cellarray{i}.expdata(j);
                end
                ic = ic+1;
            end
            exp = Experiment([], instr, sampl);
            exp.expdata = expinfo;
            %             if iscell(exp_cellarray)
            %                 for i=1:n_contrib
            %                     [exp,n_combined] = exp.add_contents(exp_cellarray{i});
            %                 end
            %             else
            %                 for i=1:n_contrib
            %                     [exp,n_combined] = exp.add_contents(exp_cellarray(i));
            %                 end
            %             end
        end
    end
    %======================================================================
end


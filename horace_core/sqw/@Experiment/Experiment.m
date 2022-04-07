classdef Experiment < serializable
    %EXPERIMENT Container object for all data describing the Experiment

    properties(Access=private)
        instruments_ = {IX_null_inst()};
        detector_arrays_ = []
        samples_ = {IX_null_sample()}; % IX_samp.empty;
        expdata_ = IX_experiment();

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
    end
    properties(Dependent,Hidden)
        % property providing compatibility with old header interface
        header
    end
    properties(Constant,Access=private)
        fields_to_save_ = {'detector_arrays','instruments','samples','expdata'};
    end


    methods
        function obj = Experiment(varargin)
            % Create a new Experiment object.
            %
            %   obj = Experiment()
            %   obj = Experiment(detector_array[s], instrument[s], sample[s],expdata[s])
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
                    if isfield(S,'efix') && isfield(S,'emode')
                        obj = build_from_old_headers_(obj,{S});                        
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
                narg = nargin;
                if narg > numel(flds)
                    error('HORACE:Experiment:invalid_argument',...
                        'Experiment constructor accepts only %d input arguments. Actually it has %d inputs',...
                        numel(flds),narg);
                end
                input = cell2struct(varargin,flds(1:narg),2);
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
                obj.instruments_ = {};
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
                obj.instruments_ = val(:);
            end
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function val=get.samples(obj)
            val=obj.samples_;
        end
        function obj=set.samples(obj, val)
            if isempty(val)
                obj.samples_ = {};
                return
            elseif ~iscell(val)
                val = num2cell(val);
            end

            if ~IX_samp.cell_is_class(val)
                error('HORACE:Experiment:invalid_argument', ...
                    'Samples must be a cellarray or array of IX_samp objects . In fact it is %s',...
                    class(val));
            else
                obj.samples_ = val(:);
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
            obj.expdata_ = val;
            [~,~,obj] = check_combo_arg(obj);
        end
        %------------------------------------------------------------------
        function nr = get.n_runs(obj)
            nr = numel(obj.expdata_);
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
        function [subexper,runid_map] = get_subobj(obj,indexes,runid_map)
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
            [subexper,runid_map] = get_subobj_(obj,indexes,runid_map);
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
            if numel(obj.instruments_) ~= obj.n_runs
                ok = false;
                mess = sprintf(...
                    'Number of instruments: %d is not equal to number of runs: %d; ',...
                    numel(obj.instruments_),obj.n_runs);
            end
            if numel(obj.samples_) ~= obj.n_runs
                ok = false;
                mess = sprintf(...
                    '%s Number of samples %d is not equal to number of runs: %d; ',...
                    mess,numel(obj.samples_),obj.n_runs);
            end
            obj.isvalid_ = ok;
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


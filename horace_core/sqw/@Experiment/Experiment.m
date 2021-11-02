classdef Experiment < serializable
    %EXPERIMENT Container object for all data describing the Experiment
    
    properties(Access=private)
        instruments_ = IX_inst();
        detector_arrays_ = []
        samples_ = IX_samp();
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
                    % Assume trying to initialise from a structure array of properties
                    % Actually this is the case where the header has just one
                    % run in it. It may be simpler to convert the header to a
                    % cell of one - but leaving this for the moment,
                    if isfield(S,'version')
                        obj =Experiment.loadobj(S);
                    elseif isfield(varargin{1},'serial_name')
                        obj =serializable.from_struct(S);
                    else
                        if isfield(S,'filename') && isfield(S,'efix') % this is probably old single header
                            obj = build_from_old_headers_(obj,{S});
                        else
                            obj =from_class_struct(obj,S);
                        end
                    end
                elseif iscell(S)
                    obj = build_from_old_headers_(obj,S);
                else
                    error('HORACE:Experiment:invalid_argument',...
                        'unrecoginzed Experiment constructor type: %s',class(varargin{1}));
                end
            elseif nargin==3
                obj.detector_arrays = S;
                if isa(varargin{2}, 'IX_inst')
                    obj.instruments =  varargin{2};
                elseif isempty(varargin{2})
                    % do nothing, instruments is already empty on
                    % construction
                else
                    error('HORACE:Experiment:invalid_argument',...
                        'bad type for instruments on construction');
                end
                if isa(varargin{3}, 'IX_samp')
                    obj.samples = varargin{3};
                elseif isempty(varargin{3})
                    % do nothing, samples is already empty on construction
                else
                    error('HORACE:Experiment:invalid_argument',...
                        'bad type for samples on construction');
                end
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Must give all of detector_array, instrument and sample or the structure representing them')
            end
        end
        %
        function oldhdrs = convert_to_old_headers(obj,header_num)
            % convert Experiment into the old header structure, initially
            % stored within binary files
            samp = obj.get_unique_samples();
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
            if ~isa(val,'IX_inst') && all(isempty(val)) % empty IX_inst may have a shape 
                % but nice to clear sample by providing empty string
                val = IX_inst();                
            end
            
            if isa(val,'IX_inst')
                if size(val,1) > 1
                    val = reshape(val,1,numel(val));
                end
                obj.instruments_ = val;
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Instruments must be one or an array of IX_inst objects. In fact it is %s',...
                    class(val))
            end            
        end
        %
        function is = is_same_ebins(obj)
            % return true if all energy bins of all experiments are the
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
            % some, presumably average, experiment data
            expi = obj.expdata(1);
        end
        
        function val=get.samples(obj)
            val=obj.samples_;
        end
        %
        function obj=set.samples(obj, val)
            if ~isa(val,'IX_samp') && all(isempty(val))  % empty IX_sample may have a shape 
                % but nice to clear sample by providing empty string
                val = IX_samp();                
            end
            
            if isa(val,'IX_samp')
                if size(val,1) > 1
                    val = reshape(val,1,numel(val));
                end
                obj.samples_ = val;
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Sample must be one or an array of IX_samp objects')
            end
        end
        %
        function val=get.expdata(obj)
            val=obj.expdata_;
        end
        %
        function obj=set.expdata(obj, val)
            if ~isa(val,'IX_experiment') && isempty(val)  % empty IX_experiment may have shape
                val = IX_experiment();                
            end
            if isa(val,'IX_experiment')
                if size(val,1) > 1 % do rows, they are more compact at serialization
                    val = reshape(val,1,numel(val));
                end
            else
                error('HORACE:Experiment:invalid_argument', ...
                    'Sample must be one or an array of IX_experiment objects')
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
        function avh = header_av(obj)
            % very crude implementation for the header, average over all
            % runs.
            if isempty(obj.expdata)
                avh = [];
            else
                avh = obj.expdata_(1);
            end
        end
        %
        function instr = get_unique_instruments(obj)
            % compartibility fields with old binary file formats
            instr = obj.instruments_(1);
        end
        %
        function samp = get_unique_samples(obj)
            % compartibility fields with old binary file formats
            %
            samp = obj.samples_(1);
        end
        % GEN_SQW interface
        %------------------------------------------------------------------
        function [obj,nelements] = add_contents(obj,other_exper)
            % add contents of the other_exper object to the contetns of the
            % current experiment
            %
            % TODO: do proper optiomization on the way, avoid copying the
            % same information.
            n_exisiting_inst = sum(~isempty(obj.instruments));
            n_exisiting_samp = sum(~isempty(obj.samples));
            n_existing_expi = sum(~isempty(obj.expdata));
            
            [obj,n_added_inst] = check_and_copy_contents_(obj,other_exper.instruments(),'instruments_');
            [obj,n_added_samp] = check_and_copy_contents_(obj,other_exper.samples(),'samples_');
            [obj,n_added_expi] = check_and_copy_contents_(obj,other_exper.expdata(),'expdata_');
            
            nelements = max([n_exisiting_inst+n_added_inst,...
                n_exisiting_samp+n_added_samp,n_existing_expi+n_added_expi]);
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
            % saveable class
            obj = Experiment();
            obj = loadobj@serializable(S,obj);
        end
        function [exp,nspe] = combine_experiments(exp_cellarray,allow_equal_headers,drop_subzone_headers)
            % take cellarray of experiments (e.g., generated from each runfile build
            % during gen_sqw generation)
            % and combine then together into single Experiment info class
            %
            %TODO: Do proper optinization on the way. See sqw_header.header_combine(header,allow_equal_headers,drop_subzone_headers)
            %TODO: use allow_equal_headers,drop_subzone_headers variables
            %      appropriately
            %TODO: repeat at least the logic within sqw_header helper class
            n_contrib = numel(exp_cellarray);
            nspe = zeros(n_contrib,1);
            for i=1:n_contrib
                nspe(i) = exp_cellarray{i}.n_runs;
            end
            n_tot = sum(nspe);
            instr  = repmat(IX_inst(),1,n_tot );
            sampl  = repmat(IX_samp(),1,n_tot);
            expinfo= repmat(IX_experiment(),1,n_tot);
            ic = 1;
            for i=1:n_contrib
                for j=1:exp_cellarray{i}.n_runs
                    instr(ic) = exp_cellarray{i}.instruments(j);
                    sampl(ic) = exp_cellarray{i}.samples(j);  
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


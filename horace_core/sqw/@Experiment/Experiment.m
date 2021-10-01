classdef Experiment
    %EXPERIMENT Container object for all data describing the Experiment
    
    properties(Access=private)
        class_version_ = 1;
        instruments_ = IX_inst.empty;
        detector_arrays_ = []
        samples_ = IX_samp.empty;
        expdata_ = IX_experiment.empty;
    end
    
    properties (Dependent)
        % Mirrors of private properties
        instruments
        detector_arrays
        samples
        expdata
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
            
            if nargin==1 && isa(varargin{1},'Experiment')
                obj = varargin{1};
                return;
            end

            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                % Actually this is the case where the header has just one
                % run in it. It may be simpler to convert the header to a
                % cell of one - but leaving this for the moment,
                
                %obj = IX_fermi_chopper.loadobj(varargin{1});
                alatt = varargin{1}.alatt;
                angdeg = varargin{1}.angdeg;
                if isstruct(varargin{1}.instrument) && isempty(fieldnames(varargin{1}.instrument))
                    % as the instrument struct is empty, create a null
                    % instrument to represent it
                    obj.instruments_(end+1) = IX_null_inst();
                elseif isa(varargin{1}.instrument,'IX_inst')
                    % hoping that the IX_inst is in fact a subclass
                    obj.instruments_(end+1) = varargin{1}.instrument;
                elseif isstruct(varargin{1}.instrument)
                    if isfield(varargin{1}.instrument,'fermi_chopper') && ...
                       isa(varargin{1}.instrument.fermi_chopper,'IX_fermi_chopper')
                        obj.instruments_(end+1) = IX_inst_DGfermi(varargin{1}.instrument.moderator, ...
                                                                  varargin{1}.instrument.aperture,  ...
                                                                  varargin{1}.instrument.fermi_chopper);
                    else
                        % where this instrument is probably a DGdisk which
                        % actually is implemented but may be somethig else
                        error("Horace:Experiment:this instrument not implemented yet");
                    end
                end
                if isstruct(varargin{1}.sample) && isempty(fieldnames(varargin{1}.sample))
                    try
                    ixns = IX_null_sample();
                    ixns.alatt = alatt;
                    ixns.angdeg = angdeg;
                    obj.samples_(end+1) = ixns;
                    catch ME
                        error("TT");
                    end
                else
                    ixs = varargin{1}.sample;
                    ixs.alatt = alatt;
                    ixs.angdeg = angdeg;
                    obj.samples_(end+1) = ixs;
                end
                filename = varargin{1}.filename;
                filepath = varargin{1}.filepath;
                cu = varargin{1}.cu;
                cv = varargin{1}.cv;
                efix = varargin{1}.efix;
                emode = varargin{1}.emode;
                psi = varargin{1}.psi;
                omega = varargin{1}.omega;
                dpsi = varargin{1}.dpsi;
                gl = varargin{1}.gl;
                gs = varargin{1}.gs;
                en = varargin{1}.en;
                uoffset = varargin{1}.uoffset;
                u_to_rlu = varargin{1}.u_to_rlu;
                ulen = varargin{1}.ulen;
                ulabel = varargin{1}.ulabel;
                obj.expdata_(end+1) = IX_experiment(filename, filepath, efix,emode,cu,cv,psi,omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,ulabel);
            elseif nargin==1 && iscell(varargin{1})
                % in this case the header (which is what varargin{1} is in
                % this case) is a cell of runs. Consequently we run over
                % the runs in the cell doing just what we did to one run
                % header in the if block above
                headers = varargin{1};
                for i=1:numel(headers)
                    hdr = headers{i};
                    alatt = hdr.alatt;
                    angdeg = hdr.angdeg;
                    if isstruct(hdr.instrument)
                        if isempty(fieldnames(hdr.instrument))
                            try
                            obj.instruments_(end+1) = IX_null_inst();
                            catch ME
                                error("T");
                            end
                        elseif isfield(hdr.instrument,'fermi_chopper')
                            ins = hdr.instrument;
                            hdr.instrument = IX_inst_DGfermi(ins.moderator, ...
                                                             ins.aperture,  ...
                                                             ins.fermi_chopper);
                            obj.instruments_(end+1) = hdr.instrument;
                        else
                            error('HORACE:Experiment-ctor','unknown struct');
                        end
                    else
                        obj.instruments_(end+1) = hdr.instrument;
                    end
                    if isstruct(hdr.sample) && isempty(fieldnames(hdr.sample))
                        try
                        ixns = IX_null_sample();
                        ixns.alatt = alatt;
                        ixns.angdeg = angdeg;
                        obj.samples_(end+1) = ixns;
                        catch ME
                            error("TT");
                        end
                    else
                        ixs = hdr.sample;
                        ixs.alatt = alatt;
                        ixs.angdeg = angdeg;
                        obj.samples_(end+1) = ixs;
                    end
                    filename = hdr.filename;
                    filepath = hdr.filepath;
                    cu = hdr.cu;
                    cv = hdr.cv;
                    efix = hdr.efix;
                    emode = hdr.emode;
                    psi = hdr.psi;
                    omega = hdr.omega;
                    dpsi = hdr.dpsi;
                    gl = hdr.gl;
                    gs = hdr.gs;
                    en = hdr.en;
                    uoffset = hdr.uoffset;
                    u_to_rlu = hdr.u_to_rlu;
                    ulen = hdr.ulen;
                    ulabel = hdr.ulabel;
                    obj.expdata_(end+1) = IX_experiment(filename, filepath, efix,emode,cu,cv,psi,omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,ulabel);

                end
            elseif nargin==3
                obj.detector_arrays_ = varargin{1};
                obj.instruments_ =  varargin{2};
                obj.samples_ = varargin{3};
            else
                error('EXPERIMENT:invalid_argument', ...
                    'Must give all of detector_array, instrument and sample')
            end
        end
        
        function oldhdrs = convert_to_old_headers(obj)
            nruns = numel(obj.expdata);
            oldhdrs = cell(nruns,1);
            edflds = fields(obj.expdata);
            for i=1:nruns
                oldhdr = struct();
                for j=1:numel(edflds)
                    oldhdr.(edflds{j}) = obj.expdata(i).(edflds{j});
                end
                oldhdr.alatt = obj.samples(i).alatt;
                oldhdr.angdeg = obj.samples(i).angdeg;
                if isa(obj.instruments(i),'IX_null_inst')
                    oldhdr.instrument = struct();
                else
                    oldhdr.instrument = obj.instruments(i);
                end
                if isa(obj.samples(i),'IX_null_sample')
                    oldhdr.sample = struct();
                    oldhdr.alatt = obj.samples(i).alatt;
                    oldhdr.angdeg = obj.samples(i).angdeg;
                else
                    oldhdr.sample = obj.samples(i);
                end
                oldhdr.alatt = obj.samples(i).alatt;
                oldhdr.angdeg = obj.samples(i).angdeg;
                oldhdrs{i} = oldhdr;
            end
        end

        function obj=set.detector_arrays_(obj,val)
            if isa(val,'IX_detector_array') || isempty(val)
                obj.detector_arrays_ = val;
            else
                error('EXPERIMENT:invalid_argument', ...
                    'Detector array must be one or an array of IX_detector_array object')
            end
        end
        
        function obj=set.instruments_(obj,val)
            if isa(val,'IX_inst') || isempty(val)
                obj.instruments_ = val;
            else
                error('EXPERIMENT:invalid_argument', ...
                    'Instruments must be one or an array of IX_inst objects')
            end
        end
        
        function obj=set.samples_(obj,val)
            if isa(val,'IX_samp') || isempty(val)
                obj.samples_ = val;
            else
                error('EXPERIMENT:invalid_argument', ...
                    'Sample must be one or an array of IX_sample or IX_null_sample objects')
            end
        end

        function val=get.detector_arrays(obj)
            val=obj.detector_arrays_;
        end
        function obj=set.detector_arrays(obj, val)
            obj.detector_arrays_ = val;
        end

        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        function obj=set.instruments(obj, val)
            obj.instruments_ = val;
        end

        function val=get.samples(obj)
            val=obj.samples_;
        end
        function obj=set.samples(obj, val)
            obj.samples_ = val;
        end

        function val=get.expdata(obj)
            val=obj.expdata_;
        end
        function obj=set.expdata(obj, val)
            obj.expdata_ = val;
        end

        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            S = structIndep(obj);
        end
    end

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class

            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
    end
    %======================================================================
end


classdef IX_experiment < serializable
    %IX_EXPERIMENT

    properties(Dependent)
        filename; % name of the file which was the source of data for this
        %         % experiment
        filepath; % path where the experiment data were initially stored
        run_id    % the identifier, which uniquely defines this experiment
        %         % this indentifier is also stored within the PixelData,
        %         % providing connection between the particular pixel and
        %         % the experiment info

        en;  % array of all energy transfers, present in the experiment
    end

    properties
        efix = []
        emode=[]

        cu=[];
        cv=[];
        psi=[];
        omega=[];
        dpsi=[];
        gl=[];
        gs=[];
        uoffset=[];
        u_to_rlu=[];
        ulen=[];
        ulabel=[];
    end
    properties(Access=protected)
        filename_=''
        filepath_='';
        run_id_ = NaN;
        en_ = zeros(0,1);
    end
    properties(Constant,Access=private)
        % fields, which fully define public interface to the class
        fields_to_save_ = {'filename','filepath','run_id','efix','emode','cu',...
            'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
            'u_to_rlu','ulen','ulabel'};
    end
    methods
        function flds = saveableFields(~)
            flds = IX_experiment.fields_to_save_;
        end
        function ver  = classVersion(~)
            % return the version of the IX-experiment class
            ver = 2;
        end
        %------------------------------------------------------------------
        % ACCESSORS:
        function fn = get.filename(obj)
            fn = obj.filename_;
        end
        function obj = set.filename(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HERBERT:IX_experiment:invalid_argument',...
                    'filename can be only character array or string. It is %s',...
                    class(val))
            end
            obj.filename_ = val;
        end
        %
        function fn = get.filepath(obj)
            fn = obj.filepath_;
        end
        function obj = set.filepath(obj,val)
            if ~(ischar(val) || isstring(val))
                error('HERBERT:IX_experiment:invalid_argument',...
                    'filename can be only character array or string. It is %s',...
                    class(val))
            end
            obj.filepath_ = val;
        end
        %
        function id = get.run_id(obj)
            id =obj.run_id_;
        end
        function obj = set.run_id(obj,val)
            if ~isnumeric(val) || numel(val)>1
                error('HERBERT:IX_experiment:invalid_argument',...
                    'run_id can have only single numeric value. It is %s containing %d elements',...
                    class(val),numel(val))
            end
            obj.run_id_ = val;
        end
        function ids = get_run_ids(obj)
            % retrieve all run_ids, which may be present in the array of
            % rundata objects
            ind = 1:numel(obj);
            ids = arrayfun(@(in)(obj(in).run_id_),ind);
        end
        %
        function en = get.en(obj)
            en = obj.en_;
        end
        function obj = set.en(obj,val)
            if ~isnumeric(val)
                error('HERBERT:IX_experiment:invalid_argument',...
                    'energy transfers have to be array of numeric values. It is: %s',...
                    class(val));
            end
            obj.en_ = val(:);
        end
        %------------------------------------------------------------------
        % SQW_binfile_common methods related to saving to binfile and
        % run_id scrambling:
        function old_hdr = convert_to_binfile_header(obj,mode,arg1,arg2,nomangle)
            % convert to the header structure, to be stored in the old
            % binary files.
            %
            % Inputs:
            % Required:
            % obj   -- the experiment data header object to convert - 
            % mode  --
            %    = '-inst_samp' : the next 2 arguments are an instrument
            %                     and sample respectively
            %    = '-alatt_angdeg' : the next 2 arguments are the alatt and
            %                        angdeg values of the run respectively.
            %                        In this case a null instrument and
            %                        sample with these values are created
            %                        and used.
            % arg1  --
            %    = instrument to set if mode == '-inst_samp'
            %    = alatt -- lattice cell sizes (3x1 vector) if mode ==
            %               '-alatt_angdeg'
            % arg2  --
            %    = sample to set if node == '-inst_samp'
            %    = angdeg --lattice angles (3x1 vector) if mode ==
            %               '-alatt_angdeg'
            % Optional:
            % nomangle -- if false or absent, mangle (append to the end)
            %             file name with run_id (if one is defined)
            %
            % Outputs:
            % old_hdr  -- struct with the old-style header data
            %
            if ~exist('nomangle','var')
                nomangle = false;
            end
            old_hdr = obj.to_bare_struct();
            if ~isnan(old_hdr.run_id) && ~nomangle
                old_hdr.filename = sprintf('%s$id$%d',old_hdr.filename,old_hdr.run_id);
            end
            old_hdr = rmfield(old_hdr,'run_id');
            if strcmp( mode, '-inst_samp')
                old_hdr.instrument = arg1;
                old_hdr.sample     = arg2;
                old_hdr.alatt      = arg2.alatt;
                old_hdr.angdeg     = arg2.angdeg;
            elseif strcmp( mode, '-alatt_angdeg')
                old_hdr.instrument = IX_null_inst();
                old_hdr.sample = IX_null_sample('',arg1,arg2);
                old_hdr.alatt      = arg1;
                old_hdr.angdeg     = arg2;
            else
                error('HORACE:convert_to_binfile_header:invalid argument', ...
                      'mode arg is not -inst_samp or -alatt_angdeg');
            end
        end
        %------------------------------------------------------------------
        function is = isempty(obj)
            is = false(size(obj));
            flds = IX_experiment.fields_to_save_;
            for i=1:numel(obj)
                obj_i_empty = true;
                for j=1:numel(IX_experiment.fields_to_save_)
                    fld_val = obj(i).(flds{j});
                    if ~(isempty(fld_val) || (isnumeric(fld_val)&&isnan(fld_val)))
                        obj_i_empty= false;
                        break;
                    end
                end
                is(i) = obj_i_empty;
            end
        end
        function obj = IX_experiment(varargin)
            if nargin==0
                return
            end
            obj = obj.init(varargin{:});
        end

        function obj = init(obj,varargin)
            % Usage:
            %   obj = init(obj,filename, filepath, efix,emode,cu,cv,psi,...
            %               omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,...
            %               ulabel,run_id)
            %
            %   IX_EXPERIMENT Construct an instance of this class

            % the list of the fieldnames, which may appear in constructor
            % in the order they may appear in the constructor.
            flds = {'filename', 'filepath', 'efix','emode','cu',...
                'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
                'u_to_rlu','ulen','ulabel','run_id'};

            if nargin == 2
                input = varargin{1};
                if isa(input,'IX_experiment')
                    obj = input ;
                    return
                elseif isstruct(input)
                    % constructor
                    % The constructor parameters names in the order, then can
                    % appear in constructor
                    for i=1:numel(flds)
                        fld = flds{i};
                        if isfield(input,fld)
                            obj.(fld) = input.(fld);
                        end
                    end
                else
                    error('HERBERT:IX_experiment:invalid_argument',...
                        'Unrecognised single input argument of class %s',...
                        class(input));
                end
            elseif nargin > 2
                % list of crude validators, checking the type of all input
                % parameters for constructor. Mainly used to identify the
                % end of positional arguments and the beginning of the
                % key-value pairs. The accurate validation should occur on
                % setters.
                [obj,remains] = set_positional_and_key_val_arguments(obj,...
                    flds,varargin{:});
                if ~isempty(remains)
                    error('HERBERT:IX_experiment:invalid_argument',...
                        'Non-recognized extra-arguments provided as input for constructor for IX_experiemt')
                end
            else
                error('HERBERT:IX_experiment:invalid_argument',...
                    'unrecognised number of input arguments: %d',nargin);
            end
            if isempty(obj)
                error('HERBERT:IX_experiment:invalid_argument',...
                    'initialized IX_experiment can not be empty')
            end
        end
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % recover the object from old structure
            if isfield(inputs,'version') && inputs.version == 1
                for i=1:numel(inputs)
                    inputs(i).run_id = NaN;
                end
                inputs.version = 2;
                obj = obj.from_struct(inputs);
                return;
            end
            obj = from_old_struct@serializable(obj,inputs);
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class, necessary to load data from old structures
            % only
            obj = IX_experiment();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
        % SQW_binfile_common methods related to saving to binfile and
        % run_id scrambling:
        function [obj,alatt,angdeg] = build_from_binfile_header(inputs)
            % Inputs: the old header structure, stored in binfile
            old_fldnms = {'filename','filepath','efix','emode','cu',...
                'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
                'u_to_rlu','ulen','ulabel'};
            obj = IX_experiment();
            for i=1:numel(old_fldnms)
                obj.(old_fldnms{i}) = inputs.(old_fldnms{i});
            end
            alatt = inputs.alatt;
            angdeg = inputs.angdeg;
            [runid,filename] = rundata.extract_id_from_filename(inputs.filename);
            if ~isnan(runid)
                obj.run_id = runid;
                obj.filename = filename;
            end
        end
    end
end

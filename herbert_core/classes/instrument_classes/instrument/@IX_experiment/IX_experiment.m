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

        efix;
        en;  % array of all energy transfers, present in the experiment
        cu;
        cv;
    end
    properties(Dependent,Hidden)
        u_to_rlu;
    end

    properties
        emode=1
        psi=0;
        omega=0;
        dpsi=0;
        gl=0;
        gs=0;
        uoffset=[0,0,0,0];

        ulen=[];
        ulabel=[];
    end
    properties(Access=protected)
        filename_=''
        filepath_='';
        run_id_ = NaN;
        en_ = zeros(0,1);
        efix_ = [];
        cu_ = [1,0,0];
        cv_ = [0,1,0];
        u_to_rlu_ = eye(3);
    end
    properties(Access= private)
        % the hash used to compare IX_experiments for equality
        hash_valid_ = false;
        equality_hash_
    end
    methods
        function obj = IX_experiment(varargin)
            % IX_EXPERIMENT Construct an instance of this class
            if nargin==0
                return
            end
            obj = obj.init(varargin{:});
        end

        function obj = init(obj,varargin)
            % construcnt non-empty instance of this class
            % Usage:
            %   obj = init(obj,filename, filepath, efix,emode,cu,cv,psi,...
            %               omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,...
            %               ulabel,run_id)
            %
            obj = init_(obj,varargin{:});
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
            obj.filename_     = val;
            obj.hash_valid_  = false;
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
            obj.hash_valid_  = false;
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
        %
        function ef = get.efix(obj)
            ef = obj.efix_;
        end
        function obj = set.efix(obj,val)
            if val<=0
                error('HERBERT:IX_experiment:invalid_argument',...
                    'efix (incident energy) have to be positive')
            end
            obj.efix_ = val;
            obj.hash_valid_  = false;
        end
        %
        function mat = get.u_to_rlu(obj)
            mat = eye(4);
            mat(1:3,1:3) = obj.u_to_rlu_;
        end
        function obj = set.u_to_rlu(obj,val)
            if all(size(val)== [4,4])
                val = val(1:3,1:3);
            end
            if ~all(size(val) == [3,3])
                error('HERBERT:IX_experiment:invalid_argument',...
                    'input u_to_rlu matrix have to have size 3x3 or 4x4')
            end
            obj.u_to_rlu_ = val;
        end
        %
        function u = get.cu(obj)
            u = obj.cu_;
        end
        function obj = set.cu(obj,val)
            obj.cu_ = val(:)';
            obj.hash_valid_  = false;
        end
        %
        function v = get.cv(obj)
            v = obj.cv_;
        end
        function obj = set.cv(obj,val)
            obj.cv_ = val(:)';
            obj.hash_valid_  = false;
        end

    end
    %----------------------------------------------------------------------
    methods
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
            old_hdr = convert_to_binfile_header_(obj,mode,arg1,arg2,nomangle);
        end
        %
        function [hash,obj] = get_eq_hash(obj)
            % get hash used for comparison of IX_experiment objects against
            % equality while building sqw objects


            % list of properties which can not be all equal for
            % experiments to be diffetent
            %
            eq_properties = {'filename','cu','cv','efix', 'psi', 'omega', 'dpsi', 'gl', 'gs'};

            persistent engine;
            if isempty(engine)
                engine= java.security.MessageDigest.getInstance('MD5');
            end
            if obj.hash_valid_
                hash = obj.equality_hash_;
                return;
            end
            n_par = numel(eq_properties);
            contents = cell(1,n_par);
            for i=1:n_par
                contents{i} = typecast(obj.(eq_properties{i}),'uint8');
            end
            contents = [contents{:}];
            Engine.update(contents);
            hash = typecast(Engine.digest,'uint8');
            hash = char(hash');
            obj.equality_hash_ = hash;
            obj.hash_valid_ = true;
        end
        %

    end
    %----------------------------------------------------------------------
    % SERIALIZABLE interface
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

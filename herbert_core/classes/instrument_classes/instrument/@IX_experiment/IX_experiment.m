classdef IX_experiment < goniometer
    %IX_EXPERIMENT -- transient class which describes transformation of a
    %single run into Crystal Cartesian coordinate system during sqw file
    %generation
    %
    % Should be replaced by instr_proj in a future.

    properties(Dependent)
        filename; % name of the file which was the source of data for this
        %         % experiment
        filepath; % path where the experiment data were initially stored
        run_id    % the identifier, which uniquely defines this experiment
        %         % this indentifier is also stored within the PixelData,
        %         % providing connection between the particular pixel and
        %         % the experiment info

        emode;
        efix;
        en;  % array of all energy transfers, present in the experiment
        cu;
        cv;
    end
    properties(Dependent,Hidden)
        u_to_rlu;
    end

    properties(Hidden)
        uoffset=[0,0,0,0];

        ulen=[];
        ulabel=[];
    end
    properties(Access=protected)
        filename_=''
        filepath_='';
        run_id_ = NaN;
        emode_ = 1;
        en_ = zeros(0,1);
        efix_ = [];
        u_to_rlu_ = eye(3);
    end
    properties(Access= private)
        % the hash used to compare IX_experiments for equality
        hash_valid_ = false;
        comparison_hash_
    end
    methods
        function obj = IX_experiment(varargin)
            % IX_EXPERIMENT Construct an instance of this class
            obj.angular_units = 'deg';
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
        function mode = get.emode(obj)
            mode = obj.emode_;
        end
        function obj = set.emode(obj,val)
            if ~isnumeric(val) || ~isscalar(val) || val<0 || val>2
                error('HERBERT:IX_experiment:invalid_argument',...
                    'Transformation mode can be numeric scalar in range from 0 to 2.\n It is: %s',...
                    disp2str(val));
            end
            obj.emode_ = val;
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
            u = obj.u_;
        end
        function obj = set.cu(obj,val)
            obj.u = val;
            obj.hash_valid_  = false;
        end
        %
        function v = get.cv(obj)
            v = obj.v_;
        end
        function obj = set.cv(obj,val)
            obj.v = val;
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
        function [hash,obj] = get_neq_hash(obj)
            % get hash used for comparison of IX_experiment objects against
            % equality while building sqw objects

            % At present, we insist that the contributing spe data are distinct in that:
            %   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input

            if obj.hash_valid_
                hash = obj.comparison_hash_;
                return;
            end
            % list of properties which can not be all equal for
            % experiments to be diffetent
            neq_properties = {'filename','cu','cv','efix',...
                'psi', 'omega', 'dpsi', 'gl', 'gs'};

            hash = obj.get_comparison_hash(neq_properties);
            if nargout>1
                obj.comparison_hash_ =  hash;
                obj.hash_valid_      = true;
            end
        end
        %

    end
    methods(Access=protected)
        function [val,obj] = check_angular_val(obj,val)
            % main overloadable setter function for goniometer angles
            [val,obj] = check_angular_val@goniometer(obj,val);
            obj.hash_valid_ = false;
        end
        function hash = get_comparison_hash(obj,prop_list)
            % get hash to check partial set of properties for comparison
            % Inputs:
            % prop_list -- the list of properties to compare agains
            %
            persistent engine;
            if isempty(engine)
                engine= java.security.MessageDigest.getInstance('MD5');
            end

            n_par = numel(prop_list);
            contents = cell(1,n_par);
            for i=1:n_par
                contents{i} = obj.(prop_list{i});
                if istext(contents{i})
                    contents{i} = uint8(contents{i});
                elseif isnumeric(contents{i})
                    contents{i} = typecast(single(contents{i}),'uint8');
                else
                    contents{i} = typecast(contents{i},'uint8');
                end
            end
            contents = [contents{:}];
            engine.update(contents);
            hash = typecast(engine.digest,'uint8');
            hash = char(hash');
        end

    end
    %----------------------------------------------------------------------
    % SERIALIZABLE interface
    properties(Constant,Access=private)
        % fields, which fully define public interface to the class
        fields_to_save_ = {'filename','filepath','run_id','efix','emode','cu',...
            'cv','psi','omega','dpsi','gl','gs','en','uoffset','u_to_rlu'};
    end
    methods
        function flds = saveableFields(~)
            flds = IX_experiment.fields_to_save_;
        end
        function ver  = classVersion(~)
            % return the version of the IX-experiment class
            ver = 3;
        end
        % Do we need this? current usage of the hash is very restricted so
        % it is reasonable to calculate it on request only
        %         function obj = check_combo_arg(obj)
        %             % verify interdependent variables and the validity of the
        %             % obtained lattice object
        %             obj = check_combo_arg@goniometer(obj);
        %             if ~obj.hash_valid_
        %                 [~,obj.comparison_hash_] = obj.get_comparison_hash();
        %             end
        %         end

    end

    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % recover the object from old structure
            if isfield(inputs,'version')
                if inputs.version == 1
                    % version 1 does not contain run_id so it is set to NaN
                    % and recalculated on sqw object level
                    for i=1:numel(inputs)
                        inputs(i).run_id = NaN;
                    end
                    inputs.version = 2;
                    obj = obj.from_struct(inputs);
                    return;
                elseif inputs.version == 2
                    % version 3 does not save/load u_to_rlu, ulen, ulabel
                    % These fields are redundant for instr_proj and moved
                    % to sqw.data (DnD object)
                    inputs.version = 3;
                end
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
                'cv','psi','omega','dpsi','gl','gs','en','uoffset','u_to_rlu'};
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

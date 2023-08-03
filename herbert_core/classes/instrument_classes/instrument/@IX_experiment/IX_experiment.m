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
        %         % this identifier is also stored within the PixelData,
        %         % providing connection between the particular pixel and
        %         % the experiment info

        emode;
        efix;
        en;  % array of all energy transfers, present in the experiment

    end
    properties(Dependent,Hidden)
        % returns goniometer sliced from this object
        goniometer;
        % redundant property. Was inv(b_matrix). left for compatibility
        % with legacy alignment, as it multiplies it by alignment rotation
        % matrix
        u_to_rlu;
        cu % alternative names for u and v, used in goniometer class
        cv % and during gen_sqw generation
    end

    properties(Hidden)
        % Never usefully ised except loading from old files so candidates
        % for removal
        uoffset=[0,0,0,0];  % Always 0.
    end
    properties(Access=protected)
        filename_=''
        filepath_='';
        run_id_ = NaN;
        emode_ = 0;
        en_   = zeros(0,1);
        efix_ = 0;
        u_to_rlu_ = [];
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
            % construct non-empty instance of this class
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
            if val < 0
                error('HERBERT:IX_experiment:invalid_argument',...
                    'efix (incident energy) can not be negative')
            end
            obj.efix_ = val;
            obj.hash_valid_  = false;
        end
        %
        function mat = get.u_to_rlu(obj)
            if isempty(obj.u_to_rlu_)
                mat = [];
            else
                mat = eye(4);
                mat(1:3,1:3) = obj.u_to_rlu_;
            end
        end
        function obj = set.u_to_rlu(obj,val)
            if isempty(val)
                obj.u_to_rlu_ = [];
                return
            end
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
        function u=get.cu(obj)
            u = obj.u_;
        end
        function obj=set.cu(obj,u)
            obj = check_and_set_uv(obj,'u',u);
        end
        %
        function v=get.cv(obj)
            v = obj.v_;
        end
        function obj=set.cv(obj,v)
            obj = check_and_set_uv(obj,'v',v);
        end
        %
        function gon = get.goniometer(obj)
            str = obj.to_bare_struct();
            str.u = obj.cu;
            str.v = obj.cv;
            gon = goniometer(str);
        end
        function obj = set.goniometer(obj,val)
            if isstruct(val)
                if isfield(val,'cu')
                    val.u = val.cu;
                end
                if isfield(val,'cv')
                    val.v = val.cv;
                end
            elseif isa(val,'goniometer')
                val = val.to_bare_struct();
            else
                error('HORACE:IX_experiment:invalid_argument', ...
                    'Goniometer property accepts input as a class "goniometer" or a structure, convertable into goniometer.\n Provided %s', ...
                    class(val));
            end
            obj = obj.from_bare_struct(val);
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
        function [hash,obj] = get_comparison_hash(obj)
            % get hash used for comparison of IX_experiment objects against
            % equality while building sqw objects

            if obj.hash_valid_
                hash = obj.comparison_hash_;
                return;
            end
            persistent engine;
            if isempty(engine)
                engine= java.security.MessageDigest.getInstance('MD5');
            end

            % list of properties which can not be all equal for
            % experiments to be diffetent
            eq_properties = {'filename','cu','cv','efix',...
                'psi', 'omega', 'dpsi', 'gl', 'gs'};

            n_par = numel(eq_properties);
            contents = cell(1,n_par);
            for i=1:n_par
                contents{i} = obj.(eq_properties{i});
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
            obj.comparison_hash_ = hash;
            obj.hash_valid_ = true;
        end
        %

    end
    methods(Access=protected)
        function obj = check_and_set_uv(obj,name,val)
            % main overloadable setter for u and v
            obj = check_and_set_uv@goniometer(obj,name,val);
            obj.hash_valid_  = false;
        end

        function [val,obj] = check_angular_val(obj,val)
            % main overloadable setter function for goniometer angles
            [val,obj] = check_angular_val@goniometer(obj,val);
            obj.hash_valid_ = false;
        end

    end
    methods(Static)
        %------------------------------------------------------------------
        % SQW_binfile_common methods related to saving to old format binfile and
        % run_id scrambling:
        function [obj,alatt,angdeg] = build_from_binfile_header(inputs)
            % Inputs: the old header structure, stored in binfile
            old_fldnms = {'filename','filepath','efix','emode','en','cu',...
                'cv','psi','omega','dpsi','gl','gs','uoffset','u_to_rlu'};
            obj = IX_experiment();
            for i=1:numel(old_fldnms)
                obj.(old_fldnms{i}) = inputs.(old_fldnms{i});
            end
            % old headers always contain angular values in radians
            obj.angular_is_degree_ = false;
            alatt = inputs.alatt;
            angdeg = inputs.angdeg;
            [runid,filename] = rundata.extract_id_from_filename(inputs.filename);
            if ~isnan(runid)
                obj.run_id = runid;
                obj.filename = filename;
            end
            if all(abs(subdiag_elements(obj.u_to_rlu))<4*eps('single'))
                obj.u_to_rlu = [];
            end
        end
    end
    %----------------------------------------------------------------------
    % SERIALIZABLE interface
    properties(Constant,Access=private)
        % fields, which fully define IX_experiment part of the public
        % interface to the class
        fields_to_save_ = {'filename','filepath','run_id','efix','emode','en'};
    end
    methods
        function flds = saveableFields(obj)
            base= saveableFields@goniometer(obj);
            flds = [IX_experiment.fields_to_save_(:);base(:)];
            if ~isempty(obj(1).u_to_rlu_) || isnan(obj(1).run_id_) % run_id_ is NaN on non-initialized file
                flds = [flds(:);'u_to_rlu'];
            end
        end
        function flds = constructionFields(obj)
            base= constructionFields@goniometer(obj);
            flds = [IX_experiment.fields_to_save_(:);base(:)];

        end

        function ver  = classVersion(~)
            % return the version of the IX-experiment class
            ver = 3;
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained lattice object
            obj = check_combo_arg@goniometer(obj);
            if numel(obj.efix_) == 1 && obj.efix_ == 0 && obj.emode_ ~=0
                error('HERBERT:IX_experiment:invalid_argument',...
                    'efix (incident energy) can be 0 in elastic mode only. Emode=%d', ...
                    obj.emode_)

            end
            % Do we need this? current usage of the hash is very restricted so
            % it is reasonable to calculate it on request only
            %             if ~obj.hash_valid_
            %                 [~,obj.comparison_hash_] = obj.get_comparison_hash();
            %             end
        end
    end
    methods(Access=protected)
        function [S,obj] = convert_old_struct (obj, S, ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised

            if ver == 1
                % version 1 does not contain run_id so it is set to NaN
                % and recalculated on sqw object level
                S.run_id = NaN;

            end
            % version 3 does not save/load u_to_rlu, ulen, ulabel
            % These fields are redundant for instr_proj and moved
            % to sqw.data (DnD object)

            % Old IX_experiment data were containing angular values in
            % radians
            S.angular_is_degree = false;
            if isfield(S,'cu')
                S.u = S.cu;
            end
            if isfield(S,'cv')
                S.v = S.cv;
            end

            if isfield(S,'u_to_rlu')
                % support for legacy alignment:
                if ~any(subdiag_elements(S.u_to_rlu)>4*eps('single'))
                    S = rmfield(S,'u_to_rlu');
                else
                    obj.u_to_rlu = S.u_to_rlu;
                end
            end
        end

    end

    methods(Static)
        function obj = loadobj(S)
            % crafted loadobj method, calling generic method of
            % saveable class, necessary to load data from old structures
            % + support for legacy alignment matrix
            obj = IX_experiment();
            obj = loadobj@serializable(S,obj);

        end
    end
end

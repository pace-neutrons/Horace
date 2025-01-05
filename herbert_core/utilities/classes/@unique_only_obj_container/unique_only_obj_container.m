classdef unique_only_obj_container < ObjContainersBase
    %UNQUE_ONLY_OBJ_CONTAINER contains only unique objects prviding
    %permanent references (pointers) to these objects
    %
    % Despite this is still serializable object, there are no situation
    % when this object is expected to be serialized or saved to hdd.
    %
    properties (Access=protected)
        n_unique_       = 0;          % number of unique objects stored in
        %                             % the container
        stored_hashes_  = cell(1,0);  % the hashes of unique objects stored
        %                             % for fast processing and search
        %                               operations
        n_duplicates_   = zeros(1,0); % number of duplicateds
        lidx_           = zeros(1,0); % continuous array of local indices for the objects in the contianer

        total_allocated_ = 0;
        max_obj_idx_     = 0;
    end
    properties(Dependent,Hidden=true)
        % property containing list of stored hashes for unique objects for
        % comparison with other objects
        stored_hashes;
        % size of the memory allocated within the procedure. Information
        % and tests usage.
        allocated_mem_size;
    end
    %properties(Constant,Access= protected)
    properties(Access=protected)
        % typical experiment may contain ~200 runs. The configuration is
        % usually unique, but in special cases may differ between runs.
        % let's select number which mimimize memory storage but from another,
        % do not reallocate memory too often to accomodate all runst which
        % may become unique. If these assumptions are insufficient, we may
        % always introduce more complex algorithm (e.g. doupling each
        % allocation size. see e.g. C++ stl algorithms for vector) in a future.
        mem_expansion_chunk_ = 100;
    end
    methods(Access=protected)
        function [self,lidx_first_empty] = check_and_expand_memory_if_necessary(self)
            % Expand memory used for keeping and managing container objects
            % if current memory is insufficient for keeping more objects.
            %
            % memory manament idea borrowed from Alen & Tildesley "Computer
            % simulation of liquids
            n_existing            = self.n_unique_;
            lidx_first_empty      = n_existing  + 1;
            if lidx_first_empty<=self.total_allocated_
                return;
            end

            stor_chunk = cell(self.mem_expansion_chunk_,1);
            self.idx_            = [self.idx_,zeros(1,self.mem_expansion_chunk_)];
            self.unique_objects_ = [self.unique_objects_(:);stor_chunk(:)]';
            self.stored_hashes_  = [self.stored_hashes_(:);stor_chunk(:)]';
            self.n_duplicates_   = [self.n_duplicates_,zeros(1,self.mem_expansion_chunk_)];
            self.lidx_           = [self.lidx_,lidx_first_empty:n_existing+self.mem_expansion_chunk_];

            self.total_allocated_ = numel(self.idx_);
        end
    end
    %----------------------------------------------------------------------
    % Dependent properties set/get functions specific to subclass.
    methods
        function self = unique_only_obj_container(varargin)
            %UNIQUE_ONLY_OBJ_CONTAINER construct the container
            % Input:
            % ------
            % Either
            % - no arguments (loadobj interface request)
            % Or
            % - basecl: base class for all objects contained
            % Or
            % - standard set of input positional or key-value parameters,
            %   used by serializable constructor
            if nargin == 0
                return;
            end
            self = self.init(varargin{:});
        end
        %
        function x = get.stored_hashes(self)
            %GET.STORED_HASHES - list the hashes corresponding to the unique
            % objects. Only really useful for debugging.
            x = self.stored_hashes_;
        end
        function ms = get.allocated_mem_size(self)
            ms = numel(self.idx_);
        end
    end
    %----------------------------------------------------------------------
    % SATISFY CONTAINERS INTERFACE
    %----------------------------------------------------------------------
    methods
        function uoca = expose_unique_objects(self)
            % expose cellarray of unique objects this container subscribes to.
            uoca = get_unique_objects(self);
        end

        function [lix, hash,obj] = find_in_container(self,obj)
            %FIND_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj  : the object which may or may not be uniquely contained
            %         in self
            % Output:
            % - lix  : the index of the unique object in self.unique_objects_,
            %          if it is stored, otherwise empty []
            % - hash : the hash of the object from hashify
            %
            % - obj  : input object. If hashable, contains calculated hash
            %          value, if this value have not been there initially
            %
            [obj,hash] = build_hash(obj);
            if isempty(self.stored_hashes_)
                lix = []; % object not stored as nothing is stored
            else
                % get intersection of array stored_hashes_ with (single) array
                % hash from hashify. Calculates the index of the hash in
                % stored_hashes.
                [~,lix] = ismember( hash, self.stored_hashes_(1:self.n_unique_));
                if lix<1
                    lix = []; % ismember returns 0 in this case, not []
                end
            end
        end

        function obj = replicate_runs(varargin)
            % function expands container onto specified number of runs.
            % only single unique object allowed to be present in the
            % container initially
            error('HERBERT:unique_objects_container:not_implemented', ...
                'This funciton is pissible but does not make sence on unique_only_obj_container')
        end

        function sset = get_subset(self,indices)
            error('HERBERT:unique_objects_container:not_implemented', ...
                'This funciton is pissible but does not make sence on unique_only_obj_container')
        end
        function [self,gidx] = replace(self,obj,nuix,varargin)
            %REPLACE replaces the object at non-unique index nuix in the container
            % Input:
            % - obj : the object to be added. This may duplicate an object
            %         in the container, but it will be noted as a
            %         duplicate; it is positioned at index nuix
            % - nuix : position at which obj will be inserted. nuix must
            %          be in the range 1:numel(self.idx_)
            % Output:
            % - self : the changed container (as this is a value class)
            %
            % it may be a duplicate but it is still the n'th object you
            % added to the container. The number of additions to the
            % container is implicit in the size of idx_.

            % check that obj is of the appropriate base class
            [self,gidx] = replace_(self,obj,nuix,varargin{:});
        end % replace()

        function obj = get(self,lidx)
            % given the non-unique index nuix that you know about for your
            % object (it was returned when you added it to the container
            % with add) get the unique object associated
            %
            % Input:
            % - luix : unique index of this object used in subsref
            % Output:
            % - obj : the unique object store for this index
            %
            self.check_if_range_allowed(lidx);
            ix = self.lidx_(lidx);
            if numel(ix) == 1
                obj = self.unique_objects{ix};
            else
                obj = cellfun(@(ii)self.unique_objects{ii},ix);
            end
        end

        function newself = reorder(self)
            % the internal order of unique_objects_container is not well
            % defined. As long as idx and unique_objects between them
            % return the correct object, the internal order does not
            % matter.
            % However, in test comparisons, this can cause false failures.
            % This reordering provides a standard order when comparing.
            % This is only used for tests and so its efficiency is not
            % important.
            error('HERBERT:unique_objects_container:not_implemented', ...
                'This funciton is pissible but does not make sence on unique_only_obj_container')
        end
        %
        function val = hash(self,index)
            % accessor for the stored hashes
            val = self.stored_hashes_{ self.lidx_(index) };
        end
    end
    %----------------------------------------------------------------------
    % satisfy ObjContainersBase protected interface
    methods(Access=protected)
        function check_if_range_allowed(self,nuix,varargin)
            % Validates if input non-unique index is in the range of indices
            % allowed for current state of the container
            if nargin==3
                upper_range = self.n_objects+1;
                if any(nuix == upper_range)
                    error('HERBERT:unique_only_obj_container:invalid_argument',[ ...
                        'Some or all input indices: [%d..%d] are at the range %d+1.\n' ...
                        'This container can not be extended by addressing its elements behind its boundaries'], ...
                        nuix(1),nuix(end),upper_range);
                end
            end
            check_if_range_allowed@ObjContainersBase(self,nuix);
        end

        function x = get_idx(self)
            % core of get.idx method.
            x = self.idx_(1:self.max_obj_idx_);
        end

        function uo = get_unique_objects(self,varargin)
            %GET_UNIQUE_OBJECTS Return the cell array containing the unique
            % objects in this container.
            % if provided with argument, return object, located at
            % specified non-unique index
            % TODO: reconsile with get
            if nargin == 1
                uo = self.unique_objects_(1:self.n_unique_);
            else
                nuidx = varargin{1};
                self.check_if_range_allowed(nuidx);
                uidx = self.idx_(nuidx );
                if numel(uidx)==1
                    uo = self.unique_objects_{uidx};
                else % this makes {a:b}  behave like (a:b).
                    % TODO: May be should be modified and extended.
                    uo = self.unique_objects_(uidx);
                    uo = [uo{:}];
                end
            end
        end
        %
        function self = set_unique_objects(self,val)
            %SET_UNIQUE_OBJECTS Load a cell array or array of appropriate
            % objects into the container, e.g. from file
            %
            % Inputs:
            % -------
            % val = array or cellarray of unique objects to populate the
            % container.
            %
            % NB this set operation should only be done in environments such as
            % loadobj which disable combo arg checking
            error('HERBERT:unique_only_obj_container:not_implemented', ...
                'This method is not implemented')
        end
        function nd = get_n_duplicates(self)
            % retrieve number of duplicates, stored in the container
            nd = self.n_duplicates_(1:self.n_unique_);
        end
        function self = set_n_duplicates(self,n_dupl)
            % main setter for set.n_duplicates method
            %
            if ~isnumeric(n_dupl)
                error('HERBERT:unique_only_obj_container:not_implemented', ...
                    'Input for n_duplicates can be only numeric array')
            end
            if numel(n_dupl) ~= self.n_unique_
                error('HERBERT:unique_only_obj_container:not_implemented', ...
                    'Number of elements in n_duplicates array (%d) must be equal to the number of unique objects in the container (%d)', ...
                    numel(n_dupl),self.n_unique_);
            end
            self.n_duplicates_(1:self.n_unique_)  = n_dupl(:)';
        end
        %
        function n = get_n_unique(self)
            % get number of unique objects in the container
            n = self.n_unique_;
        end
        %
        function  n = get_n_objects(self)
            % return number of objets, stored in the container
            % Main part of get.n_objects method
            n = self.n_unique_;
        end
        function [self,nuix] = add_single(self,obj)
            [self,nuix] = add_if_new_single_(self,obj);
        end

    end
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    properties(Constant,Access=private)
        fields_to_save_ = {...
            'baseclass'};
        % Despite this class have serializable interface, its contents should
        % not be saved/restored ,     ...
        %    'unique_objects',...
        %    'idx'...
        %    'n_duplicates'...
        %    };
    end

    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end

        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = unique_only_obj_container.fields_to_save_;
        end


        function obj = check_combo_arg(obj,with_checks)
            % runs after changing property or number of properties to check
            % the consistency of the changes against all other relevant
            % properties
            %
            % Inputs:
            % with_checks  -- if true, each following hash is compared with
            %                 the previous hashes and if coincedence found,
            %                 throw the error. Necessary when replacing the
            %                 unique_objects to check that new objects are
            %                 indeed unique. The default is false.
            if nargin == 1
                with_checks  = false;
            end
            obj = check_combo_arg@ObjContainersBase(obj);
            obj = check_combo_arg_(obj,with_checks);
        end
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = unique_objects_container();
            obj = loadobj@serializable(S,obj);
        end
    end % static methods
end % classdef unique_objects_container

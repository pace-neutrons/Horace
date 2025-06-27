classdef unique_only_obj_container < ObjContainersBase
    %UNQUE_ONLY_OBJ_CONTAINER contains only unique objects providing
    %permanent references (pointers) to these objects
    %
    % contrary to unique_objects_container, it also contains and
    % exposed only unique addresses of the objects it holds.
    %
    % There are two types of addresses of this object: local indices (lidx)
    % -- continuous array of numbers with size, equal to number of objects
    % container holds and global indices (gidx, exposed as idx to adhere to
    % common containers interface) -- the array of constant indices(numbers)
    % used to address container's unique objects from out
    % unique
    % objects can be addressed from outside
    %
    %
    % Despite this is still serializable object by inheritance, there are
    % no situation when this object is expected to be serialized or saved
    % to hdd, so searilizable features of this object are disabled.
    %
    properties (Access=protected)
        n_unique_       = 0;          % number of unique objects stored in
        %                             % the container
        stored_hashes_  = cell(1,0);  % the hashes of unique objects stored
        %                             % for fast processing and search
        %                               operations
        n_duplicates_   = zeros(1,0); % number of duplicated
        lidx_           = zeros(1,0); % continuous array of local indices for the objects in the container

        total_allocated_ = 0;    % total size of allocated memory
        max_obj_idx_     = 0;    % maximal position of global index of
        %                        % unique objects in memory
    end
    properties(Dependent,Hidden=true)
        % property containing list of stored hashes for unique objects for
        % comparison with other objects
        stored_hashes;
        % size of the memory allocated within the procedure. Information
        % and tests usage.
        allocated_mem_size;
        %
        lidx % access to internal local indices of the container,
        % controlling distribution of information within the container
    end
    properties(Access=protected)
        % typical experiment may contain ~200 runs. The configuration is
        % usually unique, but in special cases may differ between runs.
        % let's select number which minimize memory storage but from other
        % side, do not reallocate memory too often to accommodate all runs
        % which may become unique. If these assumptions are insufficient,
        % we may always introduce more complex algorithm (e.g. doubling each
        % allocation size. see e.g. C++ stl algorithms for the vector)
        % in a future.
        mem_expansion_chunk_ = 100;
    end
    methods(Access=protected)
        function [self,lidx_first_empty] = check_and_expand_memory_if_necessary(self)
            % Expand memory used for keeping and managing container objects
            % if current memory is insufficient for keeping more objects.
            %
            % memory management idea borrowed from Alen & Tildesley "Computer
            % simulation of liquids
            n_existing            = self.n_unique_;
            lidx_first_empty      = n_existing  + 1;
            if lidx_first_empty<=self.total_allocated_
                return;
            end

            stor_chunk = cell(self.mem_expansion_chunk_,1);

            self.unique_objects_ = [self.unique_objects_(:);stor_chunk(:)]';
            self.stored_hashes_  = [self.stored_hashes_(:);stor_chunk(:)]';
            self.n_duplicates_   = [self.n_duplicates_,zeros(1,self.mem_expansion_chunk_)];
            % local indices and global indices pointing to each other
            new_idx = lidx_first_empty:n_existing+self.mem_expansion_chunk_;
            self.idx_            = [self.idx_,new_idx];
            self.lidx_           = [self.lidx_,new_idx];

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
        function is = is_in(self,gidx)
            % returns true if input global idx is within allowed indices range
            % of the container or false otherwise
            is = all(gidx>0 & gidx<=self.max_obj_idx_);
        end
        function lix = get.lidx(self)
            lix = self.lidx_;
        end
        function out = get_at_direct_idx(self,gidx)
            % return object given its direct location in the container's
            % local storage.
            %
            % Used by unique_references_container to obtain objects from
            % pointers stored in them
            self.check_if_range_allowed(gidx);
            n_targ = numel(gidx);
            out = cell(1,n_targ);
            obj = self.unique_objects_{gidx(1)};
            base_class = class(obj);
            same_class = true;
            out{1}=obj;
            for i=2:n_targ
                out{i} = self.unique_objects_{gidx(i)};
                if ~strcmp(class(out{i}),base_class) % check if we can
                    same_class = false; % merge different classes in one array
                    % may be addressed by mixing arrays, but we are not
                    % using them right now.
                end
            end
            if same_class
                out = [out{:}];
            end

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

        function [idx, hash,obj] = find_in_container(self,obj,return_global)
            %FIND_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj  : the object which may or may not be uniquely contained
            %         in self
            % - return_global
            %        : if present and true return unmutable global index
            %          defining external position of object in the
            %          unique objects container.
            % Output:
            % - idx  : the index of the unique object in self.lidx_ or
            %          self.idx_ depending of return_global being true or
            %          false, if it is stored, otherwise empty []
            % - hash : the hash of the object from build_hash
            %
            % - obj  : input object. If hashable, contains calculated hash
            %          value, if this value have not been there initially
            %
            if nargin <3
                return_global = false;
            end
            [obj,hash] = build_hash(obj);
            if isempty(self.stored_hashes_)
                idx = []; % object not stored as nothing is stored
                return
            else
                % get intersection of array stored_hashes_ with (single) array
                % hash from hashify. Calculates the index of the hash in
                % stored_hashes.
                [present,idx] = ismember(hash,self.stored_hashes_(self.lidx_(1:self.n_unique_)));
                if ~present
                    idx = []; % ismember returns 0 in this case, not []
                    return
                end
            end
            if return_global % if requested, return container global indices
                % which may be used as permanent reference to the object
                % outside of the container
                idx = self.lidx_(idx);
            end
        end

        function self = replicate_runs(self,n_duplicates,gidx)
            % function expands number of references onto unique object in
            % the contaner at specified position by additional number of
            % references provided as input.
            %
            % E.g. if an object in position 3 had one reference,
            % after replication by 10, it will have 10 references.
            % if it had 2 references, it will be 11 references.
            %
            self.n_duplicates_(gidx) = self.n_duplicates_(gidx)+n_duplicates-1;
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
        function val = hash(self,lidx)
            % accessor for the stored hashes looping over container indices
            %
            % Indices are accessed through their local indices in container
            %
            % confusing test function.
            val = self.stored_hashes_{ self.lidx_(lidx) };
        end
    end
    %----------------------------------------------------------------------
    % satisfy ObjContainersBase protected interface
    methods(Access=protected)
        function uo = get_unique_objects(self,varargin)
            %GET_UNIQUE_OBJECTS Return the cell array containing the unique
            % objects in this container.
            % if provided with argument, return object, located at
            % specified non-unique index
            if nargin == 1
                uo = self.unique_objects_(self.lidx_(1:self.n_unique_));
            else
                nuidx = varargin{1};
                self.check_if_range_allowed(nuidx);
                uidx = self.lidx_(nuidx);
                if isscalar(uidx)
                    uo = self.unique_objects_{uidx};
                else % this makes {a:b}  behave like (a:b).
                    % TODO: May be should be modified and extended.
                    uo = self.unique_objects_(uidx);
                    uo = [uo{:}];
                end
            end
        end
        %

        function check_if_range_allowed(self,nuix,varargin)
            % Validates if input non-unique index is in the range of indices
            % allowed for current state of the container
            %
            %
            if nargin==3
                upper_range = self.max_obj_idx_+1;
                if any(nuix == upper_range)
                    error('HERBERT:unique_only_obj_container:invalid_argument',[ ...
                        'Some or all input indices: [%d..%d] are at the range %d+1.\n' ...
                        'This container can not be extended by addressing its elements behind its boundaries'], ...
                        nuix(1),nuix(end),upper_range);
                end
            else
                upper_range = self.max_obj_idx_;
            end
            if any(nuix < 1) || any(nuix > upper_range)
                error('HERBERT:ObjContainersBase:invalid_argument', ...
                    'Some or all input indices: [%d..%d] are outside allowed range [1:%d] for this container', ...
                    nuix(1),nuix(end),upper_range);
            end
        end

        function x = get_idx(self)
            % core of get.idx method.
            if isempty(self.n_duplicates_)
                x = [];
            else
                idx = 1:self.max_obj_idx_;
                idx(self.n_duplicates_(idx)==0) = 0;
                x   = idx;
            end
        end

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
            nd = self.n_duplicates_(1:self.max_obj_idx_);
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
            %ADD_SINGLE Add single object to the unique objects container
            % if it is not already there. If it is, increase number of object references
            %
            %
            % Input
            % -----
            % self - the unique_objects_container in question
            % obj  - the object to be added to the container
            %
            % Output
            % ------
            % self - the modified container (modified by adding obj)
            % nuix - the global insertion index at which obj is added in the container
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

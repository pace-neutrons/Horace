classdef unique_objects_container < ObjContainersBase
    %UNIQUE_OBJECTS_CONTAINER
    % This container stores objects of a common baseclass so that if some
    % contained objects are duplicates, only one unique object is stored
    % for all the duplicates.
    %
    % The following documentation on use is usefully supplemented by the
    % tests in the test_unqiue_objects_container suite.
    %
    % Duplicates are only compressed to a single copy for this instance of
    % unique_objects_container; other unique_objects_containers will have
    % their own copy of an object even if this container also contains a
    % copy. If you wish to have many containers share a set of unique
    % objects to increase the compression of the storage, then use
    % unique_references_container.
    %
    % Note that unique_references_container uses unique_objects_container
    % as the underlying storage singleton container for its contents.
    %
    % The overall aim here is - minimise memory for storage of objects in
    % this container.
    %
    % If you do also need the elimination of duplicates between containers,
    % then use unique_references_container instead of unique_object_container.
    %
    % The usage of this container is that it emulates an array or cell
    % array. Thus
    % >> u{1} = 'a'; % sets the first element of u to 'a'.
    % >> u(9) = 'b'; % sets the 9th element of u to 'b'.
    % Either kind of brace or parenthesis may be used.
    % For u(9) = 'b', at least 8 elements must already be present in u.
    % If the 9th element does not already exist, the container will be
    % extended to accommodate it.
    % An element may always be added to the end of the container by
    % >> u = u.add('c'); % here 'c' is added as the new last element
    % regardless of the size. Note that this is not a handle class and the
    % resized container must be copied back to u.  Multiple elements may be
    % added at the same time via a cell array.
    %
    % Elements in the container may be used as with an array or cell array;
    % thus:
    % >> a = u{3}; will copy the third element of u to variable a.
    % NOTE! As a limitation in the current implementation, if an element is
    % a struct or class instance, its fields may not be referenced immediately, but
    % must be copied to be reset. Thus
    % >> u{3}.info = 'new_info' is not allowed for an instance or struct field .info.
    % Instead you must do
    % >> s = u{3};
    % >> s.info = 'new_info';
    % >> u{3} = s.
    %
    % The constructor takes 2 keyword arguments:
    % >> uoc = unique_objects_container('baseclass', bc,             ...
    %                                   'convert_to_stream_f', cf);
    % where
    %    - bc = the common baseclass for all objects in the contain
    %    - cf = serializer function to create a hash from the objects
    % Both are optional:
    %    - if bc is not specified, objects can be of any type.
    %    - if cf is not specified, it defaults to the undocumented
    %      function getByteStreamFromArray to perform the conversion.
    %
    %
    % Usage issues:
    % It is possible to extract the cell array containing the unique
    % objects with the get.unique_objects property. This may be used to
    % scan properties of the container without duplicating items in the
    % scan. This is a by-product of the availability of get.unique_objects
    % due to its use by saveobj; users may wish to consider if this should
    % be used as it breaks encapsulation. The cell-array list may be modified
    % outside of the container and returned to it due to the availability
    % of set.unique_objects; it is not recommended that this be used as the
    % changes may break the container's consistency.
    %
    % The number of objects in a container is retrieved via
    % container.n_objects. As Horace instruments and samples are conceptually
    % stored per run, this size can also be retrieved as container.n_runs.
    %
    % NOTE: unique_references_container uses unique_objects_container to
    % implement its storage. Ensure that any changes here in
    % unique_objects_container are reflected in unique_references_container
    % if required.

    properties (Access=protected)
        stored_hashes_ = cell(1,0);  % their hashes are stored
        % (default respecified in constructor inputParser)
    end
    properties(Dependent,Hidden)
        % property containing list of stored hashes for unique objects for
        % comparison with other objects
        stored_hashes;
    end
    %----------------------------------------------------------------------
    % Dependent properties set/get functions specific to subclass.
    methods
        function self = unique_objects_container(varargin)
            %UNIQUE_OBJECTS_CONTAINER construct the container
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
        %
    end
    %----------------------------------------------------------------------
    % SATISFY CONTAINERS INTERFACE
    %----------------------------------------------------------------------
    methods
        function uoca = expose_unique_objects(self)
            % expose cellarray of unique objects this container subscribes to.
            uoca = get_unique_objects(self);
        end

        function [ix, hash,obj] = find_in_container(self,obj)
            %FIND_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj : the object which may or may not be uniquely contained
            %         in self
            % Output:
            % - ix   : the index of the unique object in self.unique_objects_,
            %          if it is stored, otherwise empty []
            % - hash : the hash of the object from hashify
            %
            % - obj  : input object. If hashable, contains calculated hash
            %          value, if this value have not been there initially
            %
            [obj,hash] = build_hash(obj);
            if isempty(self.stored_hashes_)
                ix = []; % object not stored as nothing is stored
            else
                % get intersection of array stored_hashes_ with (single) array
                % hash from hashify. Calculates the index of the hash in
                % stored_hashes.
                [~,ix] = ismember( hash, self.stored_hashes_ );
                if ix<1
                    ix = []; % ismember returns 0 in this case, not []
                end
            end
        end

        function obj = get(self,nuix)
            % given the non-unique index nuix that you know about for your
            % object (it was returned when you added it to the container
            % with add) get the unique object associated
            %
            % Input:
            % - nuix : non-unique index that has been stored somewhere for
            %          this object
            % Output:
            % - obj : the unique object store for this index
            %
            obj = self.get_unique_objects(nuix);
        end
        function obj = replicate_runs(obj,n_objects)
            % function expands container onto specified number of runs.
            % only single unique object allowed to be present in the
            % container initially
            validateattributes(n_objects, {'numeric'}, {'>', 0, 'scalar'})
            if obj.n_unique ~=1
                error('HERBERT:unique_objects_container:invalid_argument',...
                    'The method works only on containers containing a single unique run. This container contains %d unique runs.', ...
                    obj.n_unique);
            end

            obj.idx_ = ones(1,n_objects);
        end

        function sset = get_subset(self,indices)
            sset = unique_objects_container('baseclass',self.baseclass);
            for i = indices
                item = self.get(i);
                [sset,~] = sset.add(item);
            end
        end
        function [self,nuix] = replace(self,obj,nuix,varargin)
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
            self.check_if_range_allowed(nuix,varargin{:})
            self = replace_(self,obj,nuix);
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
            newself = unique_objects_container('baseclass',self.baseclass);%,'convert_to_stream_f',self.convert_to_stream_f');

            for i=1:self.n_objects
                newself = newself.add(self.get(i));
            end
        end
        %
        function val = hash(self,index)
            % accessor for the stored hashes
            val = self.stored_hashes_{ self.idx_(index) };
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
            % TODO: reconsile with get
            if nargin == 1
                uo = self.unique_objects_;
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
            if ~iscell(val)
                val = {val};
            end
            if self.n_objects>0 && self.n_unique ~= numel(val)
                error('HERBERT:unique_objects_container:invalid_argument',[...
                    'If container is not empty, number of unique objects to' ...
                    ' set must be equal to the number of exisiting unique objects\n' ...
                    'n_unique_objects = %d; number of candidates to set = %d'], ...
                    self.n_unique,numel(val));
            end

            self.unique_objects_ = val;
            check_existing = ~isempty(self.stored_hashes_)||(isempty(self.idx_));
            self.stored_hashes_  = {};
            if self.do_check_combo_arg_
                self = self.check_combo_arg(check_existing);
            end
        end
        function n = get_n_unique(self)
            % get number of unique objects in the container
            n = numel(unique(self.idx_));
        end
        %
        function nd = get_n_duplicates(self)
            % retrieve number of duplicates, stored in the container
            nd = accumarray(self.idx_',1)';
        end
        %
        function  n = get_n_objects(self)
            % return number of objets, stored in the container
            % Main part of get.n_objects method
            n = numel(self.idx_);
        end
        function [self,nuix] = add_single(self,obj)
            [self,nuix] = add_single_(self,obj);
        end
    end
    %----------------------------------------------------------------------
    % UNIQUE_OBJ CONTAINERS SPECIFIC. Think about removing or making private
    % at least for majority of them.
    %----------------------------------------------------------------------
    methods
        function self = clear(self)
            % empty container. unique_object_container interface request.
            % TODO: remove?
            self.idx_ = zeros(1,0);
            self.unique_objects_=cell(1,0); % the actual unique objects - initialised in constructor by type
            self.stored_hashes_ = cell(1,0);  % their hashes are stored
            self.n_duplicates_ =  zeros(1,0);
        end

        function self = rehashify_all(self,with_checks)
            % recalculate hashes of all objects, stored in the container
            %
            % Inputs:
            % with_checks -- if true, run check assuring that all hashes
            %                are unique and throw otherwise
            if nargin == 1
                with_checks = false;
            end
            self.stored_hashes_ =cell(1,self.n_unique);
            for i=1:self.n_unique
                [self.unique_objects_{i},hash] = build_hash(self.unique_objects{i});
                if with_checks
                    is = ismember(hash,self.stored_hashes_(1:i-1));
                    if is
                        error('HERBERT:unique_objects_container:invalid_argument',...
                            'Non-unique objects are set as input to unique objects container')
                    end
                end
                self.stored_hashes_{i} = hash;
            end
        end
    end


    % SERIALIZABLE interface
    %------------------------------------------------------------------
    properties(Constant,Access=private)
        fields_to_save_ = {
            'baseclass',     ...
            'unique_objects',...
            'idx'...
            };
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
            flds = unique_objects_container.fields_to_save_;
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

        function out = concatenate(objs, type)
            %CONCATENATE takes the unique_object and idx (index) arrays from
            % an array of one or more unique_object_containers and concatenates
            % separately the unique objects and the indices to single outputs
            % suitable for use with object_lookup
            %
            % Input
            % -----
            % - objs - one cell or array of one or more unique_object_containers
            % - type - '{}' if objs is a cell; anything else (but by
            %          convention '()') if objs is an array
            %
            % Outputs
            % -------
            % - out - single unique_objects_container combining the contents of
            %         the elements of the input array objs

            if isempty(objs)
                error('HERBERT:unique_objects_container:invalid_input', ...
                    'at least one object must be supplied to concatenate');
            end

            concat_cells = strcmp(type,'{}');

            if numel(objs)==1
                if concat_cells
                    out = objs{1};
                else
                    out = objs;
                end
            else
                if concat_cells
                    out = objs{1};
                    for ii=2:numel(objs)
                        for jj=1:objs{ii}.n_runs
                            out_obj = objs{ii}.get(jj);
                            out_hsh = objs{ii}.hash(jj);
                            [~,index] = ismember(out_hsh, out.stored_hashes_);
                            if index==0, index = []; end
                            out = out.add_single_(out_obj,index,out_hsh); %( objs{ii}.get(jj) );
                        end
                    end
                else
                    out = objs(1);
                    for ii=2:numel(objs)
                        for jj=1:objs(ii).n_runs
                            out_obj = objs(ii).get(jj);
                            out_hsh = objs(ii).hash(jj);
                            [~,index] = ismember(out_hsh, out.stored_hashes_);
                            if index==0, index = []; end
                            out = out.add_single_(out_obj,index,out_hsh); %( objs{ii}.get(jj) );
                        end
                    end
                end
            end
        end

    end % static methods
end % classdef unique_objects_container

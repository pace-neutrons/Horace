classdef unique_references_container < ObjContainersBase
    %UNIQUE_REFERENCES_CONTAINER
    % This container stores objects of a common baseclass so that if some
    % contained objects are duplicates, only one unique object is stored
    % for all the duplicates in a global storage, common for all
    % unique_reference_container instances.
    %
    % The following documentation on use is usefully supplemented by the
    % tests in the test_unqiue_objects_container suite.
    %
    % The objects are assigned to a category (or parent class name), and
    % all containers with the same category have their unique objects
    % stored in a singleton unique_obj_store. Access to the global storage
    % of the container be obtained by calling singleton's method:
    %
    %>> storage =  unique_obj_store.instance().get_objects('category');
    %
    % Any changes to storage can be send back by inverse method:
    % unique_obj_store.instance().set_objects(storage);
    % but this method should be used within unique_references_container
    % only, because invalid deleteon of objects from global storage may
    % invalidate other unique_reference_container-s present in sqw objects
    % allocated in memory and referring to this storage.
    %
    % The global container does not persist between sessions, and containers
    % written out to file are represented by separate
    % unique_objects_containers, one for each owner of the container
    % (usually the experiment_info object of an sqw.)
    %
    % The overall aim here is - minimise overall memory for storage of
    % objects in a given Matlab session, and also achieve partial storage
    % minimisation on file without using separate global objects also being written to file.
    %
    % If you do not need the elimination of duplicates between containers,
    % then use unique_object_container instead of unique_references_container.
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
    % %
    % >> myurc = unique_references_container(stored_base_type)
    % where stored_base_type will be a common superclass of all objects in
    % the container
    %
    % Usage issues:
    % It is possible to extract the cell array containing the unique
    % objects with the expose_unique_objects property. This may be used to
    % scan properties of the container without duplicating items in the
    % scan. This is a by-product of the availability of get.unique_objects
    % due to its use by saveobj; users may wish to consider if this should
    % be used as it breaks encapsulation. It works by get.unique_objects
    % returning  a copy of the underlying singleton unique_obects_container
    % with objects not present in this container removed; its corresponding cell array
    % is then extracted  with a further use of .unique_objects - see the
    % expose_unique_objects method.
    % It is NOT possible to reset the unique objects with a corresponding set
    % property outside of loadobj. There is no actual cell array of objects
    % available in this container to modify; the user would have to modify the
    % objects stored in the underlying singleton unique_object_container. As
    % this is shared with other unique_references_container, they would also
    % be modified.
    %
    %USAGE WITH SQW OBJECTS
    % The instruments, detectors and samples in the experiment_info field of an SQW
    % are stored as unique_references_arrays. The global names for these
    % containers equal to the names of the correspondent base classes.
    %
    % You are free to use other categories for your own containers but
    % should leave these categories for Horace's SQW objects.
    %
    % The number of objects in a container is retrieved via
    % container.n_objects. As instruments and samples are conceptually
    % stored per run, this value is also retrieved as container.n_runs.
    %
    % NOTE:unique_objects_container is used by unique_references_container to
    % implement its storage. Ensure that any changes here in
    % unique_references_container will continue to be supported by unique_objects_container
    % if required.

    methods % constructor and container specific set/get (no any)
        function self = unique_references_container(varargin)
            %CONSTRUCTOR - create unique_references_container
            % Input:
            % ------
            % Either
            % - no arguments (loadobj interface request)
            % Or
            % - basecl: base class for all objects contained
            % Or
            % - standard set of input positional or key-value parameters,
            %   used by serializable constructor
            if nargin==0
                return
            end
            self = self.init(varargin{:});
        end
    end
    %----------------------------------------------------------------------
    % SATISFY CONTAINERS INTERFACE
    %----------------------------------------------------------------------
    methods
        function uoca = expose_unique_objects(self)
            %EXPOSE_UNIQUE_OBJECTS - returns the unique objects referred by
            % self as a cell array. This allows the user to scan unique objects
            % for a property without having to rescan for duplicates. It is not
            % intended to expose the implementation of the container.

            % obtain a unique_objects_container with the unique objects
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            uidx = unique(self.idx_);
            % retrieve unique objects referred here as a cell array for external use
            uoca = arrayfun(@(idx)(storage.get_at_direct_idx(idx)),uidx,'UniformOutput',false);
        end
        %
        function self = replicate_runs(self, n_objects)
            %REPLICATE_RUNS - for the case with only 1 unique object contained,
            % Enlarge the container so that it has n_objects objects contained,
            % all identical to the existing single unique object.
            %
            % Input
            % -----
            % - n_objects: the size to which the container is to be enlarged.
            %   This must be greater than the existing size of the container.

            if ~isnumeric(n_objects) || n_objects<1 || ~isscalar(n_objects)
                error('HERBERT:unique_references_container:invalid_argument', ...
                    ['n_objects can only be a positive numeric scalar; ', ...
                    ' instead it is %d, class %s'], n_objects, class(n_objects));
            end
            if self.n_unique>1
                error('HERBERT:unique_references_container:invalid_argument', ...
                    ['existing container must hold only one unique object; ', ...
                    ' instead it is %d'], self.n_unique);
            end
            if n_objects<self.n_objects
                error('HERBERT:unique_references_container:invalid_argument', ...
                    ['n_objects cannot reduce the size of the container ', ...
                    ' but it is %d, smaller than container size %s'], ...
                    n_objects, self.n_objects);
            end
            uix = self.idx(1);
            self.idx_ = zeros( n_objects, 1 )+uix;
            storage   = unique_obj_store.instance().get_objects(self.baseclass);
            storage   = storage.replicate_runs(n_objects,uix);
            %
            unique_obj_store.instance().set_objects(storage);
        end

        function [idx,hash,obj] = find_in_container(self, obj,return_global)
            %FIND_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj : the object which may or may not be uniquely contained
            %         in self
            % - return_global
            %        : if present and true return unmutable global index
            %          defining external position of object in the
            %          unique objects container. if false, return index of
            %          the object used in this container
            % Output:
            % - idx  : the index of the input object in list of local indices
            %          self.idx_ if return_global is false, or
            %          unique index of the object in the global storage
            %          If object is not stored, return emtpy []
            % - hash : the hash of the object from hashify
            %
            % - obj  : input object. If hashable, contains calculated hash
            %          value, if this value have not been there initially
            if nargin <3
                return_global = false;
            end
            idx  = [];
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            [gidx,hash,obj] = storage.find_in_container(obj,true);
            if isempty(gidx )
                return;
            end
            if ~return_global % return local index within this container.
                idx = find(gidx == self.idx_,1);
            end
        end

        function sset = get_subset(self, indices)
            % retrieve set of objects, defined by input indices
            % and arrange then into appropriate unique objects container
            sset = unique_objects_container('baseclass', self.baseclass);
            for i=indices
                item = self.get(i);
                [sset,~] = sset.add(item);
            end
        end

        function [self, nuidx] = add(self, obj)
            %ADD -
            % add (possibly contents of multiple) objects at the end of the
            % container
            %
            % Input:
            % ------
            % - obj: scalar obj, or array or cell array or unique_objects_container
            %        of objects.
            %        if not scalar then equivalent to adding the contents of
            %        obj one by one
            %
            % obj or elements within obj must match the base class - this
            % will be tested for in add_single rather than here

            % Process case that obj is a matlab container or
            % cell or unique objects container.
            % - Char objects are excluded as they are implicitly arrays of
            %   single characters but will be treated as a single object.
            % - Cells are included as even if they have only one element as
            %   they will be split up into their elements to be added here;
            %   a single element cell is thus converted to that element.
            if isempty(self.baseclass_)
                if isa(obj,'unique_objects_container')
                    self.baseclass = obj.baseclass;
                else
                    self.baseclass = class(obj);
                end
                warning('HERBERT:ObjContainerBase:incomplete_setup', ...
                    'baseclass not initialised, using first assigned type: "%s"', ...
                    self.baseclass);
            end
            storage = unique_obj_store.instance().get_objects(self.baseclass);

            % idx_add are the poistions of the added objects in storage.idx
            % array, which addresses local objects
            [storage,idx_add] = storage.add(obj);
            n_present = self.n_objects;
            nuidx  = 1:numel(idx_add);
            nuidx =  nuidx+n_present;
            self.idx_ = [self.idx_,idx_add];

            unique_obj_store.instance().set_objects(storage);
        end

        function [self,nuix] = replace(self,obj,nuix,varargin)
            %REPLACE - substitute object obj at position nuix in container
            % Equivalent to self{nuix}=obj (which would not work inside the
            % container) and used to implement it.
            %
            % Input
            % -----
            % - obj:  object to be inserted into the container
            % - nuix: (non-unique index) position at which it is to be
            %         inserted.
            % Optional:
            % '+'     if this argument is present, the replacement is
            %         allowed not on existing objects/indices only but
            %         at position n_objects+1, where operation works like
            %         simple addition.
            % Result:
            % The old value is overwritten.
            self.check_if_range_allowed(nuix,varargin{:});
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            %--------------------------------------------------------------
            % This is solution with reference counters which deletes
            % objects not referenced any more.
            %gidx             = self.idx_(nuix);
            %[storage,gidx]   = storage.replace(obj,gidx,varargin{:});
            %--------------------------------------------------------------
            % This is Chris solution implemented on
            % unique_only_obj_container. On unique_obj_container it should
            % be add_if_new (check presence in the container first if the
            % method is not implemented as such). On
            % unique_only_obj_container add is implemented as add_if_new,
            % so only new objects are placed in the container. Old objects
            % increase their reference counter.
            [storage,gidx]   = storage.add(obj);
            self.idx_(nuix)  = gidx;
            unique_obj_store.instance().set_objects(storage);
        end
        % return container ordered in a particular way. Redundant?
        newself = reorder(self)

        function val = hash(self,index)
            %HASH - for a given `index` into the container, return the associated hash
            % this prevents the calling code from having to recalculate the hash since it is already known
            obj      = unique_obj_store.instance().get_value(self.baseclass, self.idx(index));
            val      = build_hash(obj);
        end
    end

    %----------------------------------------------------------------------
    % satisfy ObjContainersBase protected interface
    methods(Access=protected)
        function uoc = get_unique_objects(self,nuidx)
            %GET_UNIQUE_OBJECTS - unique_reference_container version of
            %                     this method. Returns container of unique
            %                     objects
            % Input:
            % nuidx   -- list of non-unique local indices to retrieve
            %            unique objects for.
            %
            % if missing -- returns all unique objects
            %               referred by this container
            %
            % Output:
            % -------
            % - uoc - the unique objects as a unique_objects_container
            %
            if nargin == 1
                storage = unique_obj_store.instance().get_objects(self.baseclass);
                uoc     = unique_objects_container(self.baseclass);
                for ii=1:self.n_objects
                    gidx  = self.idx(ii);
                    obj   = storage.get_at_direct_idx(gidx);
                    uoc   = uoc.add(obj);
                end
            else
                self.check_if_range_allowed(nuidx);
                glindex = self.idx(nuidx);
                uoc = unique_obj_store.instance().get_value(self.baseclass,glindex);
            end
        end
        function self = set_unique_objects(self,val)
            %SET_UNIQUE_OBJECTS - copy objects stored in uinput
            % into this container and set set up this container's indices
            % to address these objects.

            % Part of serializable interface
            %
            % Input
            % -----
            % - val: unique_objects_container with the objects to be restored
            %        to this container
            %   Or
            %       cellarray of unique objects to add them to the container
            %       set unique objects for storage
            %
            self = set_container_from_saved_objects_(self,val);
        end
        function n = get_n_unique(self)
            % get number of unique objects in the container
            n = numel(unique(self.idx_));
        end
        %
        function nd = get_n_duplicates(self)
            % retrieve number of duplicates, stored in the container
            nd = accumarray(self.idx_',1)';
            % exclude 0 elements to advoid indices not used by the container
            % and transforming output to the form, used by other containers
            nd = nd(nd~=0);
        end
        %
        function  n = get_n_objects(self)
            % return number of objets, stored in the container
            % Main part of get.n_objects method
            n = numel(self.idx_);
        end
        function self = add_single(self,obj)
            error('HORACE:unique_references_container:not_implemented', ...
                'this method is not yet implemented on unique_references_container')
        end
    end
    %----------------------------------------------------------------------
    % unique_references_container specific. Consider making proteced or
    % remove
    methods % property (and method) set/get

        function [unique_objects, unique_idx] = get_unique_objects_and_indices(self,get_lidx)
            %GET_UNIQUE_OBJECTSAND_INDICES - get the unique objects and their
            % indices into the singleton container.
            % Inputs:
            % self     --  initialized instance of unique reference container
            % get_lidx --  boolean. If absent or false, returns array of
            %              unique global indices.
            %              If present and true -- return cellarray of local
            %              indices, each bunch referring its own unique
            %              instrument
            % Returns:
            % unique_objects
            %          -- cellarray of unique objects referred by this
            %             container
            % unique_idx
            %          -- either
            %             array of global indices, providing access
            %             to these objects from global storage
            %          -- or
            %             cellarray of arrays of local indices, each bunch
            %             gives access to local indices pointing to a
            %             single unique object in the container

            if nargin<2
                get_lidx = false;
            end
            [unique_idx,~,ic] = unique( self.idx_ );
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            n_unique = numel(unique_idx);
            unique_objects = cell( 1, n_unique);

            for i = 1:n_unique
                unique_objects{i} = storage.get(unique_idx(i));
            end
            if get_lidx
                lidx = 1:self.n_objects;
                unique_idx = cell(1,n_unique);
                for i=1:n_unique
                    unique_idx{i} = lidx(ic==i);
                end
            end
        end

        function self = set_all(self,v)
            %SET_ALL - used to reset the whole container to a single
            % value (NB alternative implementation property set.all not used,
            % as `all` has other meanings in Matlab)
            %
            % Input:
            % - v: scalar value to set all object in the container to
            %      replicate in
            if ~isa(v,self.baseclass)
                if ~(isa(v,'unique_objects_container')&&strcmp(v.baseclass,self.baseclass))
                    targ_class = class(v);
                    if isa(targ_class,'unique_objects_container')
                        targ_class = v.baseclass;
                    end
                    error('HERBERT:unique_objects_container:invalid_argument', ...
                        ['assigned value must have the same class as the one already present in the container.\n' ...
                        'Present class: "%s", Setting: "%s"'], ...
                        self.baseclass,targ_class);
                    % altergatively, we may reset the container class here.
                end
            end

            storage = unique_obj_store.instance().get_objects(self.baseclass);
            if numel(v)==self.n_objects || isa(v,'unique_objects_container')&&isequal(v.n_objects,self.n_objects)
                self.idx_ = zeros(1,self.n_objects);
                for i=1:self.n_objects
                    [storage,igdx] = storage.add(v(i));
                    self.idx_(i) = igdx;
                end
            elseif isscalar(v) && ~isa(v,'unique_objects_container')
                [storage,idgs] = storage.add(v);
                self.idx_ = repmat(idgs,1,self.n_objects);
                storage   = storage.replicate_runs(self.n_objects,idgs);
            else
                error('HERBERT:unique_objects_container:invalid_argument', ...
                    'assigned value must be scalar or have right number of objects');
            end
            unique_obj_store.instance().set_objects(storage);
        end
    end

    methods (Static)
        %==========================================================================
        % (save)/load functionality via serializable
        % save done via serializable directly

        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = unique_references_container();
            obj = loadobj@serializable(S,obj);
        end

    end
    properties (Constant, Access=private) % serializable igetnterface
        fields_to_save_ = { ...
            'baseclass', ...
            'unique_objects', ...
            };
    end

    methods % serializable interface
        function flds = saveableFields(obj)
            flds = obj.fields_to_save_;
        end
        function ver = classVersion(~)
            ver = 2;
        end
    end
    methods(Access=protected)
        function  [S,obj] = convert_old_struct (obj, S, ver)
            % convert old structure of unique object container into the
            % one, which support unique_object_storage and number of
            % duplicates
            if ver == 1
                S.baseclass = S.stored_baseclass;
            end
        end
    end
end

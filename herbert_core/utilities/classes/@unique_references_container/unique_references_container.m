classdef unique_references_container < ObjContainersBase
    %UNIQUE_REFERENCES_CONTAINER
    % This container stores objects of a common baseclass so that if some
    % contained objects are duplicates, only one unique object is stored
    % for all the duplicates.
    %
    % The following documentation on use is usefully supplemented by the
    % tests in the test_unqiue_objects_container suite.
    %
    % The objects are assigned to a category (or global_name), and all containers with the
    % same category have their unique objects stored in a singleton global
    % container for all unique_reference_containers of a given category
    % open in the current Matlab session. The static method
    % global_container implements this global container. The class
    % unique_objects_container is used to implement this storage.
    %
    % The adaptation of the standard Matlab singleton pattern to the
    % present code where several singletons, one per data type, are stored
    % in the same class, is documented in SMG-22.
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
    % extended to accomodate it.
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
            % - no arguments (loadobj invocation only)
            % Or
            % - glname: categopry name of singleton unique_objects_container
            %           for current contents
            % - basecl: base class for all objects contained
            %
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
            uoca = arrayfun(@(idx)(storage(idx)),uidx,'UniformOutput',false);
        end
        
        function [is, first_index,item] = contains(self, item)
            %CONTAINS - find if item is present in the container,
            %
            % Input
            % -----
            % - item: the object to be found in the container
            %
            % Output:
            % -------
            % - is:           logical true if item is in the container, else false
            % - first_index:  first locations in the unique references container
            %                 if it is found
            %            ==[] if not found

            % get out the global container for this container
            is = false;
            first_index = [];
            if ~isa(item,self.baseclass)
                return;
            end
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            [igdx,~,item] = storage.find_in_container(item);
            if isempty(igdx)
                return;
            end
            first_index = find(igdx == self.idx_,1);
            if ~isempty(first_index)
                is = true;
            end
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
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            storage.n_duplicates(uix) = storage.n_duplicates(uix)+n_objects-1;
            unique_obj_store.instance().set_objects(storage);
        end

        function [obj_idx,hash,obj] = find_in_container(self, obj)
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

            obj_idx = [];
            storage = unique_obj_store.instance().get_objects(selt.baseclass);
            [igx,hash,obj] = storage.find_in_container(obj);
            if isempty(igx )
                return;
            end
            inglc = find(igx == self.idx_,1);
            if ~isempty(inglc)
                obj_idx = self.igx_(inglc);
            end
        end

        function sset = get_subset(self, indices)
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


            n_add_obj = numel(obj);
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            n_present = self.n_objects;
            if ischar(obj)
                [storage,uidx] = storage.add_if_new(obj);
                idx_add = uidx;
                nuidx   = n_present+1;
            elseif iscell(obj)
                idx_add = zeros(1,n_add_obj);
                nuidx = zeros(1,n_add_obj);
                for i=1:n_add_obj
                    [storage,igdx] = storage.add_if_new(obj{i});
                    idx_add(i) = igdx;
                    nuidx(i) = n_present+i;
                end
            else
                if isa(obj, 'unique_objects_container')
                    n_add_obj = obj.n_objects;
                end
                idx_add = zeros(1,n_add_obj);
                nuidx = zeros(1,n_add_obj);
                for i=1:n_add_obj
                    [storage,igdx] = storage.add_if_new(obj(i));
                    idx_add(i) = igdx;
                    nuidx(i)   = n_present+i;
                end
            end
            self.idx_ = [self.idx_,idx_add];

            unique_obj_store.instance().set_objects(storage);
        end

        function self = replace(self,obj,nuix)
            %REPLACE - substitute object obj at position nuix in container
            % Equivalent to self{nuix}=obj (which would not work inside the
            % container) and used to implement it.
            %
            % Input
            % -----
            % - obj:  object to be inserted into the container
            % - nuix: (non-unique index) position at which it is to be
            %         inserted.
            % The old value is overwritten.
            self.check_if_range_allowed(nuix)
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            gidx = self.idx_(nuix);
            if storage.n_duplicates(gidx)>1 % this needs proper destruction
                % of presious references not to increase unique storage unnecessary
                [storage,gidx_new]= storage.add_if_new(obj);
                % if this is new object, decrease its number of copies by
                % one
                if gidx ~= gidx_new
                    storage.n_duplicates(gidx) = storage.n_duplicates(gidx)-1;
                    self.idx_(nuix) = gidx_new;
                end

            else
                storage(gidx) = obj;
            end
            unique_obj_store.instance().set_objects(storage);
        end

        function val = get(self,index)
            %GET - alternative access method: obj.get(i)===obj{i}
            self.check_if_range_allowed(index)
            ngidx = self.idx_(index);
            val = unique_obj_store.instance().get_value(self.baseclass,ngidx);
        end
        % return container ordered in a particular way. Redundant?
        newself = reorder(self)

        function val = hash(self,index)
            %HASH - for a given `index` into the container, return the associated hash
            % this prevents the calling code from having to recalculate the hash since it is already known
            storage  = unique_obj_store.instance().get_objects(self.baseclass);
            obj      = storage{ self.idx(index) };
            val      = build_hash(obj);
        end
    end

    %----------------------------------------------------------------------
    % satisfy ObjContainersBase protected interface
    methods(Access=protected)
        function uoc = get_unique_objects(self,varargin)
            %GET_UNIQUE_OBJECTS - unique_objects_container version of
            %                     this container
            % Output:
            % -------
            % - uoc - the unique objects as a unique_objects_container
            % To obtain this as a cell array, it is possible to repeat the .unique_objects
            % property get on uoc but it is preferable to use the
            % expose_unique_objects method which does this in an encapsulated fashion.
            %
            % if provided with argument, return object, located at
            % specified non-unique index
            % TODO: reconsile with get
            if nargin == 1
                storage = unique_obj_store.instance().get_objects(self.baseclass);
                uoc     = unique_objects_container(self.baseclass);
                for ii=1:self.n_objects
                    gidx  = self.idx(ii);
                    obj   = storage(gidx);
                    uoc   = uoc.add(obj);
                end
            else
                nuidx = varargin{1};
                self.check_if_range_allowed(nuidx);
                glindex = self.idx_(nuidx);
                uoc = unique_obj_store.instance().get_value(self.baseclass,glindex);
            end
        end
        function self = set_unique_objects(self,val)
            %SET_UNIQUE_OBJECTS - copy a unique_objects_container into this
            % container. Part of serializable interface
            %
            % Input
            % -----
            % - val: unique_objects_container with the objects to be restored
            %        to this container or cellarray of the objects
            if iscell(val)
                val = unique_objects_container(class(val{1}),val);
            end
            if ~isa(val,'unique_objects_container')
                error('HERBERT:unique_references_container:invalid_argument', ...
                    'unique_objects must be a unique_objects_container');
            end
            % unique_obj_container resets everything, so no point of
            % throwing in this situation. Just reset target
            if isempty(self.baseclass)
                self.baseclass  = val.baseclass;
            end
            if ~strcmp(self.baseclass,val.baseclass)
                if self.n_objects>0
                    error('HERBERT:unique_references_container:invalid_argument', ...
                        'Can not asign unique objects of type "%s" to non-empty container of type "%s"',...
                        val.baseclass,self.baseclass);
                else
                    self.baseclass_ = val.baseclass;
                end
            end
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            self.idx_ = zeros(1,val.n_objects);
            for i=1:val.n_objects
                [storage,gidx] = storage.add_if_new(val(i));
                self.idx_(i) = gidx;
            end
            unique_obj_store.instance().set_objects(storage);
        end
        function n = get_n_nunique(self)
            % get number of unique objects in the container
            n = numel(unique(self.idx_));
        end

    end
    %----------------------------------------------------------------------
    % unique_references_container specific. Consider making proteced or
    % remove
    methods % property (and method) set/get

        function [unique_objects, unique_indices] = get_unique_objects_and_indices(self)
            %GET_UNIQUE_OBJECTSAND_INDICES - get the unique objects and their
            % indices into the singleton container. Abandoned implementation
            % left in case it becomes useful.
            unique_indices = unique( self.idx_ );
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            unique_objects = cell( 1,numel(unique_indices) );
            for i = 1:numel(unique_indices)
                unique_objects{i} = storage{unique_indices(i)};
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
                    [storage,igdx] = storage.add_if_new(v(i));
                    self.idx_(i) = igdx;
                end
            elseif numel(v)==1 && ~isa(v,'unique_objects_container')
                [storage,idgs] = storage.add_if_new(v);
                self.idx_ = repmat(idgs,1,self.n_objects);
            else
                error('HERBERT:unique_objects_container:invalid_argument', ...
                    'assigned value must be scalar or have right number of objects');
            end
            unique_obj_store.instance().set_objects(storage);
        end
    end

    methods (Access = protected)
        function [self] = replace_all(self,obj)
            %REPLACE_ALL - substitute object obj at all positions in container
            %
            % Input
            % -----
            % - obj:  objects to be inserted into the container
            %         to replace all existing content
            %
            % The old values are overwritten.
            storage = unique_obj_store.instance().get_objects(self.baseclass);
            [igdx,~,obj] = storage.find_in_container(obj);
            if ~isempty(igdx)
                self.idx_(:) = igdx;
                return;
            end
            [self,igdx] = storage.add_if_new(obj);
            self.idx_(:) = igdx;

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

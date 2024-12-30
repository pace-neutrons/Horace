classdef unique_references_container < serializable
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
    % >> myurc = unique_references_container(GLOBAL_NAME, stored_base_type)
    % where stored_base_type will be a common superclass of all objects in
    % the container and GLOBAL_NAME will connect the container with a
    % global container of this category tag.
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

    properties (Access = protected)
        idx_ = zeros(1,0); %  array of unique global indices for each object stored
        stored_baseclass_ = ''; % the baseclass
    end

    properties (Dependent)
        % Name of the class, this container holds
        stored_baseclass;
        % other dependent properties
        n_unique_objects; % number of unique_objects (without creating it)
        idx;              % object indices into the global unique objects container.
        n_objects; % numel(idx)
    end
    properties(Dependent,Hidden=true)
        n_runs;    % same as n_objects, provides a domain-specific interface
        % to the number of objects for SQW-Experiment
        % instruments and samples

        unique_objects; % returns unique_objects_container. Hidden not to
        % expose expensive operation to view but widely used in access/save/load operations
    end

    methods % property (and method) set/get

        function val = get.idx(self)
            %GET.IDX - list of indices into the global container
            % Not recommended for normal use outside of saving.
            val = self.idx_;
        end

        function val = get.stored_baseclass(self)
            %GET.STORED_BASECLASS - base class for all objects in the container
            val = self.stored_baseclass_;
        end
        function self = set.stored_baseclass(self,val)
            %SET.STORED_BASECLASS - set a baseclass for this container
            % this is really only to be used by loadobj.
            % otherwise the code below permissively resets the baseclass
            % only if the container has not been populated. But really
            % better to set this on construction outside of loadobj
            if ~(ischar(val)||isstring(val))
                val = class(val);
            end
            if self.n_objects == 0 && isempty(self.stored_baseclass_)
                self.stored_baseclass_ = val;
            elseif strcmp(val,self.stored_baseclass_)
                % silently ignore resetting baseclass to the same value
            else
                error('HERBERT:unique_references_container:invalid_argument', ...
                    'stored baseclass cannot be reset differently once set');
            end
        end

        function val = get.n_objects(self)
            %GET.N_OBJECTS property - number of non-unique items in the container
            val = numel(self.idx_);
        end
        function val = get.n_runs(self)
            %GET.N_RUNS property - number of non-unique items in the container
            % Identical to n_objects - provides an interface using domain
            % nomenclature for instruments and samples in the Experiment class
            val = numel(self.idx_);
        end
        % NB n_objects only set by adding objects to the container

        function uoca = expose_unique_objects(self)
            %EXPOSE_UNIQUE_OBJECTS - returns the unique objects contained in
            % self as a cell array. This allows the user to scan unique objects
            % for a property without having to rescan for duplicates. It is not
            % intended to expose the implementation of the container.

            % obtain a unique_objects_container with the unique objects
            uoca = unique_obj_store.instance().get_objects(self.stored_baseclass);
            % convert it to a cell array for external use
            uoca = uoca.unique_objects;
        end

        function uoc = get.unique_objects(self)
            % GET.UNIQUE_OBJECTS - unique_objects_container version of
            %                           this container, principally used for
            %                           load/save to disc
            % Output:
            % -------
            % - uoc - the unique objects as a unique_objects_container
            % To obtain this as a cell array, it is possible to repeat the .unique_objects
            % property get on uoc but it is preferable to use the
            % expose_unique_objects method which does this in an encapsulated fashion.

            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            uoc     = unique_objects_container('baseclass',self.stored_baseclass);
            for ii=1:self.n_objects
                glob_idx  = self.idx(ii);
                obj   = storage(glob_idx);
                uoc   = uoc.add(obj);
            end
        end

        function self = set.unique_objects(self,val)
            %SET.UNIQUE_OBJECTS - copy a unique_objects_container into this
            % container.
            %
            % Input
            % -----
            % - val: unique_objects_container with the objects to be restored
            %        to this container.
            % this is assumed to be called from loadobj when restoring a
            % unique_reference_container from saved file.

            if ~isa(val,'unique_objects_container')
                error('HERBERT:unique_references_container:invalid_argument', ...
                    'unique_objects must be a unique_objects_container');
            end
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            self.idx_ = zeros(1,val.n_objects);
            for i=1:val.n_objects
                [storage,ids] = storage.add(val(i));
                self.idx_(i) = ids;
            end
            unique_obj_store.instance().set_objects(storage);
        end

        function n = get.n_unique_objects(self)
            n = numel( unique(self.idx_) );
        end

        function [unique_objects, unique_indices] = get_unique_objects_and_indices(self)
            %GET_UNIQUE_OBJECTSAND_INDICES - get the unique objects and their
            % indices into the singleton container. Abandoned implementation
            % left in case it becomes useful.
            unique_indices = unique( self.idx_ );
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
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
            if ~isa(v,self.stored_baseclass)||~(isa(v,'unique_objects_container')&&strcmp(v.baseclass,self.stored_baseclass))
                targ_class = class(v);
                if strcmp(targ_class,'unique_objects_container')
                    targ_class = v.baseclass;
                end
                error('HERBERT:unique_objects_container:invalid_argument', ...
                    ['assigned value must have the same class as the one already present in the container.\n' ...
                    'Present class: "%s", Setting: "%s"'], ...
                    self.stored_baseclass,targ_class);
                % altergatively, we may reset the container class here.
            end

            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            if numel(v)==self.n_objects
                self.idx_ = zeros(1,self.n_objects);
                for i=1:self.n_objects
                    [storage,igdx] = storage.add(v(i));
                    self.idx_(i) = igdx;
                end
            elseif numel(v)==1
                [is,idgs] = storage.contains(v);
                if ~is
                    [storage,idgs] = storage.add(v);
                end
                self.idx_ = repmat(idgs,1,self.n_objects);
            else
                error('HERBERT:unique_objects_container:invalid_argument', ...
                    'assigned value must be scalar or have right number of objects');
            end
            unique_obj_store.instance().set_objects(storage);
        end

    end

    methods % constructor
        function obj = unique_references_container(varargin)
            %CONSTRUCTOR - create unique_references_container
            % Input:
            % ------
            % Either
            % - no arguments (loadobj invocation only)
            % Or
            % - glname: categopry name of singleton unique_objects_container
            %           for current contents
            % - basecl: base class for all objects contained

            if nargin==1
                glname = varargin{1};
                basecl = varargin{2};
                obj = obj.init(glname,basecl);
            elseif nargin==0
                % leave as-is, to be used in loadobj only
            else
                error('HERBERT:unique_references_container:invalid_argument', ...
                    'unique_references_container requires either 0 or 2 arguments.');
            end
        end

        function self = init(self, glname, basecl)
            %INIT - constructor implementation for case with 2 arguments
            self.global_name_ = glname;
            self.stored_baseclass_ = basecl;
            self.global_container('init',glname,basecl);
        end
    end

    methods % overloaded indexers, subsets, find functions
        %
        % function field_vals = get_unique_field(self, field)
        %     %GET_UNIQUE_FIELD each of the unique objects referred to by self
        %     % should have a property named 'field'. The code below takes each of the
        %     % referred objects in turn, extracts the object referred to by
        %     % 'field' and stores it in the unique_OBJECTS_container field_vals
        %     % created here. field_vals will then contain unique copies of all
        %     % the values of 'field' within the objects referred to in self, indexed
        %     % in the same way as the original referred objects.
        %
        %     % determine type of unique_references_container to make from the
        %     % object field type
        %     s1 = self.get(1);
        %     v = s1.(field);
        %
        %     % initialise the final output container (a unique_references_container)
        %     % to hold the unique field value objects from objects in this container
        %     % which are of type class(v).
        %     glob_name = ['GLOBAL_NAME_FIELD_',class(v)];
        %     field_vals = unique_references_container(glob_name,class(v));
        %
        %     %
        %     % get a list without duplicates of indices to the objects in self
        %     % these are the indices into the global container
        %     uix = unique( self.idx_, 'stable');
        %     % get the global container (a unique_objects_container)
        %     glc = self.global_container('value',self.global_name_);
        %     % get the unique field objects out of it, and their hashes
        %     % by placing them in another temporary unique_references_container
        %     % this minimises the number of times the field object has to be hashed
        %     poss_field_vals = unique_references_container(glob_name,class(v));
        %     for ii=1:numel(uix)
        %         sii = glc{ uix(ii) };
        %         v = sii.(field);
        %         poss_field_vals = poss_field_vals.add_single_(v);
        %     end
        %
        %     % now we construct the main unique_references_container `field_vals` of
        %     % all the field values within objects in self
        %     for ii=1:self.n_objects
        %         sii = self.get(ii); % get the object
        %         v = sii.(field);    % get its field
        %         index = self.idx_(ii); % get its global index
        %         [~,loc] = ismember(index,uix); % find where it is in the list of
        %         % unique indices for objects
        %         hash = poss_field_vals.hash(loc); % find the hash at that location
        %         % find if that hash is in the hashes already in field
        %         % values and if so where it is
        %         glc = field_vals.global_container('value',glob_name);
        %         [~,loc]=ismember(hash,glc.stored_hashes_);
        %         % if we already have it, add the field object via that
        %         % location
        %         if loc>0
        %             field_vals = field_vals.add_single_(v,loc,hash);
        %             % if we don't , add it without a location (it will go at
        %             % the end as a new object/hash
        %         else
        %             field_vals = field_vals.add_single_(v,[],hash);
        %         end
        %     end
        % end

        function varargout = subsref(self, idxstr)
            if numel(self)>1 % input is array or cell of unique_references_containers
                [varargout{1:nargout}] = builtin('subsref',self,idxstr);
                return;
            end
            switch idxstr(1).type
                case {'()','{}'}
                    b = idxstr(1).subs{:};
                    if any(b<1)
                        error('HERBERT:unique_references_container:invalid_subscript', ...
                            'subscript must be positive');
                    end
                    if any(b>numel(self.idx_))
                        if numel(self.idx_)>0
                            error('HERBERT:unique_references_container:invalid_subscript',...
                                'subscript must be less than %d',numel(self.idx_)+1);
                        else
                            error('HERBERT:unique_references_container:invalid_subscript',...
                                'container is empty and cannot take a subscript');
                        end
                    end
                    glindex = self.idx_(b);
                    glc = self.global_container('value',self.global_name_);
                    c = glc(glindex);
                    if numel(idxstr)==1
                        varargout{1} = c;
                    else
                        idx2 = idxstr(2:end);
                        [varargout{1:nargout}] = builtin('subsref',c,idx2);
                    end
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',self,idxstr);
            end
        end

        function self = local_assign_(self,val,nuix)
            %LOCAL_ASSIGN - replacement for self{nuix}=val which does not work inside the class
            if isempty(self.stored_baseclass_)
                self.stored_baseclass = class(val);
                warning('HERBERT:unique_references_container:incomplete_setup', ...
                    'baseclass not initialised, using first assigned type');
            end
            if nuix<1 || nuix>self.n_objects+1
                error('HERBERT:unique_references_container:invalid_argument', ...
                    'subscript %d out of range 1..%d', nuix, numel(self.idx_));
            elseif nuix == self.n_objects+1
                self = self.add(val);
                return;
            end
            self = self.replace(val, nuix);
        end

        function self = subsasgn(self,idxstr,varargin)
            if strcmp(idxstr(1).type,'.')
                self = builtin('subsasgn',self,idxstr,varargin{:});
            else % idxstr(1).type=='()'/'{}'
                val = varargin{1}; % value to assign
                if isempty(self.stored_baseclass_)
                    self.stored_baseclass = class(val);
                    warning('HERBERT:unique_references_container:incomplete_setup', ...
                        'baseclass not initialised, using first assigned type');
                end
                if ~isa(val,self.stored_baseclass)
                    %error('HERBERT:unique_references_container:invalid_argument', ...
                    %      'assigning object with wrong baseclass');
                end
                nuix = idxstr(1).subs{:};
                if nuix<1 || nuix>self.n_objects+1
                    error('HERBERT:unique_references_container:invalid_argument', ...
                        'subscript %d out of range 1..%d', nuix, numel(self.idx_));
                elseif nuix == self.n_objects+1
                    if numel(idxstr)>1
                        error('HERBERT:unique_references_container:invalid_subscript', ...
                            ['when adding to the end of a container, additionally setting ', ...
                            'properties is not permitted']);
                    end
                    self = self.add(val);
                    return;
                end
                c = self.get(nuix);
                if numel(idxstr)>1
                    idx2 = idxstr(2:end);
                    c = builtin('subsasgn',c,idx2,varargin{:});
                    self = self.replace(c,nuix);
                else
                    self = self.replace(val, nuix);
                end
            end
        end

        function sset = get_subset(self, indices)
            sset = unique_objects_container('baseclass', self.stored_baseclass);
            for i=indices
                item = self.get(i);
                [sset,~] = sset.add(item);
            end
        end

        function [obj_idx,obj] = find_in_container(self, obj)
            obj_idx = [];
            storage = unique_obj_store.instance().get_objects(obj.stored_baseclass);
            igx = storage.find_in_container(obj);
            if isempty(igx )
                return;
            end
            inglc = find(igx == self.idx_,1);
            if ~isempty(inglc)
                obj_idx = self.igx_(inglc);
            end
        end
    end

    methods (Access = protected) % get, add, replicate and replace

        % really only for use within class. these implement
        % subsref/subsasgn action.

        function val = get(self,index)
            %GET - alternative access method: obj.get(i)===obj{i}
            storage = unique_obj_store.instance().get_objects(obj.stored_baseclass);
            val =storage{ self.idx(index) };
        end

        function val = hash(self,index)
            %HASH - for a given `index` into the container, return the associated hash
            % this prevents the calling code from having to recalculate the hash since it is already known
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            obj      =storage{ self.idx(index) };
            val      = build_hash(obj);
        end
        %
        % function [self, nuix] = add_single_(self,inobj,glindex,hash)
        %     %ADD_SINGLE - add a single object obj at the end of the container
        %     % if the existing location of inobj in the global container (`inobj`) is known together
        %     % with its associated `hash` then these are used instead of recalculating the hash
        %     if isempty(self.stored_baseclass_)
        %         error('HERBERT:unique_references_container:runtime_error', ...
        %             'stored baseclass unset');
        %     end
        %     if ~isa(inobj,self.stored_baseclass_)
        %         warning('HERBERT:unique_references_container:invalid_argument', ...
        %             'not correct stored base class; object was not added');
        %         nuix = 0;
        %         return;
        %     end
        %     if isempty(self.global_name_)
        %         error('HERBERT:unique_references_container:runtime_error', ...
        %             'global name unset');
        %     end
        % 
        %     if nargin<=2
        %         % have to recalculate the hash and the position of `inobj` in the global container as
        %         % this info is not in the additional arguments
        %         [glindex, hash,inobj] = self.global_container('value',self.global_name_).find_in_container(inobj);
        %     end
        %     if isempty(glindex)
        %         glcont = self.global_container('value',self.global_name_);
        %         [glcont,glindex] = glcont.add_single_(inobj,[],hash);
        %         self.global_container('reset',self.global_name_,glcont);
        %     end
        %     self.idx_ = [ self.idx(:)', glindex ];
        %     nuix = numel(self.idx_);
        % end
        % 
        % function [self, nuix] = add_copies_(self,obj,n)
        %     %ADD_COPIES - add a single object obj at the end of the container
        %     % multiple times
        %     %
        %     % Input:
        %     % ------
        %     % obj - the single object to be added. This must not be a
        %     %       unique container or an array of size.1 or cell.
        %     % n   - the number of copies to add
        %     %
        %     % Output
        %     % ------
        %     % self - the revised container with the additional indices for
        %     %        the added objects
        %     % nuix - the range of added non-unique indices
        % 
        %     if isempty(self.stored_baseclass_)
        %         error('HERBERT:unique_references_container:incomplete_setup', ...
        %             'stored baseclass unset');
        %     end
        %     if ~isa(obj,self.stored_baseclass_)
        %         warning('HERBERT:unique_references_container:invalid_argument', ...
        %             'not correct stored base class; object was not added');
        %         nuix = 0;
        %         return;
        %     end
        %     if isempty(self.global_name_)
        %         error('HERBERT:unique_references_container:incomplete_setup', ...
        %             'global name unset');
        %     end
        %     [glindex, ~,obj] = self.global_container('value',self.global_name_).find_in_container(obj);
        %     if isempty(glindex)
        %         glcont = self.global_container('value',self.global_name_);
        %         [glcont,glindex] = glcont.add(obj);
        %         if glindex == 0
        %             % object was not added
        %             nuix = 0;
        %             return
        %         end
        %         self.global_container('reset',self.global_name_,glcont);
        %     end
        %     multiple_copies = repmat( glindex, n, 1);
        %     oldsize = numel(self.idx_);
        %     self.idx_ = [ self.idx(:)', multiple_copies(:)' ];
        %     newsize = numel(self.idx_);
        %     nuix = oldsize+1:newsize;
        % end
        % 
        function [self, nuix] = add(self, obj)
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
            if isa(obj, 'unique_objects_container')
                n_add_obj = obj.n_objects;
            end
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            idxl = self.idx_;
            self.idx_ = zeros(1,numel(idxl)+n_add_obj);
            self.idx_(1:numel(idxl)) = idxl;
            ic = numel(idxl)+1;
            nuix = zeros(1,n_add_obj);
            for i=1:n_add_obj
                if iscell(obj)
                    [storage,igdx] = storage.add(obj{i});
                else
                    [storage,igdx] = storage.add(obj(i));
                end
                self.idx_(ic) = igdx;
                nuix(i) = ic;
                ic = ic+1;
            end
            unique_obj_store.instance().set_objects(storage);
        end

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
            if self.n_unique_objects>1
                error('HERBERT:unique_references_container:invalid_argument', ...
                    ['existing container must hold only one unique object; ', ...
                    ' instead it is %d'], self.n_unique_objects);
            end
            if n_objects<self.n_objects
                error('HERBERT:unique_references_container:invalid_argument', ...
                    ['n_objects cannot reduce the size of the container ', ...
                    ' but it is %d, smaller than container size %s'], n_objects, self.n_objects);
            end
            uix = self.idx(1);
            self.idx_ = zeros( n_objects, 1 )+uix;
        end


        % substitute object obj at position nuix in container
        function [self] = replace(self,obj,nuix)
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
            if nuix<1 || nuix>self.n_objects
                error('HORACE:unique_references_container:invalid_argument', ...
                    'index for replacement "%d" lies out of the current object boundaries: %d', ...
                    nuix,self.n_objects);
            end
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            [igdx,~,obj] = storage.find_in_container(obj);
            if ~isempty(igdx)
                self.idx_(nuix) = igdx;
                return;
            end
            [self,igdx] = storage.add(obj);
            self.idx_(nuix) = igdx;
            unique_obj_store.instance().set_objects(storage);
        end

        function [self] = replace_all(self,obj)
            %REPLACE_ALL - substitute object obj at all positions in container
            %
            % Input
            % -----
            % - obj:  objects to be inserted into the container
            %         to replace all existing content
            %
            % The old values are overwritten.
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            [igdx,~,obj] = storage.find_in_container(obj);
            if ~isempty(igdx)
                self.idx_(:) = igdx;
                return;
            end
            [self,igdx] = storage.add(obj);
            self.idx_(:) = igdx;
            unique_obj_store.instance().set_objects(storage);
        end
    end

    methods % check contents

        function [is, unique_index,item] = contains(self, item)
            %CONTAINS - find if item is present in the container,
            %
            % Input
            % -----
            % - item: the object to be found in the container
            %
            % Output:
            % -------
            % - is:           logical true if item is in the container, else false
            % - unique_index: locations in the container where it is found
            %                 ==[] if not found

            % get out the global container for this container
            is = false;
            unique_index = [];
            if ~isa(item,self.stored_baseclass)
                return;
            end
            storage = unique_obj_store.instance().get_objects(self.stored_baseclass);
            [igdx,~,item] = storage.find_in_container(item);
            if isempty(igdx)
                return;
            end
            unique_index = find(igdx == self.idx_,1);
            if ~isempty(unique_index)
                is = true;
            end
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
    properties (Constant, Access=private) % serializable interface
        fields_to_save_ = { ...
            'stored_baseclass', ...
            'unique_objects', ...
            };
    end

    methods % serializable interface
        function flds = saveableFields(obj)
            flds = obj.fields_to_save_;
        end

        function ver = classVersion(~)
            ver = 1;
        end
    end
end

classdef unique_objects_container < serializable
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
    %
    % The constructor takes 2 keyword arguments:
    % >> uoc = unique_objects_container('baseclass', bc,             ...
    %                                   'convert_to_stream_f', cf);
    % where
    %    - bc = the common baseclass for all objects in the containe
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
        unique_objects_=cell(1,0); % the actual unique objects - initialised in constructor by type
        stored_hashes_ = cell(1,0);  % their hashes are stored
        idx_ = zeros(1,0);   % array of unique indices for each non-unique object added

        baseclass_ = ''; % if not empty, name of the baseclass suitable for isa calls
        % (default respecified in constructor inputParser)
        n_duplicates_ = zeros(1,0);

        % hashify  defaults to this undocumented java function handle
        % if you try to store objects non-children for serializable and
        % the function to convert objects to bytes has not been set
        % explicitly
        convert_to_stream_f_ = @getByteStreamFromArray;
    end
    properties(Access = private)
        % is set to true if we decide not to use default stream conversion
        % function
        non_default_f_conversion_set_ = false;
    end

    properties (Dependent)
        n_objects;
        n_runs; % duplicate of n_objects that names the normal usage in Horace
        % of this container for storing possibly duplicated
        % instruments or samples per run.
        n_unique;
        %
        baseclass;
        idx;
        unique_objects;

        n_duplicates;
    end
    properties(Dependent,Hidden)
        % string representation of the function, used to serialize
        % input objects which can not serialize themselves.
        % (I.e. are not the children of "serializable" class).
        % The representation used for simple saveobj/loadob conversion
        % of the container into not-Matlab binary files.
        conv_func_string;
        % handle to the function, used for conversion of objects into
        % bytestream if default serialization is not available. May be set
        % up directly through function handle or through ist string
        % representation above
        convert_to_stream_f;
        % property containing list of stored hashes for unique objects for
        % comparison with other objects
        stored_hashes;
    end
    %----------------------------------------------------------------------
    % Dependent properties set/get functions and subsrefs/subsassign
    % methods
    methods
        function val = get.conv_func_string(obj)
            %GET.CONV_STRING_FUNCTION - report the function handle used to
            % generate hashes
            val = func2str(obj.convert_to_stream_f_);
        end
        function obj = set.conv_func_string(obj,val)
            %SET.CONV_STRING_FUNCTION - set the function handle used to
            % generate hashes. Should only be used with loadobj. After the
            % container is created, changing this functionmid-stream may
            % invalidate the comparison for unique objects.

            if ~(ischar(val)||isstring(val))
                error('HERBERT:unique_obj_container:invalid_argument',...
                    'convert_to_stream_f_string must be a string convertable to function. It is %s',...
                    class(val))
            end
            obj.convert_to_stream_f = str2func(val);
        end
        %
        function x = expose_unique_objects(self)
            %EXPOSE_UNIQUE_OBJECTS - return the cell array containing the
            % unique objects in this container. This provides the interface for
            % using this functionality outside of saveobj. It is allowed so
            % that users can scan the properties of this container without
            % repeating the scan for many duplicates. Note that this does break
            % the encapsulation of the class in some sense.

            x = self.unique_objects_;
        end

        function x = get.unique_objects(self)
            %GET.UNIQUE_OBJECTS Return the cell array containing the unique
            % objects in this container. This access is solely for saveobj.
            % Users wishing to do a scan by unique objects outside of saveobj
            % should use expose_unique_objects().

            x = self.unique_objects_;
        end

        function self = set.unique_objects(self, val)
            %SET.UNIQUE_OBJECTS Load a cell array or array of appropriate
            % objects into the container, e.g. from file
            %
            % Inputs:
            % -------
            % val = array or cellarray of unique objects to populate the
            % container.
            %
            % NB this set operation should only be done in environments such as
            % loadobj which disable combo arg checking

            if ~self.do_check_combo_arg_
                if ~iscell(val)
                    val = {val};
                end
                self.unique_objects_ = val;
            else
                error('HERBERT:unique_objects_container:invalid_set', ...
                    'attempt to set unique objects in container outside of loadobj');
            end
        end
        %
        function x = get.stored_hashes(self)
            %GET.STORED_HASHES - list the hashes corresponding to the unique
            % objects. Only really useful for debugging.
            x = self.stored_hashes_;
        end
        %
        function x = get.idx(self)
            %GET.IDX - get the indices of each stored object in the container
            % which point to the unique objects stored internally.
            x = self.idx_;
        end
        function self = set.idx(self,val)
            %SET.IDX - set the indices of each stored object in the container
            % which point to the unique objects stored internally. Really only
            % used by loadobj.
            if ~isnumeric(val)
                error('HERBERT:unique_obj_container:invalid_argument',...
                    'idx may be only array of numeric values, identifying the object position in the container');
            end
            if min(val)<=0
                error('HERBERT:unique_obj_container:invalid_argument',...
                    'idx are the indexes so they must be positive only. Minum of indexes provided is: %d', ...
                    min(val))
            end
            if ~self.do_check_combo_arg_
                self.idx_ = val(:)';
                self.n_duplicates_ = accumarray(self.idx_',1)';
            else
                error('HERBERT:unique_objects_container:invalid_set', ...
                    'attempt to set idx in container outside of loadobj');
            end
        end
        %
        function x = get.baseclass(self)
            %GET.BASECLASS - retrieve the baseclass for objects in this
            % container. If it is the empty string '' then any kind of object
            % may be stored.

            x = self.baseclass_;
        end
        function self = set.baseclass(self,val)
            %SET.BASECLASS - (re)set the baseclass. If any existing items
            % contained here do not conform to the new baseclass, then abort
            % the process.

            if ~(ischar(val)||isstring(val))
                val = class(val);
            end
            %self = remove_noncomplying_members_(self,val);
            if any( cellfun( @(x) ~isa(x,val), self.unique_objects_) )
                error('HERBERT:unique_objects_container:invalid_argument', ...
                    'existing objects in the container do not conform to this baseclass');
            end
            self.baseclass_ = val;

            if self.do_check_combo_arg_
                self = self.check_combo_arg(false);
            end
        end
        %
        function x = get.convert_to_stream_f(self)
            %GET.CONVERT_TO_STREAM - retrieve the hashing function
            x = self.convert_to_stream_f_;
        end
        function self = set.convert_to_stream_f(self,val)
            %SET.CONVERT_TO_STREAM - (re)set the hashing function
            % This may invalidate the contents by changing the hashing function
            % so should not be used if the container is not empty
            if ~(isempty(val)|| isa(val,'function_handle'))
                error('HERBERT:unique_objects_container:invalid_argument',...
                    'this method accepts function handles for serializing objects only')
            end
            if isequal(self.convert_to_stream_f_,val)
                return;
            end
            self.convert_to_stream_f_ = val;
            self.non_default_f_conversion_set_  = true;
            if self.do_check_combo_arg_
                self = self.check_combo_arg(true,false);
            end
        end
        %
        function x = get.n_duplicates(self)
            x = self.n_duplicates_;
        end
        %-----------------------------------------------------------------
        % Overloaded indexers
        function varargout = subsref(self,idxstr)
            if numel(self)>1 % input is array or cell of unique_object_containers
                [varargout{1:nargout}] = builtin('subsref',self,idxstr);
                return;
            end
            % overloaded indexing for retrieving object from container
            switch idxstr(1).type
                case {'()','{}'}
                    if iscell(self.unique_objects_)
                        b = idxstr(1).subs{:};
                        if isempty(self.unique_objects_)
                            varargout{1} = self.unique_objects_;
                        else
                            c = self.unique_objects_{self.idx_(b)};
                            if numel(idxstr)==1
                                varargout{1} = c;
                            else
                                idx2 = idxstr(2:end);
                                [varargout{1:nargout}] = builtin('subsref',c,idx2);
                            end
                        end
                    else
                        error('HERBERT:unique_objects_container:invalid_argument', ...
                            'braces for array storage');
                    end
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',self,idxstr);
            end % end switch
        end % end function subsref
        %
        function self = subsasgn(self,idxstr,varargin)
            % overloaded indexing for placing object to container

            % initial processing for indexes out of bounds
            % and add just after end
            if ~strcmp(idxstr(1).type,'.')
                val = varargin{1};
                nuix = idxstr(1).subs{:};
                if nuix < 1
                    error('HERBERT:unique_objects_container:invalid_argument', ...
                        'non-positive index not allowed');
                elseif nuix > numel(self.idx_)+1
                    error('HERBERT:unique_objects_container:invalid_argument', ...
                        'index outside legal range');
                elseif nuix == numel(self.idx_)+1
                    self = self.add(val);
                    return;
                end
            end

            % Having eliminated the above options, the assignment position
            % is within the existing data in the container. Use the replace
            % method to put the new object in the container.
            % the replacement method is the same for both types of
            % container; the duplication allows checking for incorrect
            % bracket use
            switch idxstr(1).type
                case {'()','{}'}
                    c = self.get(nuix);
                    if numel(idxstr)>0
                        idx2 = idxstr(2:end);
                        c = builtin('subsasgn',c,idx2,varargin{:});
                        val = c;
                    end
                    self = self.replace(val,nuix);
                case '.'
                    self = builtin('subsasgn',self,idxstr,varargin{:});
            end
        end % subsasgn

    end
    %----------------------------------------------------------------------
    % OTHER
    %----------------------------------------------------------------------
    methods
        function [is,unique_ind] = contains(obj,value)
            % check if the container has the objects of the class "value"
            % if the value is char, or the the object equal value, if the
            % value is the object of the kind, stored in container
            % Inputs:
            % value  -- the sample, to verify presence in the container
            % Outputs:
            % is      -- true if the sample is present in the container and
            %            false -- otherwise.
            % unique_ind
            %         -- if requested, the positions of the sample in the
            %            unique objects container
            [is,unique_ind] = contains_(obj,value,nargout);
        end

        function obj = replicate_runs(obj,n_objects)
            % function expands container onto specified number of runs.
            % only single unique object allowed to be present in the
            % container initially
            validateattributes(n_objects, {'numeric'}, {'>', 0, 'scalar'})
            if obj.n_unique ~= 1
                error('HERBERT:unique_objects_container:invalid_argument',...
                    'The method works only on containers containing a single unique run. This container contains %d unique runs.', ...
                    obj.n_unique);
            end

            obj.idx_ = ones(1,n_objects);
            obj.n_duplicates_(1) = n_objects;
        end

        function self = remove_noncomplying_members(self,new_class_name)
            self = remove_noncomplying_members_(self,new_class_name);
        end

        function newself = rename_all_blank(self)
            newself = unique_objects_container('baseclass',self.baseclass);
            for i=1:numel(self.idx)
                item = self.get(i);
                if isprop(item,'name')
                    item.name = '';
                end
                newself = newself.add(item);
            end
        end

        function hash = hashify(self,obj)
            % makes a hash from the argument object
            % which will be unique to any identical object
            %
            % Input:
            % - obj : object to be hashed
            % Output:
            % - hash : the resulting has, a row vector of uint8's
            %
            Engine = java.security.MessageDigest.getInstance('MD5');
            if isa(obj,'serializable') && ~self.non_default_f_conversion_set_
                % use default serializer, build up by us for serializable objects
                Engine.update(obj.serialize());
            else
                %convert_to_stream_f_ = @getByteStreamFromArray;
                Engine.update(self.convert_to_stream_f_(obj));
            end
            hash = typecast(Engine.digest,'uint8');
            hash = char(hash');
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
                hash = self.hashify(self.unique_objects{i});
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

    methods

        function [ix, hash] = find_in_container(self,obj)
            %FIND_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj : the object which may or may not be uniquely contained
            %         in self
            % Output:
            % - ix   : the index of the unique object in self.unique_objects_,
            %          if it is stored, otherwise empty []
            % - hash : the hash of the object from hashify
            %
            hash = self.hashify(obj);
            if isempty(self.stored_hashes_)
                ix = []; % object not stored as nothing is stored
            else
                % get intersection of array stored_hashes_ with (single) array
                % hash from hashify. Calculates the index of the hash in
                % stored_hashes.
                ix = find(ismember(self.stored_hashes_,hash));
            end
        end
    end

    methods
        function self = unique_objects_container(varargin)
            %UNIQUE_OBJECTS_CONTAINER construct the container
            % Input:
            % - parameter: 'basecase' - charstring name of basecase of
            %                           contained objects
            % - parameter: 'convert_to_stream_f' - function doing the stream
            %                               conversion for hashify

            flds = self.saveableFields();
            flds = [flds(:);'convert_to_stream_f']; % convert_to_stream
            % function is not present in saveable properties but may be present
            % as input too.
            % standard serializable constructor
            self = self.set_positional_and_key_val_arguments(...
                flds,false,varargin{:});
        end

        function n = get.n_objects(self)
            %GET.N_OBJECTS - retrieve size of container without duplicate
            % compression. This functionality is also provided by get.n_runs to
            % provide naming by the normal usage of this container for storing
            % instruments and samples in Horace. The two should be kept
            % synchronized.

            n = numel(self.idx_);
        end
        function n = get.n_runs(self)
            %GET.N_RUNS - retrieve size of container without duplicate
            % compression. This functionality duplicates that provided by
            % get.n_objects so that naming by the normal usage of this container for storing
            % instruments and samples in Horace is available. Both properties
            % should be kept synchronized.

            n = numel(self.idx_);
        end
        function n =  get_nruns(self)
            %GET_NRUNS non-dependent-property form of n_runs
            % for use with arrayfun in object_lookup
            
            n = numel(self.idx_);
        end
        function n = runs_sz(self)
            %RUNS_SZ converts n_runs to the form of output from size
            % to put unique_objectss_container on the same footing as
            % array/cell in object_lookup
            
            n = numel(self.idx_);
            n = [n 1];
        end

        function n = get.n_unique(self)
            n = numel(self.unique_objects_);
        end

        function sset = get_subset(self,indices)
            sset = unique_objects_container('baseclass',self.baseclass);
            for i = indices
                item = self.get(i);
                [sset,~] = sset.add(item);
            end
        end

        function [self,nuix] = add(self,obj)
            %ADD adds an object to the container
            % Input:
            % - obj : the object to be added. This may duplicate an object
            %         in the container, but it will be noted as a duplicate
            %         and will be given its own index, which it returns
            %    or   cellarray or array of objects to add
            % Output:
            % - self : the changed container (as this is a value class)
            % - nuix : the non-unique index for this object
            %     or   array of such indexes if multiple objects were
            %          added
            %
            % it may be a duplicate but it is still the n'th object you
            % added to the container. The number of additions to the
            % container is implicit in the size of idx_.

            % process addition of multiple objects at once.
            if ~ischar(obj) && (numel(obj)>1 || iscell(obj))
                nobj = numel(obj);
                nuix = zeros(1,nobj);
                if iscell(obj)
                    for i = 1:nobj
                        [self,nuix(i)]=self.add(obj{i});
                    end
                else
                    for i = 1:nobj
                        [self,nuix(i)]=self.add(obj(i));
                    end

                end
                return;
            end
            % check that obj is of the appropriate base class
            if ~isempty(self.baseclass_) && ~isa(obj, self.baseclass_)
                warning('HERBERT:unique_objects_container:invalid_argument', ...
                    'not correct base class; object was not added');
                nuix = 0;
                return;
            end
            [self,nuix] = add_single_(self,obj);

        end % add()

        function self = replace(self,obj,nuix)
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
            if ~isempty(self.baseclass_) && ~isa(obj, self.baseclass_)
                warning('HERBERT:unique_objects_container:invalid_argument', ...
                    'not correct base class; object was not replaced');
                return;
            end

            % check if you're trying to replace an object with an identical
            % one. If so silently return.
            objhash = self.hashify(obj);
            curhash = self.stored_hashes_{self.idx_(nuix)};
            if isequal(objhash, curhash)
                return;
            end

            % reduce the number of duplicates of the item to be replaced by
            % 1.
            oldix = self.idx_(nuix);
            self.n_duplicates_(oldix) = self.n_duplicates_(oldix)-1;
            % all existing objects with the hash specified were removed.
            no_more_duplicates = self.n_duplicates_(oldix) == 0;

            % Find if the object is already in the container. ix is
            % returned as the index to the object in the container.
            % hash is returned as the hash of the object. If ix is empty
            % then the object is not in the container.
            [ix,hash] = self.find_in_container(obj);

            % If the object is not in the container.
            % store the hash in the stored hashes
            % store the object in the stored objects
            % take the index of the last stored object as the object index
            if isempty(ix) % means obj not in container and should be added
                if no_more_duplicates
                    self.unique_objects_{oldix} = obj;
                    self.stored_hashes_{oldix} = hash;
                    self.n_duplicates_(oldix) = self.n_duplicates_(oldix)+1;
                else
                    self.unique_objects_ = [self.unique_objects_(:);{obj}]';

                    self.stored_hashes_ = [self.stored_hashes_(:);hash]';
                    self.idx_(nuix) = numel(self.unique_objects_);
                    self.n_duplicates_ = [self.n_duplicates_(:)', 1];
                end
                % if it is in the container, then ix is the unique object index
                % in unique_objects_ and is put into idx_ as the unique index
                % for the new object
            else
                if no_more_duplicates
                    % need to remove the old object by replacing it with
                    % the previous last object in unique_objects_


                    % collect the final unique object currently in the
                    % container
                    lastobj = self.unique_objects_{end};
                    lasthash = self.stored_hashes_{end};
                    lastidx = numel(self.unique_objects_);

                    if oldix<lastidx
                        % oldix is the location where there are no more
                        % duplicates, put the last object here
                        self.unique_objects_{oldix} = lastobj;
                        self.stored_hashes_{oldix} = lasthash;
                        self.n_duplicates_(oldix) = self.n_duplicates_(lastidx);

                        % reference all non-unique objects equivalent to the
                        % last unique object as now referring to this oldix
                        % location
                        self.idx_(self.idx_==lastidx) = oldix;
                    end

                    % if the existing item was the last in stored, then
                    % make it the new location
                    if ix==lastidx
                        ix=oldix;
                    end

                    % reduce the size of the unique object arrays
                    self.unique_objects_(end)=[];
                    self.stored_hashes_(end) = [];
                    self.n_duplicates_(end) = [];

                    % do the replacement
                    self.idx_(nuix) = ix;
                    self.n_duplicates_(ix) = self.n_duplicates_(ix)+1;

                else
                    self.idx_(nuix) = ix;
                    self.n_duplicates_(ix) = self.n_duplicates_(ix)+1;
                end
            end
        end % replace()

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
            ix = self.idx_(nuix);
            obj = self.unique_objects{ix};
            % alternative implementation would use subsref for '()' case, but this
            % requires additional code to deal with '.' when calling
            % methods.
        end

        function list(self,field)
            %LIST - method for debugging use only
            % lists the non-unique and unique indices for each object
            % together with a chosen field from each object to identify it.
            % This may well be 'name' but no restriction is placed on what
            % fields the objects may have, so this allows alternatives.

            for i=1:numel(self.idx_)
                uix = self.idx_(i);
                fld = self.unique_objects_{uix}.(field);
                disp([num2str(i) '; uix=' num2str(uix)]);
                disp(fld);
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
            newself = unique_objects_container('baseclass',self.baseclass);%,'convert_to_stream_f',self.convert_to_stream_f');
            % It is unclear why specifying convert_to_stream_f in the
            % constructor causes a failure but it works if specified next.
            newself.convert_to_stream_f = self.convert_to_stream_f;
            for i=1:self.n_objects
                newself = newself.add(self.get(i));
            end
        end
        
        function field_vals = get_unique_field(self, field)
            s1 = self.get(1);
            v = s1.(field);
            field_vals = unique_objects_container(class(v));
            for ii=1:self.n_runs
                sii = self.get(ii);
                v = sii.(field);
                field_vals = field_vals.add(v);
            end
        end


    end % end methods (general)
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    properties(Constant,Access=private)
        fields_to_save_ = {
            'baseclass',     ...
            'unique_objects',...
            'idx',           ...
            'conv_func_string'};
    end

    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end

        function flds = saveableFields(obj)
            % get independent fields, which fully define the state of the
            % serializable object.
            if obj.non_default_f_conversion_set_
                flds = unique_objects_container.fields_to_save_;
            else % do not store conversion function
                flds = unique_objects_container.fields_to_save_(1:end-1);
            end
        end

        function obj = check_combo_arg(obj,do_rehashify,with_checks)
            % runs after changing property or number of properties to check
            % the consistency of the changes against all other relevant
            % properties
            %
            % Inputs:
            % do_rehashify -- if true, run rehashify procedure. If not
            %                 provided, assumed true
            % with_checks  -- if true, each following hash is compared with
            %                 the previous hashes and if coincedence found,
            %                 throw the error. Necessary when replacing the
            %                 unique_objects to check that new objects are
            %                 indeed unique. The default is false.
            if nargin == 1
                do_rehashify = true;
                with_checks  = false;
            elseif nargin == 2
                with_checks  = false;
            end
            obj = check_combo_arg_(obj,do_rehashify,with_checks);
        end
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = unique_objects_container();
            obj = loadobj@serializable(S,obj);
            if obj.do_check_combo_arg
                obj.check_combo_arg(true,true);
            end
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
                            out = out.add( objs{ii}.get(jj) );
                        end
                    end
                else
                    out = objs(1);
                    for ii=2:numel(objs)
                        for jj=1:objs(ii).n_runs
                            out = out.add( objs(ii).get(jj) );
                        end
                    end
                end
            end
        end
        
    end % static methods

end % classdef unique_objects_container

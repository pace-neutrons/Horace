classdef unique_objects_container < serializable
    %UNIQUE_OBJECTS_CONTAINER Turn an instrument-type object into a hash.
    %   Uses the undocumented getByteStreamFromArray to perform the
    %   conversion.
    % Functionality:
    % - add new object to the container with add(...) - stores only unique
    % objects but keeps a non-unique index to this addition
    % - get an object from that unique index

    properties (Access=protected)
        unique_objects_=cell(1,0); % the actual unique objects - initialised in constructor by type
        stored_hashes_ = cell(1,0);  % their hashes are stored
        idx_ = zeros(1,0);   % array of unique indices for each non-unique object added
        % for the stream converter used by hashify defaults to this
        % undocumented java function

        baseclass_ = ''; % if not empty, name of the baseclass suitable for isa calls
        % (default respecified in constructor inputParser)
        n_duplicates_ = zeros(1,0);
        % defaults to this undocumented java function handle
        convert_to_stream_f_ = @getByteStreamFromArray; 
    end
    properties(Access = private)
        % is set to true if we decide not to use default stream conversion
        % function
        non_default_f_conversion_set_ = false;
    end

    properties (Dependent)
        n_runs;
        n_unique;
        %
        baseclass;
        idx;
        unique_objects;

        n_duplicates;
    end
    properties(Dependent,Hidden)
        %string representation of the function, used to produce hashes from
        % the object. Needed for simple saveobj/loadob into not-Matlab binary
        % files
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
            val = func2str(obj.convert_to_stream_f_);
        end
        function obj = set.conv_func_string(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HERBERT:unique_obj_container:invalid_argument',...
                    'convert_to_stream_f_string must be a string convertable to function. It is %s',...
                    class(val))
            end
            obj.convert_to_stream_f = str2func(val);
        end
        %
        function x = get.unique_objects(self)
            x = self.unique_objects_;
        end
        function self = set.unique_objects(self, val)
            if ~iscell(val)
                val = {val};
            end
            self.unique_objects_ = val;
            if self.do_check_combo_arg_
                self = self.check_combo_arg(true,true);
            end
        end
        %
        function x = get.stored_hashes(self)
            x = self.stored_hashes_;
        end
        %
        function x = get.idx(self)
            x = self.idx_;
        end
        function self = set.idx(self,val)
            if ~isnumeric(val)
                error('HERBERT:unique_obj_container:invalid_argument',...
                    'idx may be only array of numeric values, identifying the object position in the container');
            end
            if min(val)<=0
                error('HERBERT:unique_obj_container:invalid_argument',...
                    'idx are the indexes so they must be positive only. Minum of indexes provided is: %d', ...
                    min(val))
            end
            self.idx_ = val(:)';
            self.n_duplicates_ = accumarray(self.idx_',1)';
            if self.do_check_combo_arg_
                self = self.check_combo_arg(false);
            end
        end
        %
        function x = get.baseclass(self)
            x = self.baseclass_;
        end
        function self = set.baseclass(self,val)
            if ~(ischar(val)||isstring(val))
                val = class(val);
            end
            self = remove_noncomplying_members_(self,val);
            self.baseclass_ = val;

            if self.do_check_combo_arg_
                self = self.check_combo_arg(false);
            end
        end
        %
        function x = get.convert_to_stream_f(self)
            x = self.convert_to_stream_f_;
        end
        function self = set.convert_to_stream_f(self,val)
            if ~(isempty(val)|| isa(val,'function_handle'))
                error('HERBERT:unique_objects_container:invalid_argument',...
                    'this method accepts function handles for serializing obhects only')
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
            % overloaded indexing for retrieving object from container
            switch idxstr(1).type
                case {'()','{}'}
                    if iscell(self.unique_objects_)
                        b = idxstr(1).subs{:};
                        if isempty(self.unique_objects_)
                            varargout{1} = self.unique_objects_;
                        else
                            varargout{1} = self.unique_objects_{self.idx_(b)};
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
        function obj = expand_runs(obj,n_runs)
            % function expands container onto specified number of runs.
            % only single unique object allowed to be present in the
            % container initially
            if ~isnumeric(n_runs) || n_runs<1 || ~isscalar(n_runs)
                error('HERBERT:unique_objects_container:invalid_argument',...
                    'n_runs can be numeric positive scalar only. It is %s', ...
                    class(n_runs))
            end
            if obj.n_unique>1
                error('HERBERT:unique_objects_container:invalid_argument',...
                    'The method works only on container containing single unique object and single run. This container contains %d objects and %d runs', ...
                    obj.n_unique,obj.n_runs);
            end

            obj.idx_ = ones(1,n_runs);
            obj.n_duplicates_(1) = n_runs;
        end
        %
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
        %
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
            %UNIQUE_OBJECTS_CONTAINER create the container
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


        function n = get.n_runs(self)
            n = numel(self.idx_);
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
                    self.unique_objects_ = cat(1, self.unique_objects_, {obj});

                    self.stored_hashes_ = [self.stored_hashes_(:),hash];
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
            for i=1:self.n_runs
                newself = newself.add(self.get(i));
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
        %
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
        end
    end % static methods

end % classdef unique_objects_container

classdef unique_objects_container < serializable
    %UNIQUE_OBJECTS_CONTAINER Turn an instrument-type object into a hash.
    %   Uses the undocumented getByteStreamFromArray to perform the
    %   conversion.
    % Functionality:
    % - add new object to the container with add(...) - stores only unique
    % objects but keeps a non-unique index to this addition
    % - get an object from that unique index

    properties (Access=private)
        stored_objects_; % the actual unique objects - initialised in constructor by type
        stored_hashes_ = [];  % their hashes are stored
        idx_ = [];   % array of unique indices for each non-unique object added
        convert_to_stream_ = @getByteStreamFromArray; % function handle for the stream converter used by hashify
        % defaults to this undocumented java
        % function (default respecified in
        % constructor inputParser)
        baseclass_ = ''; % if not empty, name of the baseclass suitable for isa calls
        % (default respecified in constructor inputParser)
        n_duplicates_ = [];
    end

    properties (Dependent) % defined only for debug reporting purposes
        stored_objects;
        stored_hashes;
        idx;
        baseclass;
        n_duplicates;
        convert_to_stream;
    end

    methods % Dependent props get functions - defined only for reporting purposes
        function x = get.stored_objects(self)
            x = self.stored_objects_;
        end
        function self = set.stored_objects(self, val)
            self.stored_objects_ = val;
        end

        function x = get.stored_hashes(self)
            x = self.stored_hashes_;
        end
        function self = set.stored_hashes(self, val)
            self.stored_hashes_= val;
        end

        function x = get.idx(self)
            x = self.idx_;
        end
        function self = set.idx(self,val)
            self.idx_ = val;
        end

        function x = get.baseclass(self)
            x = self.baseclass_;
        end
        function self = set.baseclass(self,val)
            self.baseclass_ = val;
        end

        function x = get.convert_to_stream(self)
            x = self.convert_to_stream_;
        end
        function self = set.convert_to_stream(self,val)
            self.convert_to_stream_ = val;
        end

        function x = get.n_duplicates(self)
            x = self.n_duplicates_;
        end
        function self = set.n_duplicates(self,val)
            self.n_duplicates_ = val;
        end
    end

    % SERIALIZABLE interface
    %------------------------------------------------------------------
    properties(Constant,Access=private)
        fields_to_save_ = {'stored_objects',...
            'stored_hashes', ...
            'idx',           ...
            'baseclass',     ...
            'convert_to_stream',...
            'n_duplicates'};
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
        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = unique_objects_container.fields_to_save_;
        end
    end

    % OTHER
    %------------------------------------------------------------------

    methods
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
            %convert_to_stream_ = @getByteStreamFromArray;
            Engine.update(self.convert_to_stream_(obj));
            hash = typecast(Engine.digest,'uint8');
            hash = hash';
        end
    end

    methods

        function [ix, hash] = find_in_container(self,obj)
            %FIND_IN_CONTAINER Finds if obj is contained in self
            % Input:
            % - obj : the object which may or may not be uniquely contained
            %         in self
            % Output:
            % - ix   : the index of the unique object in self.stored_objects_,
            %          if it is stored, otherwise empty []
            % - hash : the hash of the object from hashify
            %
            hash = self.hashify(obj);
            if isempty(self.stored_hashes_)
                ix = []; % object not stored as nothing is stored
            else
                % get intersection of array stored_hashes_ with (single) array
                % hash from hashify. Calculates the index of the hash in
                % stored_hashes. Argout(1), the common data, is just the
                % hash so no need to return it. Argout(2), the index in
                % hash, is 1 (single item) so no need to return it.
                % Argout(3), the index in self.stored_hashes_, is the index
                % we need.
                [~,~,ix] = intersect(hash, self.stored_hashes_, 'rows');
            end
        end
    end

    methods
        function self = unique_objects_container(varargin)
            %UNIQUE_OBJECTS_CONTAINER create the container
            % Input:
            % - parameter: 'basecase' - charstring name of basecase of
            %                           contained objects
            % - parameter: 'convert_to_stream' - function doing the stream
            %                                    conversion for hashify

            p = inputParser;
            addParameter(p,'type','',@ischar);
            addParameter(p,'baseclass','',@ischar);
            check_function_handle = @(x) isa(x,'function_handle');
            addParameter(p,'convert_to_stream',@getByteStreamFromArray,check_function_handle);
            parse(p,varargin{:});

            if isempty(p.Results.type)
                error('HORACE:unique_objects_container:invalid_argument','must specify container type () or {}');
            end

            if strcmp(p.Results.type, '{}')
                self.stored_objects_ = {};
            else
                self.stored_objects_ = [];
            end
            self.baseclass_ = p.Results.baseclass;
            self.convert_to_stream_ = p.Results.convert_to_stream;
        end


        function [self,nuix] = add(self,obj)
            %ADD adds an object to the container
            % Input:
            % - obj : the object to be added. This may duplicate an object
            %         in the container, but it will be noted as a duplicate
            %         and will be given its own index, which is returns
            % Output:
            % - self : the changed container (as this is a value class)
            % - nuix : the non-unique index for this object
            %
            % it may be a duplicate but it is still the n'th object you
            % added to the container. The number of additions to the
            % container is implicit in the size of idx_.

            % check that obj is of the appropriate base class
            if ~isempty(self.baseclass_)
                if ~isa(obj, self.baseclass_)
                    warning('HERBERT:unique_objects_container:invalid_argument', ...
                        'not correct base class; object was not added');
                    nuix = 0;
                    return;
                end
            end

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
                self.stored_hashes_ = cat(1, self.stored_hashes_, hash);
                if iscell(self.stored_objects_)
                    self.stored_objects_ = cat(1, self.stored_objects_, {obj});
                else
                    self.stored_objects_ = cat(1, self.stored_objects_, (obj));
                end
                ix = numel(self.stored_objects_);
                self.n_duplicates_ = [self.n_duplicates_(:)', 1];
            else
                self.n_duplicates_(ix) = self.n_duplicates_(ix)+1;
            end

            % add index ix to the array of indices
            % know the non-unique object index - the number of times you
            % added an object to the container - say k. idx_(k) is the
            % index of the unique object in the container.
            self.idx_ = [self.idx_(:)', ix]; % alternative syntax: cat(2,self.idx_,ix);
            nuix = numel(self.idx_);
        end % add()

        function self = replace(self,obj,nuix)
            %REPLACE replaces the object at non-unique index nuix in the container
            % Input:
            % - obj : the object to be added. This may duplicate an object
            %         in the container, but it will be noted as a
            %         duplicate; it is positioned at index nuix
            % - nuix : position at which obj will be inserted. nuix must
            %          be in the range 1:numel(
            % Output:
            % - self : the changed container (as this is a value class)
            %
            % it may be a duplicate but it is still the n'th object you
            % added to the container. The number of additions to the
            % container is implicit in the size of idx_.

            % check that obj is of the appropriate base class
            if ~isempty(self.baseclass_)
                if ~isa(obj, self.baseclass_)
                    warning('HERBERT:unique_objects_container:invalid_argument', ...
                        'not correct base class; object was not replaced');
                    return;
                end
            end

            % check if you're trying to replace an object with an identical
            % one. If so silently return.
            objhash = self.hashify(obj);
            curhash = self.stored_hashes_(self.idx_(nuix));
            if isequal(objhash, curhash)
                return;
            end

            % reduce the number of duplicates of the item to be replaced by
            % 1.
            oldix = self.idx_(nuix);
            self.n_duplicates_(oldix) = self.n_duplicates_(oldix)-1;
            if self.n_duplicates_(oldix) == 0
                warning('HERBERT:unique_objects_container:invalid_argument', ...
                    ['one of the objects in the container is now unreferenced ' ...
                    'after a replacement']);
            end

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
                self.stored_hashes_ = cat(1, self.stored_hashes_, hash);
                if iscell(self.stored_objects_)
                    self.stored_objects_ = cat(1, self.stored_objects_, {obj});
                else
                    self.stored_objects_ = cat(1, self.stored_objects_, (obj));
                end
                self.idx_(nuix) = numel(self.stored_objects_);
                self.n_duplicates_ = [self.n_duplicates_(:)', 1];
                % if it is in the container, then ix is the unique object index
                % in stored_objects_ and is put into idx_ as the unique index
                % for the new object
            else
                self.idx_(nuix) = ix;
                self.n_duplicates_(ix) = self.n_duplicates_(ix)+1;
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
            if iscell(self.stored_objects_)
                obj = self.stored_objects{ix};
            else
                obj = self.stored_objects(ix);
            end
            % alternative implementation would use subsref for '()' case, but this
            % requires additional code to deal with '.' when calling
            % methods.
        end

        function out = disp(self)
            out = sprintf(['Unique objects container with %i elements and ',...
                '%i indexed unique elements and %i stored unique elements'], ...
                numel(self.idx_), ...
                numel(unique(self.idx_)), ...
                numel(self.stored_objects_));

            if nargout == 0
                disp(out);
            end
        end

        function varargout = subsref(self,idxstr)
            switch idxstr(1).type
                case '()'
                    if ~iscell(self.stored_objects_)
                        b = idxstr(1).subs{:};
                        varargout{1} = self.stored_objects_(self.idx_(b));
                    else
                        error('HERBERT:unique_objects_container:invalid_argument','parentheses for cell storage');
                    end
                case '{}'
                    if iscell(self.stored_objects_)
                        b = idxstr(1).subs{:};
                        varargout{1} = self.stored_objects_{self.idx_(b)};
                    else
                        error('HERBERT:unique_objects_container:invalid_argument','braces for array storage');
                    end
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',self,idxstr);
            end % end switch
        end % end function subsref

        function self = subsasgn(self,idxstr,varargin)

            % initial processing for indexes out of bounds
            % and add just after end
            if ~strcmp(idxstr(1).type,'.')
                val = varargin{1};
                nuix = idxstr(1).subs{:};
                if nuix < 1
                    error('HERBERT:unique_objects_container:invalid_argument','non-positive index not allowed');
                elseif nuix > numel(self.idx_)+1
                    error('HERBERT:unique_objects_container:invalid_argument','index outside legal range');
                elseif nuix == numel(self.idx_)+1
                    [self,~] = self.add(val);
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
                case '()'
                    if ~iscell(self.stored_objects_)
                        self = self.replace(val,nuix);
                    else
                        error('HERBERT:unique_objects_container:invalid_argument','parentheses for cell replacement');
                    end
                case '{}'
                    if iscell(self.stored_objects_)
                        self = self.replace(val,nuix);
                    else
                        error('HERBERT:unique_objects_container:invalid_argument','braces for array replacement');
                    end
                case '.'
                    self = builtin('subsasgn',self,idxstr,varargin{:});
            end
        end % replace()

        function list(self,field)
            %LIST - method for debugging use only
            % lists the non-unique and unique indices for each object
            % together with a chosen field from each object to identify it.
            % This may well be 'name' but no restriction is placed on what
            % fields the objects may have, so this allows alternatives.

            for i=1:numel(self.idx_)
                uix = self.idx_(i);
                if iscell(self.stored_objects_)
                    fld = self.stored_objects_{uix}.(field);
                else
                    fld = self.stored_objects_(uix).(field);
                end
                disp([num2str(i) '; uix=' num2str(uix)]);
                disp(fld);
            end
        end

    end % end methods (general)

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = unique_objects_container();
            obj = loadobj@serializable(S,obj);
        end
    end % static methods

end % classdef unique_objects_container


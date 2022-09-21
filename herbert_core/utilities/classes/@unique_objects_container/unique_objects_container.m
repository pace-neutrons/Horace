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
        type;
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
            self = self.rehashify_all();
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
        
        function x = get.type(self)
            if iscell(self.stored_objects_)
                x = '{}';
            else
                x = '[]';
            end
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
        fields_to_save_ = {'stored_objects',... %'stored_hashes', ...
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
        function newself = rename_all_blank(self)
            newself = unique_objects_container('type',self.type,'baseclass',self.baseclass);
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
            %convert_to_stream_ = @getByteStreamFromArray;
            Engine.update(self.convert_to_stream_(obj));
            hash = typecast(Engine.digest,'uint8');
            hash = hash';
        end
        
        function newself = rehashify_all(self)
            newself = self;
            newself.stored_hashes_ = zeros(numel(self.stored_objects_),16);
            for i=1:numel(self.stored_objects_)
                newself.stored_hashes(i,:) = self.hashify(self.stored_objects{i});
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
            addParameter(p,'type','{}',@ischar); % default type for vanilla constructor
            addParameter(p,'baseclass','',@ischar);
            check_function_handle = @(x) isa(x,'function_handle');
            addParameter(p,'convert_to_stream',@getByteStreamFromArray,check_function_handle);
            parse(p,varargin{:});
            
            
            if strcmp(p.Results.type, '{}')
                self.stored_objects_ = {};
            else
                self.stored_objects_ = [];
            end
            self.baseclass_ = p.Results.baseclass;
            self.convert_to_stream_ = p.Results.convert_to_stream;
        end
        
        function n = n_total(self)
            n = numel(self.stored_objects_);
        end
        
        function n = n_runs(self)
            n = numel(self.idx_);
        end
        
        function istype = check_type(self, type)
            N = numel(self.stored_objects_);
            istype = true(1,N);
            for i=1:numel(self.stored_objects_)
                if iscell(self.stored_objects_)
                    istype(i) = isa(self.stored_objects_{i},type);
                else
                    istype(i) = isa(self.stored_objects_(i),type);
                end
            end
        end
        
        function sset = get_subset(self,indices)
            sset = unique_objects_container('type',self.type,'baseclass',self.baseclass);
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
            %          be in the range 1:numel(self.idx_)
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
            curhash = self.stored_hashes_(self.idx_(nuix),:);
            if isequal(objhash, curhash)
                return;
            end
            
            % reduce the number of duplicates of the item to be replaced by
            % 1.
            oldix = self.idx_(nuix);
            self.n_duplicates_(oldix) = self.n_duplicates_(oldix)-1;
            no_more_duplicates = 0;
            if self.n_duplicates_(oldix) == 0
                no_more_duplicates = 1;
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
                if no_more_duplicates
                    if iscell(self.stored_objects_)
                        self.stored_objects{oldix} = obj;
                    else
                        self.stored_objects(oldix) = obj;
                    end
                    self.stored_hashes(oldix,:) = hash;
                    self.n_duplicates_(oldix) = self.n_duplicates_(oldix)+1;
                else
                    if iscell(self.stored_objects_)
                        self.stored_objects_ = cat(1, self.stored_objects_, {obj});
                    else
                        self.stored_objects_ = cat(1, self.stored_objects_, (obj));
                    end
                    self.stored_hashes_ = cat(1, self.stored_hashes_, hash);
                    self.idx_(nuix) = numel(self.stored_objects_);
                    self.n_duplicates_ = [self.n_duplicates_(:)', 1];
                end
            % if it is in the container, then ix is the unique object index
            % in stored_objects_ and is put into idx_ as the unique index
            % for the new object
            else
                if no_more_duplicates
                    % need to remove the old object by replacing it with
                    % the previous last object in stored_objects_
                    
                    
                    % collect the final unique object currently in the
                    % container
                    if iscell(self.stored_objects_)
                        lastobj = self.stored_objects_{end};
                    else
                        lastobj = self.stored_objects_(end);
                    end
                    lasthash = self.stored_hashes(end,:);
                    lastidx = numel(self.stored_objects_);
                    
                    if oldix<lastidx
                        % oldix is the location where there are no more
                        % duplicates, put the last object here
                        if iscell(self.stored_objects_)
                            self.stored_objects{oldix} = lastobj;
                        else
                            self.stored_objects(oldix) = lastobj;
                        end
                        self.stored_hashes(oldix,:) = lasthash;
                        self.n_duplicates(oldix) = self.n_duplicates(lastidx);

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
                    self.stored_objects_(end)=[];
                    self.stored_hashes_(end,:) = [];
                    self.n_duplicates(end) = [];
                    
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
                    if strcmp(idxstr(1).type, self.type)
                        [self,~] = self.add(val);
                    else
                        error('bracket type for indexing does not match container');
                    end
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
        
        function newself = reorder(self)
            % the internal order of unique_objects_container is not well
            % defined. As long as idx and stored_objects between them
            % return the correct object, the internal order does not
            % matter.
            % However, in test comparisons, this can cause false failures.
            % This reordering provides a standard order when comparing.
            % This is only used for tests and so its efficiency is not
            % important.
            newself = unique_objects_container('type',self.type,'baseclass',self.baseclass);%,'convert_to_stream',self.convert_to_stream');
            % It is unclear why specifying convert_to_stream in the
            % constructor causes a failure but it works if specified next.
            newself.convert_to_stream = self.convert_to_stream;
            for i=1:self.n_runs
                newself = newself.add(self.get(i));
            end
        end

    end % end methods (general)
    
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = unique_objects_container();
            obj = loadobj@serializable(S,obj);
            obj = obj.rehashify_all();
        end
    end % static methods
    
end % classdef unique_objects_container


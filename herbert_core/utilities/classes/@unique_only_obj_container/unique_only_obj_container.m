classdef unique_only_obj_container < ObjContainersBase
    %UNQUE_ONLY_OBJ_CONTAINER contains only unique objects prviding
    %permanent references (pointers) to these objects
    %

    properties (Access=protected)
        stored_hashes_ = cell(1,0);  % their hashes are stored
        % (default respecified in constructor inputParser)
        n_duplicates_ = zeros(1,0);
    end
    properties(Dependent,Hidden)
        % property containing list of stored hashes for unique objects for
        % comparison with other objects
        stored_hashes;
    end
    %----------------------------------------------------------------------
    % Dependent properties set/get functions specific to subclass.
    methods
        function self = unique_only_obj_container(varargin)
            %UNIQUE_ONLY_OBJ_CONTAINER construct the container
            % Input:
            % - parameter: 'basecase' - charstring name of basecase of
            %                           contained objects
            % - parameter: 'convert_to_stream_f' - function doing the stream
            %                               conversion for hashify
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
    end
    %----------------------------------------------------------------------
    % SATISFY CONTAINERS INTERFACE
    %----------------------------------------------------------------------
    methods
        function uoca = expose_unique_objects(self)
            % expose cellarray of unique objects this container subscribes to.
            uoca = get_unique_objects(self);
        end
        function [is,unique_ind,obj] = contains(obj,value)
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
            % obj     -- obj, which if hashable, contains calculated hash
            [is,unique_ind,obj] = contains_(obj,value,nargout);
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

        function sset = get_subset(self,indices)
            sset = unique_objects_container('baseclass',self.baseclass);
            for i = indices
                item = self.get(i);
                [sset,~] = sset.add(item);
            end
        end
        function [self,uidx] = add(self,obj)
            %ADD_IF_NEW adds an object to the container if it is not
            %already there. If object is already in the container,
            %number of object duplicates increases.
            %
            % Returns:
            % self   -- modified container with object present or duplicate
            %           counter increased.
            % uidx   -- unique index of object in the container
            %
            if ~ischar(obj) && numel(obj)>1 || iscell(obj)
                nobj = numel(obj);
                uidx = zeros(1,nobj);
                if iscell(obj)
                    for i = 1:nobj
                        [self,uidx(i)]=self.add(obj{i});
                    end
                else
                    for i = 1:nobj
                        [self,uidx(i)]=self.add(obj(i));
                    end
                end
                return;
            end
            [self,uidx] = add_if_new_single_(self,obj);
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
            self = replace_(self,obj,nuix);
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
            self.check_if_range_allowed(nuix);
            ix = self.idx_(nuix);
            if numel(nuix) == 1
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
                    self.n_objects,numel(val));
            end

            self.unique_objects_ = val;
            check_existing = ~isempty(self.stored_hashes_)||(isempty(self.idx_));
            self.stored_hashes_  = {};
            if self.do_check_combo_arg_
                self = self.check_combo_arg(check_existing);
            end
        end
        function n = get_n_nunique(self)
            % get number of unique objects in the container
            n = numel(self.unique_objects_);
        end
    end
    %----------------------------------------------------------------------
    % UNIQUE_OBJ CONTAINERS SPECIFIC. Think about removing or making private
    % at least for majority of them.
    %----------------------------------------------------------------------
    methods

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
            'n_duplicates'...
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
    end % static methods
end % classdef unique_objects_container

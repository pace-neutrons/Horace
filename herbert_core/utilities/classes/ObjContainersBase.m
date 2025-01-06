classdef ObjContainersBase < serializable
    % ObjContainersBase Provides common interface for various object
    % containers
    properties (Dependent)
        baseclass;        % Name of the class or parent class, this container holds
        n_objects;        % number of unique objects referred by this container
        n_unique;         % number of unique objects among all objects container refers
        %
        idx;              % object indices pointing to positions of actual
        %                   objects in the container
        unique_objects;   % return class-appropriate unique objects.
        %                   result differs for different children! (TODO --
        %                   redesign?)
        % number of duplicated references to the objects, stored in the
        % container
        n_duplicates;
    end
    properties (Dependent,Hidden=true)
        % equvalent to n_objects but used in cases where it has physical
        % meaning -- numper of experimental runs. Hidden not to polute main
        % interface.
        n_runs
    end
    properties (Access=protected)
        baseclass_      = '';         % if not empty, name of the baseclass
        %                               this container holds. Should be suitable for isa() calls
        idx_            = zeros(1,0); %  array of unique global indices of objects in the container
        unique_objects_ = cell(1,0);  % storage for unique objects.
    end
    properties(Access = private)
        % service property used by set.baceclass to validate container
        % integrity vrt. the change of the baseclass name
        baseclass_name_trial_;
    end
    %----------------------------------------------------------------------
    % Dependent properties set/get functions and subsrefs/subsassign
    % methods implemented globally
    methods
        function x    = get.baseclass(self)
            %GET.BASECLASS - retrieve the baseclass for objects in this
            % container. If it is the empty string '' then any kind of object
            % may be stored.
            x = self.baseclass_;
        end
        function self = set.baseclass(self,val)
            %SET.BASECLASS - (re)set the baseclass. If any existing items
            % contained here do not conform to the new baseclass, then abort
            % the process.
            if ~istext(val)
                val = class(val);
            end
            self.baseclass_name_trial_ = val;
            if self.do_check_combo_arg_
                self = self.check_combo_arg(false);
            end
        end
        %
        function x    = get.idx(self)
            %GET.IDX - get the indices of each stored object in the container
            % which point to the unique objects stored internally.
            x = get_idx(self);
        end
        function self = set.idx(self,val)
            %SET.IDX - set the indices of each stored object in the container
            % which point to the unique objects stored internally. Really only
            % used by loadobj.
            if ~isnumeric(val)
                error('HERBERT:ObjContainerBase:invalid_argument',...
                    'idx may be only array of numeric values, identifying the object position in the container');
            end
            if min(val)<=0
                error('HERBERT:ObjContainerBase:invalid_argument',...
                    'idx are the indexes so they must be positive only. Minum of indexes provided is: %d', ...
                    min(val))
            end
            self.idx_ = val(:)';
            if self.do_check_combo_arg_
                self = self.check_combo_arg(false);
            end
        end
        %
        function n = get.n_objects(self)
            %GET.N_OBJECTS - retrieve size of container without duplicate
            % compression. This functionality is also provided by get.n_runs to
            % provide naming by the normal usage of this container for storing
            % instruments and samples in Horace. The two should be kept
            % synchronized.
            n = get_n_objects(self);
        end
        function n = get.n_runs(self)
            %GET.N_RUNS - retrieve size of container without duplicate
            % compression. This functionality duplicates that provided by
            % get.n_objects so that naming by the normal usage of this container for storing
            % instruments and samples in Horace is available. Both properties
            % should be kept synchronized.
            n = get_nruns(self);
        end
        function n = get.n_unique(self)
            n = get_n_unique(self);
        end
        %
        function x = get.n_duplicates(self)
            x = get_n_duplicates(self);
        end
        function self = set.n_duplicates(self,val)
            % temporary setter. Should be removed in a nearest future
            self = set_n_duplicates(self,val);
        end

        %------------------------------------------------------------------
        % helper methods
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

        function n =  get_nruns(self)
            %GET_NRUNS non-dependent-property form of n_runs
            % for use with arrayfun in object_lookup
            n = numel(self.idx_);
        end
        function is = is_in(self,idx)
            % returns true if input idx is within local indixes range
            % of the container or false otherwise
            is = all(idx>0 & idx<=self.n_objects);
        end
        function n = runs_sz(self)
            %RUNS_SZ converts n_runs to the form of output from size
            % to put unique_objects_container on the same footing as
            % array/cell in object_lookup
            n = size(self.idx_);
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
        %-----------------------------------------------------------------
        % Overloaded indexers
        function varargout = subsref(self,idxstr)
            if ~isscalar(self) % input is array or cell of unique_object_containers
                [varargout{1:nargout}] = builtin('subsref',self,idxstr);
                return;
            end
            % overloaded indexing for retrieving object from container
            switch idxstr(1).type
                case {'()','{}'}
                    b = idxstr(1).subs{:};
                    c = self.get(b);
                    if isscalar(idxstr)
                        varargout{1} = c;
                    else
                        idx2 = idxstr(2:end);
                        [varargout{1:nargout}] = builtin('subsref',c,idx2);
                    end
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',self,idxstr);
            end % end switch
        end % end function subsref
        function self = subsasgn(self,idxstr,varargin)
            % overloaded indexing for placing object to container

            % Use the replace if object lies in existing range and add if
            % at end+1 index
            % method to put the new object in the container.
            % the replacement method is the same for both types of
            % container; the duplication allows checking for incorrect
            % bracket use
            switch idxstr(1).type
                case {'()','{}'}
                    nuix = idxstr(1).subs{:};
                    if ~isscalar(idxstr)
                        c = self.get(nuix);
                        idx2 = idxstr(2:end);
                        c = builtin('subsasgn',c,idx2,varargin{:});
                        self = self.replace(c,nuix);
                    else
                        val = varargin{1}; % value to assign
                        if nuix == self.n_objects+1
                            self = self.add(val);
                        else
                            self = self.replace(val,nuix,'+');
                        end
                    end
                case '.'
                    self = builtin('subsasgn',self,idxstr,varargin{:});
            end
        end % subsasgn
        %------------------------------------------------------------------
        % generic methods
        function self = init(self, varargin)
            %INIT - constructor implementation for initializing empty
            %container
            if nargin==0
                return
            end
            flds = self.saveableFields();
            % standard serializable constructor
            self = self.set_positional_and_key_val_arguments(...
                flds,false,varargin{:});
        end
        %
        function subc = get_unique_field(self,fieldname)
            %GET_UNIQUE_FIELD each of the unique objects referred to by self
            % should have a property named 'field'. The code below takes each of the
            % referred objects in turn, extracts the object referred to by
            % 'field' and stores it in the appropriate type container
            % created here.

            storage    = unique_obj_store.instance().get_objects(self.baseclass);
            targ_class = class(storage.get(1).(fieldname));
            % create container of the self type to keep objects of
            % the class, defined by fieldname.
            clName = class(self);
            subc    = feval(clName);
            subc.baseclass = targ_class;
            % extract subclasses of the class requested
            for i=1:self.n_objects
                subobj = storage.get(self.idx_(i)).(fieldname);
                subc   = subc.add(subobj);
            end
        end
        %
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
            if isempty(self.baseclass_)
                self.baseclass = class(obj);
                warning('HERBERT:ObjContainerBase:incomplete_setup', ...
                    'baseclass not initialised, using first assigned type: "%s"', ...
                    self.baseclass);
            end
            is_container = isa(obj,'unique_objects_container');
            if ~(isa(obj,self.baseclass) || ...
                    (iscell(obj)&&all(cellfun(@(x)isa(x,self.baseclass),obj))) ||...
                    (is_container && isequal(self.baseclass,obj.baseclass)))
                error('HERBERT:ObjContainerBase:invalid_argument', ...
                    'Assigning object of class: "%s" to container with baseclass: "%s" is prohibited', ...
                    class(obj),self.baseclass);
            end

            if ~ischar(obj) && numel(obj)>1 || iscell(obj) || is_container
                nobj = numel(obj);
                if is_container
                    nobj = obj.n_objects;
                end
                nuix = zeros(1,nobj);
                if iscell(obj)
                    for i = 1:nobj
                        [self,nuix(i)]=self.add(obj{i});
                    end
                elseif is_container
                    for i = 1:nobj
                        [self,nuix(i)]=self.add(obj.get(i));
                    end
                else
                    for i = 1:nobj
                        [self,nuix(i)]=self.add(obj(i));
                    end
                end
                return;
            end
            [self,nuix] = self.add_single(obj);
        end % add()
    end
    %  Setter/getters for common interface with class-specific
    %  implementation
    methods
        %------------------------------------------------------------------
        function x = get.unique_objects(self)
            %GET.UNIQUE_OBJECTS Return the cell array containing the unique
            x = get_unique_objects(self);
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
            self  = set_unique_objects(self,val);
        end
    end
    methods(Access=protected)
        function x = get_idx(self)
            x = self.idx_;
        end
        function check_if_range_allowed(self,nuix,plus)
            % Validates if input non-unique index is in the range of indices
            % allowed for current state of the container
            if nargin==3
                upper_range = self.n_objects+1;
            else
                upper_range = self.n_objects;
            end
            if any(nuix < 1) || any(nuix > upper_range)
                error('HERBERT:ObjContainersBase:invalid_argument', ...
                    'Some or all input indices: [%d..%d] are outside allowed range [1:%d] for this container', ...
                    nuix(1),nuix(end),upper_range);
            end
        end
    end
    methods(Abstract)
        % expose cellarray of unique objects this container subscribes to.
        uoca = expose_unique_objects(self)

        %Finds if obj is contained in self
        [ix, hash,obj] = find_in_container(self,obj)

        % expand container onto specified number of runs.
        % only single unique object allowed to be present in the
        obj = replicate_runs(obj,n_objects)
        % retrieve appropriate container with objects, identified by
        % its inpu indices
        sset = get_subset(self,indices)
        %REPLACE replaces the object at specified non-unique index nuix
        [self,nuix] = replace(self,obj,nuix,varargin)
        % return container ordered in a particular way. Redundant?
        newself = reorder(self)
        % get hash for component with index provided
        val = hash(self,index)
    end
    methods(Abstract,Access=protected)
        % add single object to unique obects container
        [selt,uidx] = add_single(self,obj,varargin);
        % main getter for unique objects
        x = get_unique_objects(self,varargin);
        % main setter for the unique objects property
        self  = set_unique_objects(self,val);
        % get number of unique objects
        n = get_n_unique(self);
        %
        x    = get_n_duplicates(self);
        self = set_n_duplicates(self,val);
        % get total number of objects, stored in the container
        n = get_n_objects(self);
    end
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    methods
        function self = check_combo_arg(self,varargin)
            % runs after changing property or number of properties to check
            % the consistency of the changes against all other relevant
            % properties
            %
            if self.n_objects>0
                if isempty(self.baseclass_name_trial_) % no invoked setter for baseclass
                    self.baseclass_name_trial_ = self.baseclass_;
                end
                uobj = self.expose_unique_objects();
                invalid = cellfun(@(x)~isa(x,self.baseclass_name_trial_),uobj);
                if any(invalid)
                    error('HERBERT:ObjContainerBase:invalid_argument', ...
                        'One or more objects in the container are not isa(..,baseclass name: %s)', ...
                        self.baseclass_ );
                end
            end
            self.baseclass_ = self.baseclass_name_trial_;
            self.baseclass_name_trial_ = '';
        end
    end

end % classdef ObjContainersBase

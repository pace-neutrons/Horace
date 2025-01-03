classdef ObjContainersBase < serializable
    % ObjContainersBase Provides common interface for various object
    % containers
    properties (Dependent)
        baseclass;        % Name of the class or parent class, this container holds        
        n_objects;        % number of unique objects referred by this container
        n_unique;         % number of unique objects among all objects container refers
        %
        idx;               % object indices to retrieve object from a container
        unique_objects;    % return class-appropriate unique objects.
        %                    Differs for different children! (TODO --
        %                    redesign)
    end
    properties (Dependent,Hidden=true)
        % equvalent to n_objects but used in cases where it has physical
        % meaning -- numper of experimental runs. Hidden not to polute main
        % interface.
        n_runs
    end
    properties (Access=protected)
        baseclass_      = '';         % if not empty, name of the baseclass
        %                              this container holds. Should be suitable for isa() calls
        idx_            = zeros(1,0); %  array of unique global indices for each object stored        
        unique_objects_ = cell(1,0);  % storage for unique objects.
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
            if ~(ischar(val)||isstring(val))
                val = class(val);
            end
            self.baseclass_ = val;

            if self.do_check_combo_arg_
                self = self.check_combo_arg(false);
            end
        end
        %
        function x    = get.idx(self)
            %GET.IDX - get the indices of each stored object in the container
            % which point to the unique objects stored internally.
            x = self.idx_;
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
            n = numel(self.idx_);
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
            n = numel(self.unique_objects_);
        end
        %------------------------------------------------------------------
        % helper methods
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
                    c = self.get_unique_objects(b);
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
                        if isempty(self.baseclass_)
                            self.baseclass = class(val);
                            warning('HERBERT:ObjContainerBase:incomplete_setup', ...
                                'baseclass not initialised, using first assigned type: "%s"', ...
                                self.baseclass);
                        end
                        if ~isa(val,self.baseclass)
                            error('HERBERT:ObjContainerBase:invalid_argument', ...
                                'Assigning object of class: "%s" to container with baseclass: "%s" is prohibited', ...
                                class(val),self.baseclass);
                        end
                        self.check_if_range_allowed(nuix,'+');
                        if nuix == self.n_objects+1
                            self = self.add(val);
                        else
                            self = self.replace(val,nuix);
                        end
                    end
                case '.'
                    self = builtin('subsasgn',self,idxstr,varargin{:});
            end
        end % subsasgn
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
        %
    end
    methods(Abstract)
            % check if the container has the objects of the class "value"
            % if the value is char, or the the object equal value, if the
            % value is the object of the kind, stored in container        
           [is,unique_ind,obj] = contains(obj,value)
            % expand container onto specified number of runs.
            % only single unique object allowed to be present in the
            obj = replicate_runs(obj,n_objects)           

            %Finds if obj is contained in self
            [ix, hash,obj] = find_in_container(self,obj)            
            % retrieve appropriate container with objects, identified by
            % its inpu indices
            sset = get_subset(self,indices)
            %ADD adds an object to the container
            [self,nuix] = add(self,obj)  
            %REPLACE replaces the object at specified non-unique index nuix
            self = replace(self,obj,nuix)
            % get object stored in the container given non-unique index
            % associated with this object
            obj = get(self,nuix)
            % return container ordered in a particular way. Redundant?
            newself = reorder(self)
            % Retrieve container with collection of subobjects, for the
            % objects currently in container. Fancy
            field_vals = get_unique_field(self, field)
    end
    methods(Abstract,Access=protected)
        % Validates if input non-unique index is in the range of indices
        % allowed for current state of the container
        check_if_range_allowed(self,nuix,varargin);
        % main getter for unique objects
        x = get_unique_objects(self,varargin);        
        % main setter for the unique objects property
        self  = set_unique_objects(self,val);        
    end
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    methods
        function self = check_combo_arg(self,varargin)
            % runs after changing property or number of properties to check
            % the consistency of the changes against all other relevant
            % properties
            %
            if any( cellfun( @(x) ~isa(x,self.baseclass_), self.unique_objects_) )
                error('HERBERT:ObjContainerBase:invalid_argument', ...
                    'Unique objects in the container do not conform to the baseclass %s', ...
                    self.baseclass_ );
            end
        end
    end

end % classdef ObjContainersBase

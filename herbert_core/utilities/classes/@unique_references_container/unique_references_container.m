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
    % The instruments and samples in the experiment_info field of an SQW
    % are stored as unique_references_arrays. The global names for these
    % uses are
    % GLOBAL_NAME_INSTRUMENTS_CONTAINER
    % and
    % GLOBAL_NAME_SAMPLES_CONTAINER.
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
        global_name_; % name of category referencing a global container backing this one
    end
    
    properties (Dependent)
        
        % saveable fields for save/loadobj
        stored_baseclass;
        global_name;    % category name for singleton storage
        unique_objects; % returns unique_objects_container
        
        % other dependent properties
        n_unique_objects; % size of unique_objects (without creating it)
        idx; % object indices into the global unique objects container.
        n_objects; % numel(idx)
    end
    properties(Dependent,Hidden=true)
       n_runs;    % same as n_objects, provides a domain-specific interface
                   % to the number of objects for SQW-Experiment
                   % instruments and samples        
    end
    
    properties (Constant, Access=private) % serializable interface
        fields_to_save_ = { ...
            'stored_baseclass', ...
            'global_name', ... 5 must come before unique_objects
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
            
    
    methods % property (and method) set/get
        
        function self = set_all(self,v)
        %SET_ALL - used to reset the whole container to a single
        % value (NB alternative implementation property set.all not used, 
        % as `all` has other meanings in Matlab)
        % 
        % Input:
        % - v: scalar value to set all object in the container to
        
            if numel(v)==self.n_objects
                for i=1:self.n_objects
                    self = self.local_assign_(v(i),i); % self{i}=v does not work inside class
                end
            elseif numel(v)==1
                for i=1:self.n_objects
                    self = self.local_assign_(v,i); % self{i}=v does not work inside class
                end
            else
                 error('HERBERT:unique_objects_container:invalid_argument', ...
                            'assigned value must be scalar or have right number of objects');
            end
        end
            
        function val = get.idx(self)
        %GET.IDX - list of indices into the global container
        % Not recommended for normal use.
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
        
        function val = get.global_name(self)
        % GET.GLOBAL_NAME - the category name for this container where
        %                        the actual objects are stored
            val = self.global_name_;
        end
        function self = set.global_name(self,val)
        % SET.GLOBAL_NAME - the category name for this container where
        %                        the actual objects are stored
        % Input:
        % ------
        % - val: char string with the global name of the singleton
        %        container. Can only be set once.
            if ~(ischar(val)||isstring(val))
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'global name must be char');
            end
            if ~isempty(self.global_name)
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'global name cannot be reset once set');
            end
            self.global_name_ = val;
        end
            
        function uoca = expose_unique_objects(self)
        %EXPOSE_UNIQUE_OBJECTS - returns the unique objects contained in
        % self as a cell array. This allows the user to scan unique objects
        % for a property without having to rescan for duplicates. It is not
        % intended to expose the implementation of the container.
        
            % obtain a unique_objects_container with the unique objects
            uoca = self.unique_objects;
            % convert it to a cell array for external use
            uoca = uoca.expose_unique_objects();
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
        
            uoc = unique_objects_container('baseclass', self.stored_baseclass);
            glc = self.global_container('value', self.global_name_);
            for i=1:self.n_objects
                uoc = uoc.add( glc{ self.idx_(i) } );
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
            % global_name and baseclass should already have been set when loading
            self = self.init( self.global_name, self.stored_baseclass );
            % baseclass should already have been set when loading
            if ~strcmp( val.baseclass, self.stored_baseclass )
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'set unique objects with wrong stored baseclass');
            end
            for i=1:val.n_objects
                v = val{i};
                self = self.local_assign_(v,i); % self{i}=v does not work inside class
            end
        end
        
        function n = get.n_unique_objects(self)
           n = numel( unique(self.idx_) );
        end
        
        function [unique_objects, unique_indices] = get_unique_objects_and_indices(self)
        %GET_UNIQUE_OBJECTSAND_INDICES - get the unique objects and their
        % indices into the singleton container. Abandoned implementation
        % left in case it becomes useful.
            unique_indices = unique( self.idx_ );
            glc = self.global_container('value', self.global_name_);
            unique_objects = cell( 1,numel(unique_indices) );
            for i = 1:numel(unique_indices)
                unique_objects{i} = glc{ unique_indices(i) };
            end
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
        
            obj = obj@serializable();
            if nargin==2
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
        function varargout = subsref(self, idxstr)
            switch idxstr(1).type
                case {'()','{}'}
                    b = idxstr(1).subs{:};
                    if b<1 || b>numel(self.idx_)
                        error('HERBERT:unique_references_container:invalid_argument',...
                            'subscript %d out of range 1..%d', b, numel(self.idx_));
                    end
                    glindex = self.idx_(b);
                    glc = self.global_container('value',self.global_name_);
                    varargout{1} = glc(glindex);
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
            else
                val = varargin{1}; % value to assign
                nuix = idxstr(1).subs{:};
                self = self.local_assign_(val,nuix);
            end
        end
        
        function sset = get_subset(self, indices)
          sset = unique_objects_container('baseclass', self.stored_baseclass);
            for i=indices
                item = self.get(i);
                [sset,~] = sset.add(item);
            end
        end
        
        function obj_loc = find_in_container(self, obj)
           glc = self.global_container('value',self.global_name_);
            [ix,~] = glc.find_in_container(obj);
            inglc = ismember(ix, self.idx_);
            if ~any(inglc)
                obj_loc = [];
            else
                obj_loc = ix;
            end
        end
    end
    
    methods (Access = protected) % get, add, replicate and replace
        
        % really only for use within class. these implement
        % subsref/subsasgn action.
        
        function val = get(self,index)
        %GET - alternative access method: obj.get(i)===obj{i}
           glc = self.global_container('value',self.global_name_);
            val = glc{ self.idx(index) };
        end
        
        % 
        function [self, nuix] = add_single_(self,obj)
        %ADD_SINGLE - add a single object obj at the end of the container
            if isempty(self.stored_baseclass_)
                error('HERBERT:unique_references_container:incomplete_setup', ...
                      'stored baseclass unset');
            end
            if ~isa(obj,self.stored_baseclass_)
                warning('HERBERT:unique_references_container:invalid_argument', ...
                        'not correct stored base class; object was not added');
                nuix = 0;
                return;
            end
            if isempty(self.global_name_)
                error('HERBERT:unique_references_container:incomplete_setup', ...
                      'global name unset');
            end
            [glindex, ~] = self.global_container('value',self.global_name_).find_in_container(obj);
            if isempty(glindex)
                glcont = self.global_container('value',self.global_name_);
                [glcont,glindex] = glcont.add(obj);
                if glindex == 0
                    % object was not added
                    nuix = 0;
                    return
                end
                self.global_container('reset',self.global_name_,glcont);
            end
            self.idx_ = [ self.idx(:)', glindex ];
            nuix = numel(self.idx_);
        end
        
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
            
            if ~ischar(obj) && (numel(obj)>1 || iscell(obj) || ...
                                isa(obj, 'unique_objects_container'))
                            
                % Set flag that there are no elements
                nobj = 0;
                
                % find number of elements to process for the different
                % types of containers
                if isa(obj, 'unique_objects_container')
                    nobj = obj.n_objects;
                elseif numel(obj)>1 || iscell(obj)
                    nobj = numel(obj);
                end
                
                % if there are elements to process, add them
                if nobj>0
                    nuix = zeros(1,nobj);
                    if iscell(obj)
                        for i=1:nobj
                            [self,nuix(i)] = self.add_single_(obj{i});
                        end
                    else
                        for i=1:nobj
                            [self,nuix(i)] = self.add_single_(obj(i));
                        end
                    end
                end
                return;
            end
            
            % otherwise we have a single object or char array
            % add it to the container. Failure will return nuix==0 and
            % produce a warning.
            
            [self,nuix] = self.add_single_(obj);
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
        % Equivalent to self{nuix}=1 (which would not work inside the
        % container) and used to implement it.
        %
        % Input
        % -----
        % - obj:  object to be inserted into the container
        % - nuix: (non-unique index) position at which it is to be
        %         inserted. 
        % The old value is overwritten.
        
           [glindex, ~] = self.global_container('value',self.global_name_).find_in_container(obj);
            if isempty(glindex)
                [glcont,glindex] = ...
                    self.global_container('value',self.global_name_).add(obj);
                if glindex == 0
                    % object was not replaced
                    return
                end
                self.global_container('reset',self.global_name_,glcont);
            end
            self.idx_(nuix) = glindex;
        end
    end
    
    methods % check contents
        
        function [is, unique_index] = contains(self, item)
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
            glc = self.global_container('value', self.global_name_);

            % check if item is a class name - i.e. is char-type unless
            % the container contains char-type items
            if (ischar(item)   && ~strcmp(self.stored_baseclass, 'char')) || ...
               (isstring(item) && ~strcmp(self.stored_baseclass, 'string'))
               belongs = arrayfun( @(i) isa ( glc{i}, item), self.idx_ );
               is = any(belongs);
               unique_index = find(belongs);
               
            % check if item is an actual object which might be stored
            % in the global container
            else
               ix = glc.find_in_container(item); 

               if ~ismember(ix, self.idx_)
                   ix = [];
               end
               is = ~isempty(ix);
               unique_index = ix;
            end
        end
        
    end
    
    methods (Static)
        
        % the global container is a persistent struct in static method
        % global_container. This contains one field for each category (or
        % global name). Each field contains a unique_objects_container with
        % the relevant baseclass.
        
        function glc = global_container(opflag, glname, arg3)
        %GLOBAL_CONTAINER - method of accessing the global container for
        % the operations described below
        %
        % Inputs:
        % -------
        % - opflag:  name of operation:
        %            (external access)
        %            'init'  - create the category glname
        %                      arg3 is the baseclass
        %            'value' - return the container for the category
        %                      arg3 is not used
        %            (internal access only)
        %            'reset' - change the container for the category as
        %                      it has been modified. Used because it is
        %                      not a handle class.
        %                      arg3 is the new container being set
        %                      (normally the output from add or reset)
        %            (debugging access only)
        %            'CLEAR' - removes the container for the category
        %                      this invalidates ALL containers, so
        %                      should not be used for normal operation
        %                      arg3 is not used
        %
        % Outputs:
        % --------
        % - glc:    the global container being returned for this
        %           category
            
            persistent glcontainer;
                        
            % If the global container does not exist, initialise it with no
            % categories
            if isempty(glcontainer)
                glcontainer = struct();
            end
            
            % check minimum arguments
            if nargin<2
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'must be at least 2 arguments');
            end
            
            % check category name has correct type
            if ~ischar(glname)
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'global container name is %s not char',glname);
            end
            
            % if the category has not yet been created anywhere
            % create a global container for it
            if ~isfield(glcontainer,glname)
                switch opflag
                    case 'init'
                        if nargin < 3
                            error('HERBERT:unique_references_container:invalid_argument', ...
                                  'missing arg3 == stored baseclass');
                        end
                        baseclass = arg3;
                        glcontainer.(glname) = ...
                            unique_objects_container('baseclass', baseclass);
                        return;
                        
                    case 'CLEAR'
                        % do nothing - as the field hasn't been created yet
                        % leave the global container as it
                        return;
                        
                    otherwise
                        error('HERBERT:unique_references_container:invalid_argument', ...
                              ['try to set up a global container for this glname' ...
                               ' without the init opflag']);
                end
            end
            
            switch opflag
                case 'CLEAR'
                    
                    % put a new empty container in for this category
                    warning('HERBERT:unique_references_container:debug_only_argument', ...
                            ['DEBUG ONLY: clearing the global container for glname ' ...
                             '. This will invalidate all local containers for ' ...
                             ' this glname']);
                    glcontainer.(glname) = ...
                        unique_objects_container('baseclass', glcontainer.(glname).baseclass);
                    return;
                    
                case 'init'
                    % do nothing, the global container for this category
                    % already exists
                    return;
                    
                case 'value'
                    glc = glcontainer.(glname);
                    return;
                    
                case 'reset'
                    if nargin < 3
                        error('HERBERT:unique_references_container:invalid argument', ...
                              'missing arg3 == newcontainer');
                    end
                    newcontainer = arg3;
                    if isa(newcontainer, 'unique_objects_container')
                       glcontainer.(glname) = newcontainer;
                       return;
                    else
                        error('HERBERT:unique_references_container:invalid_argument', ...
                              ['attempt to reset container to something that is not', ...
                              ' a unique_objects_container']);
                    end
                    
                otherwise
                    error('HERBERT:unique_references_container:invalid_argument', ...
                          'invalid action on the global container')
                    
            end
        end
        
        % (save)/load functionality via serializable
        % save done via serializable directly
        
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = unique_references_container();
            obj = loadobj@serializable(S,obj);
        end
        
    end
end


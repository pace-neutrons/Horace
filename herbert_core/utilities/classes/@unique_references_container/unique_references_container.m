classdef unique_references_container < serializable
    %UNIQUE_REFERENCES_CONTAINER
    % This container stores objects of a common baseclass so that if some
    % contained objects are duplicates, only one unique object is stored
    % for all the duplicates.
    % The objects are assigned to a category, and all containers with the
    % same category have their unique objects stored in a singleton global
    % container for all unique_reference_containers of a given category
    % open in the current Matlab session. The static method
    % global_container implements this.
    % The global container does not persist between sessions and containers
    % written out to file are represented by separate
    % unique_objects_containers.
    % 
    % The overall aim here is - minimise storage of objects in a given
    % session. Achieve partial storage minimisation on file without needed
    % extra global objects also being written to file.
    
    properties (Access = protected)
        idx_ = zeros(1,0); %  array of unique global indices for each object stored
        baseclass_ = ''; % the baseclass
        global_name_; % name of category referencing a global container backing this one
    end
    
    properties (Dependent)
        
        % saveable fields for save/loadobj
        baseclass;
        global_name;    % category name for singleton storage
        unique_objects; % returns unique_objects_container
        
        % other dependent properties
        n_unique_objects; % size of unique_objects (without creating it)
        idx; % object indices into the global unique objects container.
        n_runs; % numel(idx)
    end
    
    properties (Constant, Access=private) % serializable interface
        fields_to_save_ = { ...
            'baseclass', ...
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
            
    
    methods % property set/get
        
        % property idx - list of indices into global container
        function val = get.idx(self)
            val = self.idx_;
        end
        %{
        % idx only set by adding objects to container
        function self = set.idx(self,val)
            if ~isnumeric(val)
                error('idx not numeric');
            end
            if min(val)<=0
                error('idx must be >0');
            end
            self.idx_ = val(:)';
        end
        %}
        
        % property baseclass - base class for all objects in the container
        function val = get.baseclass(self)
            val = self.baseclass_;
        end
        function self = set.baseclass(self,val)
            if ~(ischar(val)||isstring(val))
                val = class(val);
            end
            self.baseclass_ = val;
        end
        
        % property n_runs - number of non-unique items in the container
        function val = get.n_runs(self)
            val = numel(self.idx_);
        end
        % n_runs only set by adding objects to the container
        
        % property global_name - the category name for this container where
        %                        the actual objects are stored
        function val = get.global_name(self)
            val = self.global_name_;
        end
        function self = set.global_name(self,val)
            if ~(ischar(val)||isstring(val))
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'global name must be char');
            end
            self.global_name_ = val;
        end
            
        % property unique_objects - unique_objects_container version of
        %                           this container, principally used for
        %                           load/save to disc
        function uoc = get.unique_objects(self)
            uoc = unique_objects_container('baseclass', self.baseclass);
            glc = self.global_container('value', self.global_name_);
            for i=1:self.n_runs
                uoc = uoc.add( glc{ self.idx_(i) } );
            end
        end
        
        % this is assumed to be called from loadobj when restoring a
        % unique_reference_container from saved file. 
        function self = set.unique_objects(self,val)
            if ~isa(val,'unique_objects_container')
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'unique_objects must be a unique_objects_container');
            end
            % global_name should already have been set when loading
            self = self.init( self.global_name, self.baseclass );
            % baseclass should already have been set when loading
            if ~strcmp( val.baseclass, self.baseclass )
                error('HERBERT:unique_references_container:invalid_argument', ...
                      'set unique objects with wrong baseclass');
            end
            for i=1:val.n_runs
                v = val{i};
                self = self.local_assign_(v,i); % self{i}=v does not work inside class
            end
        end
        
        function n = get.n_unique_objects(self)
            n = numel( unique(self.idx_) );
        end

    end
    
     
    
    methods % constructor
        function obj = unique_references_container(varargin)
            obj = obj@serializable();
            if nargin==2
                glname = varargin{1};
                basecl = varargin{2};
                obj = obj.init(glname,basecl);
            end
        end
        
        function self = init(self, glname, basecl)
            self.global_name_ = glname;
            self.baseclass_ = basecl;
            self.global_container('init',glname,basecl);
        end
    end
       
    methods % overloaded indexers, subsets, find functions
        function varargout = subsref(self, idxstr)
            switch idxstr(1).type
                case {'()','{}'}
                    b = idxstr(1).subs{:};
                    glindex = self.idx_(b);
                    glc = self.global_container('value',self.global_name_);
                    varargout{1} = glc(glindex);
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',self,idxstr);
            end
        end
        
        %  replacement for self{nuix}=val which does not work inside the class
        function self = local_assign_(self,val,nuix)
            if nuix<1 || nuix>self.n_runs+1
                error('out of range');
            elseif nuix == self.n_runs+1
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
            sset = unique_objects_container('baseclass', self.baseclass);
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
    
    methods (Access = protected) % get, add and replace
        
        % really only for use within class. these implement
        % subsref/subsasgn action.
        
        % alternative access method
        function val = get(self,index)
            glc = self.global_container('value',self.global_name_);
            val = glc{ self.idx(index) };
        end
        
        % add object obj at the end of the container
        function [self, glindex] = add(self,obj)
            [glindex, ~] = self.global_container('value',self.global_name_).find_in_container(obj);
            if isempty(glindex)
                glcont = self.global_container('value',self.global_name_);
                [glcont,glindex] = glcont.add(obj);
                self.global_container('reset',self.global_name_,glcont);
            end
            self.idx_ = [ self.idx(:)', glindex ];
        end
        
        % substitute object obj at position nuix in container
        function [self] = replace(self,obj,nuix)
            [glindex, ~] = self.global_container('value',self.global_name_).find_in_container(obj);
            if isempty(glindex)
                [glcont,glindex] = ...
                    self.global_container('value',self.global_name_).add(obj);
                self.global_container('reset',self.global_name_,glcont);
            end
            self.idx_(nuix) = glindex;
        end
    end
    
    methods % check contents
        
        function [is, unique_index] = contains(self, item)
            
            % get out the global container for this container
            glc = self.global_container('value', self.global_name_);

            % check if item is a class name - i.e. is char-type unless
            % the container contains char-type items
            if (ischar(item)   && ~strcmp(self.baseclass, 'char')) || ...
               (isstring(item) && ~strcmp(self.baseclass, 'string'))
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
        
        %{
        what we want to do
        find if item is in self (the urc)
        stage 1 - find if item is in glc
        do this by glc.find_in_container(item)
        returns ix,hash. We so not want hash so just ix
        ix is the unique object instance location in glc
        ix may not exist in self so check
        jx = ismember( self.idx, ix )
        if ix is in self.idx, then jx is its position
        otherwise it is empty
        so if jx is empty return is == F and uniq=empty
        if jx is the position in self.idx
        then we have jx - the position in urc and is==T
        jx is an array of 0s and 1s for each element in self.idx
        1 where item can be found
        we turn this into positions by kx=find(ismember(....))
        which will return the indices in self.idx where item can be
        referenced
        so 
        ix is the unique location in glc where item can be found
        jx is the logical array for self.idx where ix can be found
        kx is the location in self.idx where item can be referenced
        
        how does this compare with uoc
        no ix
        jx is the ismember location logical for object in unique objects
        (via hashes but the same thing)
        kx is the location index in unique objects
        we want the unique object location in urc
        this is ix in glc if it is in self otherwise empty
        jx is not wanted it is an intermediate logical locator
        kx could also be wanted, it is the index in self.idx which can then
        be used to get ix
        kx is not unique as there could be more than one location of item
        in self(.idx). So the natural equivalent of uoc kx is ix if in self
        otherwise empty
        %}
        
    end
    
    methods (Static)
        
        % Access to the global container
        % the global container is a persistent struct in static method
        % global_container. This contains one field for each category (or
        % global name). Each field contains a unique_objects_container with
        % the relevant baseclass.
        
        function glc = global_container(opflag, glname, arg3)
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
                error('HERBERT:unique_references_container:invalid argument', ...
                      'global container name not char');
            end
            
            % if the category has not yet been created anywhere
            % create a global container for it
            if ~isfield(glcontainer',glname)
                switch opflag
                    case 'init'
                        if nargin < 3
                            error('HERBERT:unique_references_container:invalid argument', ...
                                  'missing arg3 == baseclass');
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
                        error('HERBERT:unique_references_container:invalid argument', ...
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
            
            %{
            % cases with 2 arguments ('value', 'CLEAR')
            if nargin >= 2
                % opflag=='value': get the container for this category
                % opflag=='CLEAR': CLEAR the container for this category. 
                % As this will invalidate ALL unique_reference_containers, 
                % ONLY use in a debugging environment
                elseif strcmp(opflag,'CLEAR')
                    warning('HERBERT:unique_references_container:debug_only_argument', ...
                            ['DEBUG ONLY: clearing the global container for glname ' ...
                             '. This will invalidate all local containers for ' ...
                             ' this glname']);
                    glcontainer.(glname) = ...
                        unique_objects_container('baseclass', glcontainer.(glname).baseclass);
                    return;
                end
            else
                error('HERBERT:unique_references_container:invalid argument', ...
                      'must be at least 2 args');
            end
            
            % cases with 3 args ('reset')
            if nargin >= 3
                % opflag=='reset': modify the container
                %                  usually as add or replace has changed it
                if strcmp(opflag,'reset')
                    container = arg3;
                    if isa(container, 'unique_objects_container')
                       glcontainer.(glname) = container;
                       return;
                    end
                end
            else
                error('with 3 args opflag must be *reset*');
            end
            %}
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


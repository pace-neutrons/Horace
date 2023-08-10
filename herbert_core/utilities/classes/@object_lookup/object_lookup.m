classdef object_lookup < serializable
    % An instance of object_lookup is a container for a set of arrays of objects
    %
    % The purpose of this class is twofold:
    %
    %   (1) To minimise memory requirements by retaining only unique instances
    %       of the objects in the set of arrays.
    %
    %   (2) To optimise the speed of selection of random points, or the speed
    %       of function evaluations, for an array of indices into one of the
    %       original object arrays in the set of object arrays. The optimisation
    %       arises when the array contains large numbers of repeated indices,
    %       that is, when the number of indices is much larger than the number
    %       of unique objects.
    %
    % For the indexed random number generation capability there must be a method
    % of the input object called rand that returns random points from the object.
    %
    % object_lookup Methods:
    %
    % The primary public methods are:
    %   object_lookup   - constructor
    %
    %   object_array    - retrieve a given object array from the set of object arrays
    %
    %   object_elements - retrieve one or more elements from a given object array in the set
    %
    %   func_eval_ind   - evaluate a method or function for indexed occurences in the object_lookup
    %
    %   rand_ind        - generate random points for indexed occurences in object_lookup
    %
    %
    % Relationship to pdf_table_lookup:
    % ---------------------------------
    % This class has similarities to <a href="matlab:help('pdf_table_lookup');">pdf_table_lookup</a>, which is specifically
    % for random number generation. That class provides random sampling from a
    % set of arrays of one-dimensional probability distribution functions.
    % This class is more general because random sampling that results in a vector
    % or array is supported, for example when the object method rand suplies a set
    % of points in a 3D volume.
    %
    % The reason for using this class rather than pdf_table_lookup is when one or
    % more of the following apply:
    %   (1) The main purpose is to compress the memory to keep only unique objects;
    %   (2) The pdf is multi-dimensional, or there is no object method called pdf_table;
    %   (3) Indexed evaluation of other methods or functions may be needed.
    %
    % See also pdf_table_lookup
    
    properties (Access=private)
        % Object array of unique instance of objects in the input array or cell array
        % (Column vector)
        object_store_ = zeros(0,1)
        
        % Cell array of indices into object_store_
        % (Column vector of column vectors)
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_ = cell(0,1)
        
        % Cell array of sizes of original object arrays
        % (Column cellarray of row vectors)
        sz_ = cell(0,1)
        
    end
    
    properties (Dependent)
        % Mirrors of private properties; these define object state:
        % ---------------------------------------------------------
        % Object array of unique instance of objects in the input array or cell array
        object_store
        
        % Cell array of indices into object_store
        % (Column vector of column vectors)
        % indx{i} is a column vector of indices for the ith object array.
        % The length of indx{i} = number of objects in the ith object array
        indx
        
        % The sizes of each of the stored arrays
        % (Column cellarray of row vectors)
        sz
        
        % Generic properties across all detector banks:
        % ---------------------------------------------
        % The number of arrays stored in the object_lookup (scalar)
        % Read only
        narray
        
        % The number of elements in each of the stored arrays (column vector)
        % Read only
        nelmts
        
        % True or false according as the object having at least one object array
        % Read only
        filled
        
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = object_lookup (varargin)
            % CONSTRUCTOR Create object lookup from various types of arrays of objects.
            % This can be done by one of the following 4 argument
            % combinations:
            % 
            % A. No arguments
            % 
            % Create an "empty" object. It is expected that this will be
            % immediately followed by a serialisable loadobj to populate
            % the lookup:
            %
            %   >> obj = object_lookup()
            %
            % B. A single argument which is a unique_objects_container or
            % cellarray of unique_objects_containers. It is expected that
            % this option will take objects created from a parent
            % unique_references_container (e.g. all moderators from a
            % unique_references_container of instruments - the output 
            % unique_objects_container has a very similar function to
            % object_lookup) and insert them as the equivalent contents of
            % the object_lookup.
            %
            %   >> obj = object_lookup(unique_objects_container1)
            %   >> obj = object_lookup({unique_objects_container1, ...
            %                           unique_objects_container2,...})
            %
            % C. Create object_lookup from one or more object (cell-)array(s):
            % 
            %   >> obj = object_lookup (objArr)
            %   >> obj = object_lookup (objArr1, objArr2, objArr3,...)
            %   >> obj = object_lookup ({objArr1, objArr2, objArr3,...})
            %
            %   With implicit repmat of each of the object arrays:
            %
            %   >> obj = object_lookup (..., 'repeat', sz_repmat)
            %
            % D. Directly set the object store and indexing array(s):
            %
            %   >> obj = object_lookup (object_store, indx)
            %   >> obj = object_lookup (object_store, indx, sz)
            %
            %
            % Input:
            % ------
            %   For option B:
            %   unique_objects_container1, unique_objects_container2, ...
            %              unique_objects_containers all containing one
            %              only type of object which will populate the
            %              object_lookup
            %
            %   For option C:
            %   objArr1, objArr2, ... objArrN
            %               Object arrays to be contained in the object_lookup
            %               object
            %   Also for option C if required:
            %   Optional keyword-value pair:
            %   'repeat', sz_repmat   
            %               sz_repmat is one of:
            %                 - the size of a single array:   sz
            %                 - a cell array of array sizes: {sz1,sz2,...szN}
            %
            %               by which to implicitly replicate the object arrays
            %               using the Matlab function repmat.
            %
            %               If sz_repmat is present, then the input object
            %               arrays are implicitly expanded as follows:
            %                 - single array size:
            %                       objArr1 => repmat(objArr1, sz)
            %                       objArr2 => repmat(objArr2, sz)
            %                           :               :
            %                 - cell array of array sizes:
            %                       objArr1 => repmat(objArr1, sz1)
            %                       objArr2 => repmat(objArr2, sz2)
            %                           :               :
            %               The arguments sz (or sz1, sz2,...) must be valid
            %               single argument input to the Matlab intrinsic
            %               function repmat i.e.
            %               - Valid array size from the Matlab function called
            %                 size i.e. row vectors of at least two integers all
            %                 of which must be greater than or equal to zero.
            %               - A single positive integer n greater than or equal
            %                 to zero. This is equivalent to size vector [n,n].
            %
            %               NOTE:
            %               -----
            %               In the case when there is only one object_array to
            %               store and sz_repmat is a cell array {sz1,sz2,...szN},
            %               the number of stored arrays is increased from 1 to N:
            %                   1st: repmat(objArr, sz1)
            %                   2nd: repmat(objArr, sz2)
            %                           :
            %                   Nth: repmat(objArr, szN)
            %
            %               This provides a mechanism to create an object_lookup
            %               with many identical stored arrays:
            %
            %               EXAMPLE
            %                   object_lookup (objArr, 'repeat', {1,1,1,1,1})
            %               is equivalent to
            %                   object_lookup (repmat(objArr,[1,5]))
            %               without the overhead of finding unique occurences of
            %               elements in objArr multiple times.
            %
            %
            %   For option D:
            %   object_store    Array of objects containing from which the
            %                   uncompressed object arrays can be recovered
            %                   from the index arrays in indx (below).
            %
            %   indx            Cell array of indices into object_store.
            %                   indx{i} is the vector of indices for the ith
            %                   object array. The length of ind{i} is the number
            %                   of objects in the ith object array.
            %
            %   Optional:
            %   sz              Cell array of sizes of the stored object arrays.
            %                   sz{i} is the size of the ith object array.
            %                   If not given, then it is assumed that the object
            %                   arrays have the same size as the corresponding
            %                   arrays indx{i}.
            %
            %
            % Output:
            % -------
            %   obj         Object_lookup object
            
            
            % Option A for input arguments:
            % No input arguments: default constructor - do nothing
            if nargin==0
                return  
            end
            
            % Option D for input arguments:
            if (nargin==2 || nargin==3) && all(cellfun (@isnumeric, varargin(2:end)))
                % Input can only be one of:
                %   >> obj = object_lookup (object_store, indx)
                %   >> obj = object_lookup (object_store, indx, sz)
                object_store = varargin{1};
                indx = varargin{2};
                sz = varargin{3};
                repeat = false;     % no implicit repmat

            % Option B for input arguments (single container):
            elseif isa(varargin{1}, 'unique_objects_container')

                objects = varargin{1};
                nw = numel(objects); % number of unique_object_containers

                % it is not possible to distinguish access of the first
                % element of a scalar unique_objects_container from access of
                % the first unique_objects_container in a
                % cell of such containers, when using a subscript. So the
                % cases are distinguished in this code
                if nw == 1
                    nel = objects.n_runs;
                    sz  = {objects.runs_sz};
                    obj_all = objects;
                else
                    nel = arrayfun( @get_nruns, objects );
                    sz = arrayfun( @runs_sz, objects, 'uniformoutput',false );

                    obj_all = unique_objects_container.concatenate(objects,'()');
                end

                if any(nel==0)
                    error('HERBERT:object_lookup:invalid_argument', ...
                          'Cannot have empty object containers');
                end

                % Fill lookup properties
                tmp = obj_all.unique_objects;
                object_store = vertcat(tmp{:}); %same orientation as for ordinary cells
                indx = mat2cell(obj_all.idx(:),nel,1);
                sz = sz(:);
                repeat = false; % no implicit repmat

            % Option B for input arguments (multiple containers):
            elseif iscell(varargin{1}) && all(cellfun(@(x) isa(x, 'unique_objects_container'), varargin{1}))

                objects = varargin{1};
                nel = cellfun( @get_nruns, objects );
                sz = cellfun( @runs_sz, objects, 'uniformoutput',false );
                obj_all = unique_objects_container.concatenate(objects,'{}');

                if any(nel==0)
                    error('HERBERT:object_lookup:invalid_argument', ...
                          'Cannot have empty object containers');
                end

                % Fill lookup properties
                tmp = obj_all.unique_objects;
                object_store = vertcat(tmp{:});
                indx = mat2cell(obj_all.idx(:),nel,1);
                sz = sz(:);
                repeat = false; % no implicit repmat

            % Option C for input arguments:
            else
                % Input can only be one of:
                %   >> obj = object_lookup (objects)
                %   >> obj = object_lookup (objects, 'repeat', sz_repmat)
                
                % Strip off 'repeat' option, if present
                if numel(varargin)>=3 && ischar(varargin{end-1})
                    % If the penultimate argument is a character array, then it
                    % can only be an optional keyword. It cannot be a valid
                    % object to be stored in the object_lookup
                    keyword = varargin{end-1};
                    if isempty(keyword) || ~strncmpi(keyword, 'repeat', numel(keyword))
                        error('HERBERT:object_lookup:invalid_argument', ...
                            'Unrecognised keyword option %s', keyword)
                    end
                    objArr = varargin(1:end-2);
                    repeat = true;
                    sz_repmat = varargin{end};
                else
                    objArr = varargin;
                    repeat = false;
                end
                
                % If there is only one argument before any keyword, and it is a
                % cell array, pick this out as the set of object arrays
                if numel(objArr)==1 && iscell(objArr{1})
                    objArr = objArr{1};
                end
                
                % Check all objects are in fact Matlab objects (i.e. we exclude
                % instances of MATLAB numeric, logical, char, cell, struct, and
                % function handle classes) and they have the same class
                class_name = class(objArr{1});
                tf = cellfun (@(x)(strcmp(class(x), class_name)), objArr);
                if ~all(tf)
                    error('HERBERT:object_lookup:invalid_argument', ...
                        'The classes of the object arrays are not all the same')
                end
                if ~isobject(objArr{1})
                    error('HERBERT:object_lookup:invalid_argument', ...
                        ['The object arrays to be stored cannot be MATLAB ',...
                        'numeric, logical, char, cell, struct or handle classes'])
                end
                
                % Prepare properties
                n_objArr = numel(objArr);
                
                % Now that the object arrays have been identified, validate the
                % repeat option argument before the unique object array is
                % determined - that could be a very expensive operation
                if repeat
                    sz_repmat = parse_sz_repmat (sz_repmat, n_objArr, n_objArr);
                end
                
                % Assemble the objects into one array
                nel = cellfun (@numel, objArr(:));
                nend = cumsum(nel);
                nbeg = nend - nel + 1;
                ntot = nend(end);
                
                object_store = repmat(objArr{1}(1),[ntot,1]);
                for i=1:n_objArr
                    object_store(nbeg(i):nend(i)) = objArr{i}(:);
                end
                
                % Create column cell array of index arrays into the full object list
                indx = mat2cell ((1:ntot)', nel, 1);
                
                % Get object array sizes as a column cell array
                sz = cellfun (@size, objArr(:), 'uniformOutput', false);
                
            end
            % End of argument option combinations
            
            % Now build the object:
            
            % - Disable interdependency validation
            obj.do_check_combo_arg_ = false;
            
            % - Build object from the state-defining properties
            obj.object_store = object_store;
            obj.indx = indx;
            obj.sz = sz;
            
            % - Turn on interdependency checking and check property
            %   interdependencies
            obj.do_check_combo_arg_ = true;
            obj = obj.check_combo_arg();
            
            % - Implicit repmat of stored objects, if requested
            % NB true only for some of option C for arguments
            if repeat
                obj = obj.object_repmat (sz_repmat);
            end
            
        end
        
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties; these define object state:
        % ---------------------------------------------------------
        function obj = set.object_store (obj, val)
            % Set the array of unique objects
            %
            %   >> obj.object_store = val
            %
            %   val     The array of unique instances of the objects in the
            %           object arrays that are recorded in the object_lookup
            %           object
            %
            % NOTE:
            % - If val is a scalar object, then it is assumed that every object
            %   in the stored object arrays are to be replaced by the new object
            %
            % - Only unique instances of objects in the array will be retained,
            %   and the corresponding indexing arrays held in obj.indx will be
            %   updated accordingly. These modified quantities will be returned
            %   by the corresponding getter methods:
            %       >> val = obj.object_store
            %       >> val = obj.indx
            %
            % - To recover the stored arrays, use the object_lookup method
            %   called object_array
            %
            % See also object_array object_element
            
            % The object store is turned into a column vector. An empty object
            % array is permitted.
            % Duplicate elements are removed and the corresponding index arrays
            % in property indx are updated in the call to check_combo_arg
            
            if ~isobject(val)
                error('HERBERT:object_lookup:invalid_argument', ...
                    'Property ''object_store'' must be a Matlab object or array of objects')
            end
            
            obj.object_store_ = val(:);     % ensure column vector
            
            % Check interdependencies
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        
        function obj = set.indx (obj, val)
            % Set index arrays into the object_store
            %
            %   >> obj.indx = val
            %
            %   val     Index array(s) into the unique object store of the
            %           stored object array(s):
            %           - Numeric array if there is a single stored object array
            %           - Cell array of index arrays, where val{i} is the vector
            %             of indices into the store for the ith object array
            %
            % NOTE:
            % - val will be stored as a column callarray of column vectors,
            %   which is how it will be returned by the corresponding getter:
            %       >> val = obj.indx
            
            % It is valid for an index array to be empty: this corresponds to an
            % empty stored object array
            
            % The following permits empty index arrays to pass the test, thereby
            % permitting the default object (i.e. constructor called with no
            % arguments) to pass.
            if ~iscell(val)
                val = {val};    % turn into a cell array with one element
            end
            positive_int_array = @(x)(all(x>=1,'all') && all(rem(x,1)==0, 'all'));
            if ~all (cellfun (@isnumeric, val), 'all') ||...
                    ~all (cellfun (@(x)positive_int_array(x), val), 'all')
                error('HERBERT:object_lookup:invalid_argument', ...
                    'Property ''indx'' must be a cell array of integer arrays')
            end
            
            % Make the set of indices a column cell array of column vectors
            % Note x(:) makes any empty array have size (0,1), as desired for
            % this property for any empty object array
            obj.indx_ = cellfun (@(x)(x(:)), val(:), 'uniformOutput', false);
            
            % Check interdependencies
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        
        function obj = set.sz (obj, val)
            % Set the array sizes for the object arrays in the object_store
            % Use this setter to reshape the stored object arrays
            %
            %   >> obj.sz = sz
            %
            %   sz      The size(s) of the stored object array(s) as would be
            %           returned by the Matlab size function
            %           - Row vector if a single stored object array
            %           - Cell array of row vectors where sz{i} is the Matlab
            %             array size of the ith stored object array
            
            % Stored object arrays can have zero size
            
            if ~iscell(val)
                val = {val};    % turn into a cell array with one element
            end
            
            size_array = @(x)(isrow(x) && numel(x)>=2 && all(x>=0) && all(rem(x,1)==0));
            if ~all (cellfun (@isnumeric, val), 'all') ||...
                    ~all (cellfun (@(x)size_array(x), val), 'all')
                error('HERBERT:object_lookup:invalid_argument', ...
                    'Property ''sz'' must be a cell array of valid Matlab array sizes')
            end
            
            % Trim excess trailing singleton dimensions in the size vectors, and
            % make the set of indices a column cell array
            sz_trim = @(sz)(sz(1:max([2, find(sz~=1,1,'last')])));
            obj.sz_ = cellfun (@(x)(sz_trim(x)), val(:), 'uniformOutput', false);
            
            % Check interdependencies
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties; these define object state:
        function val = get.object_store(obj)
            val = obj.object_store_;
        end
        
        function val = get.indx(obj)
            val = obj.indx_;
        end
        
        function val = get.sz(obj)
            val = obj.sz_;
        end
        
        % Other dependent properties:
        function val = get.narray(obj)
            val = numel(obj.sz_);
        end
        
        function val = get.nelmts(obj)
            val = cellfun(@prod, obj.sz_);
        end
        
        function val = get.filled(obj)
            val = (numel(obj.object_store_)>0);
        end

        function val = get_unique(obj,idx)
            if (idx==0)
                val = numel(obj.object_store_);
                return;
            end
            val = obj.object_store_(idx);
        end

        function obj = sort(obj)
            N = numel(obj.object_store_);
            hash1 = obj.hashify(obj.object_store_(1));
            object_hashes = repmat({hash1},numel(obj.object_store_),1);
            for ii=2:numel(obj.object_store)
                object_hashes{ii} = obj.hashify(obj.object_store_(ii));
            end
            [~, sorted_idx] = sort(object_hashes);
            obj.object_store_ = obj.object_store_(sorted_idx);
            [present, inverse_idx] = ismember(1:N, sorted_idx);
            if any(~present)
                error('HERBERT:object_lookup:invalid_argument','missing indices');
            end
            if numel(unique(inverse_idx))<numel(inverse_idx)
                error('HERBERT:object_lookup:invalid_argument','duplicate indices');
            end
            if max(inverse_idx)>N || min(inverse_idx)>1
                error('HERBERT:object_lookup:invalid_argument','incorrect indices');
            end
            for ii=1:numel(obj.indx)
                for jj=1:numel(obj.indx{ii})
                    k = obj.indx{ii}(jj);
                    obj.indx_{ii}(jj) = inverse_idx(k);
                end
            end
        end        
        %------------------------------------------------------------------
    end
    
    
    %======================================================================
    % SERIALIZABLE INTERFACE
    %======================================================================
    
    methods
        function ver = classVersion (~)
            % Current version of class definition
            ver = 2;
        end
        
        function flds = saveableFields (~)
            % Return cellarray of properties defining the class
            flds = {'object_store', 'indx', 'sz'};
        end
        
        function obj = check_combo_arg (obj)
            % Verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check.
            %
            % Recompute any cached arguments.
            %
            % Throw an error if the properties are inconsistent and return
            % without problem it they are not.
            
            % Check the number of index arrays and the number of size vectors are
            % the same. This gives the number of stored arrays
            if numel(obj.indx_) ~= numel(obj.sz_)
                error('HERBERT:object_lookup:invalid_argument', ...
                    ['The number of stored array sizes is inconsistent with the ',...
                    'number of index arrays'])
            end
            
            % Check the sizes of the stored object arrays are consistent with the
            % length of the index arrays
            nel = cellfun(@prod, obj.sz_);
            n_indx = cellfun(@numel, obj.indx_);
            if any(n_indx ~=  nel)
                error('HERBERT:object_lookup:invalid_argument', ...
                    ['The number of elements in one or more index arrays is ',...
                    'inconsistent with the size of the corresponding stored object array(s)'])
            end
            
            % Check that indices are in range of the number of objects
            % Empty index arrays are in range, even for an empty object_store
            nobj = numel(obj.object_store_);
            max_indx = cellfun (@(x)(max([0;x])), obj.indx_);   % max([0;x]) ensures 0 for empty x
            if ~all(max_indx<=nobj)
                error('HERBERT:object_lookup:invalid_argument', ...
                    ['One or more index arrays in ''indx'' point to objects ',...
                    'out of range of the stored objects'])
            end
            
            % Get unique entries and update index arrays
            % Use the fact that if:
            %   A = B(m), where m is an indexing array, and
            %   B = C(n),
            % then
            %   A = C(q), with q = n(m)
            
            if fieldsNumLogChar (obj.object_store_, 'indep')
                [obj_unique, ~, ind_n] = uniqueObj (obj.object_store_);    % simple object
            else
                [obj_unique, ~, ind_n] = genunique (obj.object_store_, 'resolve', 'indep');
            end
            obj.object_store_ = obj_unique;
            ind_m = cell2mat(obj.indx_);
            obj.indx_ = mat2cell (ind_n(ind_m), nel, 1);
            
        end
        
    end
    
    %----------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = object_lookup();
            obj = loadobj@serializable(S,obj);
        end

        function hash = hashify(obj)
            % makes a hash from the argument object
            % which will be unique to any identical object
            %
            % Input:
            % - obj : object to be hashed
            % Output:
            % - hash : the resulting hash, a row vector of uint8's
            %
            Engine = java.security.MessageDigest.getInstance('MD5');
            if isa(obj,'serializable') 
                % use default serializer, build up by us for serializable objects
                Engine.update(obj.serialize());
            else
                %convert_to_stream_f_ = @getByteStreamFromArray;
                Engine.update(getByteStreamFromArray(obj));
            end
            hash = typecast(Engine.digest,'uint8');
            hash = char(hash');
        end
    end
    %======================================================================
    
end

classdef object_lookup
    % Optimised lookup table for a set of arrays of objects.
    %
    % The purpose of this class is twofold:
    %
    %   (1) To minimise memory requirements by retaining only unique instances
    %       of the objects in the set of arrays;
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
    % See also pdf_table_lookup
    
    properties (Access=private)
        % Class version number
        class_version_ = 1;
        
        % Object array (column vector)
        object_store_ = []
        
        % Cell array of sizes of original object arrays
        sz_ = cell(0,1)
        
        % Index array (column vector)
        % Cell array of indices into the object_store_, where
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_ = cell(0,1)
    end
    
    properties (Dependent)
        % Object array of unique instance of objects in the input array or cell array
        object_store
        
        % Cell array of indices into object_store.
        % indx{i} is a column vector of indices for the ith object array.
        % The length of indx{i} = number of objects in the ith object array
        % Read only
        indx
        
        % The number of arrays stored in the object_lookup
        % Read only
        narray
        
        % The number of elements in each of the stored arrays
        % Read only
        nelmts
        
        % The sizes of each of the stored arrays (column cellarray of row
        % vectors)
        % Read only
        sz
        
        % True or false according as the object having at least one object array
        % Read only
        filled
        
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = object_lookup (objects, varargin)
            % Create object lookup from an array of objects
            %
            % Create object_lookup from object array(s):
            %   >> obj = object_lookup (objects)
            %
            %   >> obj = object_lookup (objects, '-repeat', sz_repmat)
            %
            % Directly set the object store and indexing array(s):
            %   >> obj = object_lookup (object_store, indx)
            %
            %
            % Input:
            % ------
            %   objects     Object array, or cell array of object arrays
            %               or cell array of unique_objects_containers
            %               Each of the object arrays must contaion at least one
            %               element.
            %
            % Optional:
            %   sz_repmat   Size of array, or cell array of size arrays, by
            %               which to repeat copies of the object arrays using
            %               Matlab function repmat.
            %               Size arrays must be valid output from the Matlab
            %               function size for non-empty arrays i.e. row vectors
            %               of at least two integers all of which must be
            %               greater than zero.
            %
            %   Either or both of object and sz_repmat can be a cell array; if
            %   one is not a cell array, it is expanded by copying to a a cell
            %   array of the same size as the other.
            %
            %   For example, suppose objArr1 and objArr2 are two arrays of
            %   objects, and sz1 and sz2 are two size arrays, then the following
            %   pairs of constructors are equivalent:
            %
            %       object_lookup ({objArr1, objArr2}, '-repeat', sz1)
            %       object_lookup ({objArr1, objArr2}, '-repeat', {sz1, sz1})
            %
            %       object_lookup ( objArr1, '-repeat', {sz1, sz2})
            %       object_lookup ({objArr1, objArr1}, '-repeat', {sz1, sz2})
            %
            %
            % Direct setting of object store and indexing arrays:
            % - - - - - - - - - - - - - - - - - - - - - - - - - -
            %   object_store    Array of objects containing from which the
            %                   uncompressed object arrays can be recovered
            %                   from the index arrays in indx (below).
            %
            %   indx            Cell array of indices into object_store.
            %                   indx{i} is the vector of indices for the ith
            %                   object array. The length of ind{i} is the number
            %                   of objects in the ith object array.
            %
            %
            % Output:
            % -------
            %   obj         Object_lookup object
            
            
            if nargin==1 && isstruct(objects)
                % Assume trying to initialise from a structure array of properties
                obj = object_lookup.loadobj(objects);
                
            elseif nargin>0
            
                if isa(objects, 'unique_objects_container')
                    
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
                    obj.object_store_ = vertcat(tmp{:}); %same orientation as for ordinary cells
                    obj.indx_ = mat2cell(obj_all.idx(:),nel,1);
                    obj.sz_ = sz(:);
                    
                elseif iscell(objects) && all(cellfun(@(x) isa(x, 'unique_objects_container'), objects))
                    
                    nel = cellfun( @get_nruns, objects );
                    sz = cellfun( @runs_sz, objects, 'uniformoutput',false );
                    obj_all = unique_objects_container.concatenate(objects,'{}');

                                        
                    if any(nel==0)
                        error('HERBERT:object_lookup:invalid_argument', ...
                              'Cannot have empty object containers');
                    end
                    
                    % Fill lookup properties
                    tmp = obj_all.unique_objects;
                    obj.object_store_ = vertcat(tmp{:});
                    obj.indx_ = mat2cell(obj_all.idx(:),nel,1);
                    obj.sz_ = sz(:);
                    

                elseif nargin==1 || (nargin==3 && ischar(varargin{1}) &&  numel(varargin{1})>=2 ...
                        && strncmpi(varargin{1},'-repeat',numel(varargin{1})))
                    % Input can only be one of the forms:
                    %   >> obj = object_lookup (objects)
                    %   >> obj = object_lookup (objects, '-repeat', sz_repmat)
                    
                    % Make a cell array for convenience, if not already
                    if ~iscell(objects)
                        objects = {objects};    % make objects a cell array length unity
                    end
                    
                    % set locally and check number of available objects
                    nobj_arr = numel(objects);
                    if nobj_arr==0
                        error('HERBERT:object_lookup:invalid_argument', ...
                            'There must be at least one object array to optimise')
                    end

                    % Check all arrays have the same class - requirement for sorting later on
                    if numel(objects)>1
	                    class_name = class(objects{1});
	                    tf = cellfun (@(x)(strcmp(class(x), class_name)), objects);
	                    if ~all(tf)
	                        error('HERBERT:object_lookup:invalid_argument', ...
	                            'The classes of the object arrays are not all the same')
	                    end
                    end
                    
                    % Check validity of sz_repmat, if present (check now before
                    % performing any expensive operations on the objects)
                    if nargin==3
                        repeat = true;
                        if iscell(varargin{2})
                            sz_repeat = varargin{2};
                        else
                            sz_repeat = varargin(2);   % make it a cell array length unity
                        end
                        nsz_repeat = numel(sz_repeat);
                        if nsz_repeat==0
                            error('HERBERT:object_lookup:invalid_argument', ...
                                'If it has been given, the set of repeat sizes cannot be empty')
                        end
                        tf = cellfun (@isnumeric, sz_repeat(:)) & ...
                            cellfun(@isrow, sz_repeat(:)) & ...
                            ~cellfun(@isempty, sz_repeat(:)) & ...
                            cellfun(@(x)(all(x>0)), sz_repeat(:));
                        if ~all(tf)
                            error('HERBERT:object_lookup:invalid_argument', ...
                                ['Repeat sizes must all be an integer>=1 or a valid Matlab array ',...
                                'sizes for non-empty arrays'])
                        end
                        if ~(isscalar(nobj_arr) || isscalar(nsz_repeat) || ...
                                nobj_arr==nsz_repeat)
                            error('HERBERT:object_lookup:invalid_argument', ...
                                ['The number of object arrays and repeat sizes must ',...
                                'be the same if they are both greater than one'])
                        end
                        ncopies = cellfun (@prod, sz_repeat(:), 'uniformoutput', false);    % cellarray of scalars
                    else % nargin=1
                        repeat = false;
                    end
                    
                    % Assemble the objects into one array
                    nel = cellfun (@numel, objects(:));
                    sz = cellfun (@size, objects(:), 'uniformoutput', false);
                    if any(nel==0)
                        error('HERBERT:object_lookup:invalid_argument', ...
                            'Cannot have any empty object arrays')
                    end
                    
                    nend = cumsum(nel);
                    nbeg = nend - nel + 1;
                    ntot = nend(end);
                    
                    obj_all=repmat(objects{1}(1),[ntot,1]);
                    for i=1:nobj_arr
                        obj_all(nbeg(i):nend(i))=objects{i}(:);
                    end
                    
                    % Get unique entries and cell array of index arrays

                    if fieldsNumLogChar (obj_all, 'indep')
                        [obj_unique,~,ind] = uniqueObj(obj_all);    % simple object
                    else
                        [obj_unique,~,ind] = genunique(obj_all,'resolve','indep');
                    end

                    ind = mat2cell(ind,nel,1);
                    
                    % Expand the index and sz arrays if required
                    % The unique objects do not need to be altered, and repeated
                    % elements of the object arrays does not alter the unique
                    % objects required to reconstruct the object arrays
                    if repeat
                        if nobj_arr>1
                            if nsz_repeat>1
                                sz = cellfun(@(x,y)(sz_repmat(x,y)), sz, sz_repeat(:),...
                                    'uniformoutput', false);
                                ind = cellfun(@(x,y)(repmat(x,[y,1])), ind, ncopies,...
                                    'uniformoutput', false);
                            else
                                sz = cellfun(@(x)(sz_repmat(x,sz_repeat{1})), sz,...
                                    'uniformoutput', false);
                                ind = cellfun(@(x)(repmat(x,[ncopies{1},1])), ind,...
                                    'uniformoutput', false);
                            end
                        else
                            if nsz_repeat>1
                                sz = cellfun(@(x)(sz_repmat(sz{1},x)), sz_repeat(:),...
                                    'uniformoutput', false);
                                ind = cellfun(@(x)(repmat(ind{1},[x,1])), ncopies,...
                                    'uniformoutput', false);
                            else
                                sz = {sz_repmat(sz{1},sz_repeat{1})};
                                ind = {repmat(ind{1},[ncopies{1},1])};
                            end
                        end
                    end
                    
                    % Fill lookup properties
                    obj.object_store_ = obj_unique;
                    obj.indx_ = ind;
                    obj.sz_ = sz;
                    
                elseif nargin==2
                    % Input can only be of form: object_lookup (object_store, indx)
                    error('***DIRECT SETTING OF OBJECT_STORE AND INDX NOT YET IMPLEMENTED')
                else
                    error('HERBERT:object_lookup:invalid_argument', ...
                        'Invalid number and/or type of input argument(s)')
                end
            end
            
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj=set.object_store(obj,val)
            % Replace the object lookup table with another set of objects
            %
            %   >> obj.object_store = new_object_store
            %
            % The number of objects in new array must be scalar or match the
            % number in the current value of the property object_store.
            %
            % - If scalar, then it is assumed that every object in the current
            %   array is to be replaced by a copy of the new object
            %
            % - If array of same size as current object array, no check is
            %   made that the objects are unique. This will not cause an error,
            %   but calls to function evaluations or random point generation
            %   will not be as efficient as they could be.
            
            if numel(val)==numel(obj.object_store_) || isscalar(val)
                if numel(obj.object_store_)>0
                    if numel(val)==numel(obj.object_store_)
                        obj.object_store_ = val(:);
                    else
                        obj.object_store_ = repmat(val(:),size(obj.object_store_));
                    end
                else
                    % Force default null object_store if currently unassigned
                    null = object_lookup;
                    obj.object_store = null.object_store_;
                end
            else
                error('HERBERT:object_lookup:invalid_argument', ...
                    'Replacement for property ''object_store'' must be scalar or have the same number of objects')
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val=get.indx(obj)
            val=obj.indx_;
        end
        
        function val=get.object_store(obj)
            val=obj.object_store_;
        end
        
        function val=get.narray(obj)
            val=numel(obj.indx_);
        end
        
        function val=get.nelmts(obj)
            val=cellfun(@numel, obj.indx_);
        end
        
        function val=get.sz(obj)
            val=obj.sz_;
        end
        
        function val=get.filled(obj)
            val=(numel(obj.object_store_)>0);
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
            [sorted_hashes, sorted_idx] = sort(object_hashes);
            obj.object_store_ = obj.object_store_(sorted_idx);
            [present inverse_idx] = ismember([1:N], sorted_idx);
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
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end
            
        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end
            
        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility
    
    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %           or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        
        function hash = hashify(obj)
            % makes a hash from the argument object
            % which will be unique to any identical object
            %
            % Input:
            % - obj : object to be hashed
            % Output:
            % - hash : the resulting has, a row vector of uint8's
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


        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

%--------------------------------------------------------------------------
function sz_out = sz_repmat (sz, sz_repeat)
% Return the size of the array that would be output by using repmat
% 
%   >> sz_out = sz_repmat (sz, sz_repeat)
%
% sz_out is the size of the array A_out obtained by the function call:
%   >> A_out = repmat (A, sz_repmat)
% 
% where sz = size(A). sz_repmat is a scalar or a row vector with length >= 2


if numel(sz_repeat)==1
    sz_repeat = [sz_repeat,sz_repeat];
end
n1 = numel(sz);
n2 = numel(sz_repeat);
if n1>n2
    sz_out = [sz(1:n2).*sz_repeat, sz(n2+1:end)];
elseif n1<n2
    sz_out = [sz.*sz_repeat(1:n1), sz_repeat(n1+1:end)];
else
    sz_out = sz.*sz_repeat;
end

end
